// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    ERC4626
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ReadCodecV1,
    EVMCallRequestV1
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {StrategyHelper} from "./StrategyHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {VaultStrategies} from "./VaultStrategies.sol";
import {
    MessagingReceipt
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultManager} from "./VaultManager.sol";
import {IVaultManager as VaultFactory} from "./IVaultManager.sol";

import {VaultRegistryManager} from "./VaultRegistryManager.sol";

contract VaultRegistry is Ownable, OApp, VaultRegistryManager {
    address _endpoint;
    uint32 _endpointId;
    address _delegate;
    address[] authrizedCallers;

    constructor(
        address __endpoint,
        address __delegate
    ) Ownable(__delegate) OApp(__endpoint, __delegate) VaultRegistryManager() {
        _delegate = __delegate;
        authrizedCallers.push(__delegate); //this authorized user should be the one we use in api
    }

    function deployHubVault(
        bytes memory deployParamsEncoded
    ) public returns (uint256) {
        (VaultHelper.VaultDeployParams memory deployParams) = abi.decode(
            deployParamsEncoded,
            (VaultHelper.VaultDeployParams)
        );
        VaultManager vaultDpeloyed = new VaultManager(deployParams);
        VaultFactory convertedVault = VaultFactory(
            payable(address(vaultDpeloyed))
        );

        address[] memory authroized;

        authroized[0] = deployParams.deployer;
        VaultHelper.Vault memory vaultInfo = VaultHelper.Vault(
            deployParams.deployer,
            0,
            0,
            convertedVault,
            deployParams.vaultName,
            deployParams.vaultTicker,
            deployParams.vaultAsset,
            deployParams.authorizedVip
        );
        setDeployedVaults(deployParams.deployer, convertedVault);
        uint256 vaultId = setVault(vaultInfo);

        return vaultId;
    }

    function deployMultiChainVault(
        VaultHelper.BulkVaultDeployments[] memory deploymentQuotes
    ) public {
        for (uint256 i = 0; i < deploymentQuotes.length; i++) {
            VaultHelper.BulkVaultDeployments
                memory currentTarget = deploymentQuotes[i];

            textRegistry(
                currentTarget._dstEid,
                currentTarget.message,
                currentTarget.fee,
                currentTarget.refundAddress
            );
        }
    }

    //sends message to other registry
    function textRegistry(
        uint32 _dstEid,
        bytes memory _message,
        MessagingFee memory _fee,
        address _refundAddress
    ) public payable {
        _lzSend(_dstEid, _message, options, _fee, _refundAddress);
    }

    function getMultiChainDpeloymentQuote(
        address _user,
        bytes[] memory messages,
        uint32[] memory _dstEids
    )
        public
        view
        returns (VaultHelper.BulkVaultDeployments[] memory deployments)
    {
        bool matchesLength = messages.length == _dstEids.length;
        require(matchesLength, "Cannot iterate no matching arrays");

        for (uint256 i = 0; i < _dstEids.length; i++) {
            MessagingFee memory currentQuote = getMessageQuote(
                _dstEids[i],
                messages[i]
            );
            VaultHelper.BulkVaultDeployments
                memory deploymentQuote = VaultHelper.BulkVaultDeployments(
                    currentQuote,
                    _dstEids[i],
                    messages[i],
                    messages[i],
                    _user
                );
            deployments[i] = (deploymentQuote);
        }
    } //work on this tn almost done with registry

    function verifyPeerExistence() public {}
    bool payInLz = false;
    bytes options = bytes(""); //options we should througholy preconfigure o vaults get gas to do stuff

    function getMessageQuote(
        uint32 _dstEid,
        bytes memory _message
    ) public view returns (MessagingFee memory) {
        MessagingFee memory fee = _quote(_dstEid, _message, options, false);
        return fee;
    }

    function addressToBytes32(address _addr) public pure returns (bytes32) {
        // First convert to fixed bytes20, then expand to bytes32
        return bytes32(bytes20(_addr));
    }

    //vualts should only communicate with the registry with wirdawring depostiing etc registry in the main brnahc
    //managers are the subbranhces
    function addRegistryPeer(uint32 eid, address _registry) public {
        bytes32 encodedRegistry = addressToBytes32(_registry);
        _setPeer(eid, encodedRegistry); //each peer should be vault registry on every chain
    }

    function deposit(
        address _user,
        uint256 _vaultId,
        uint256 _amountAssets,
        address _depositor
    ) public payable returns (uint256 _sharesSent) {
        IERC20 asset = vaults[_vaultId].depositAsset;
        assetBalanceCheck(asset, _amountAssets, _depositor);
        verifyUserExistence(_user);
        verifyAssetAllownce(_vaultId, _user, _amountAssets);
        (uint256 _shares) = vaults[_vaultId].vault.depositAssets(
            _amountAssets,
            _depositor
        );

        _sharesSent = _shares;
    }

    function verifyAssetAllownce(
        uint256 vaultId,
        address _user,
        uint256 _amount
    ) public view {
        bool isVaild = vaults[vaultId].vault.verifyAssetApproval(
            _user,
            _amount
        );
        require(isVaild, "Not enough allownace to complete tx");
    }

    function assetBalanceCheck(
        IERC20 asset,
        uint256 amountNeeded,
        address _caller
    ) public view {
        bool hasBalance = asset.balanceOf(_caller) > amountNeeded;

        require(hasBalance == true, "Not enough to run transaction!");
    }

    function vaultWithdraw(
        uint256 _vaultId,
        uint256 shares,
        address reciever
    ) public {
        vaults[_vaultId].vault.withdrawAssets(shares, reciever);
    }

    function verifyOnlyCaller(address _caller) public view {
        bool isValid = false;

        for (uint256 i = 0; i < authrizedCallers.length; i++) {
            if (authrizedCallers[i] == _caller) {
                isValid = true;
            }
        }

        require(isValid == true, "Caller not valid does not match");
    }

    function _lzReceive(
        Origin calldata,
        /*_origin*/
        bytes32,
        /*_guid*/
        bytes calldata _message,
        address,
        /**
         * _executor
         */
        bytes calldata //_extraData
    ) internal override {
        // handle incoming LayerZero message
        (bool success, ) = address(this).call(_message);

        require(success, "Message recieved but tx reverted!");
    }
}
