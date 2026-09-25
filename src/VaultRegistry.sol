// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {OAppOptionsType3} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReadCodecV1, EVMCallRequestV1} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {StrategyHelper} from "./StrategyHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {VaultStrategies} from "./VaultStrategies.sol";
import {MessagingReceipt} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultManager} from "./VaultManager.sol";
import {IVaultManager as VaultFactory} from "./IVaultManager.sol";

import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

import {VaultRegistryManager} from "./VaultRegistryManager.sol";

contract VaultRegistry is Ownable, OApp, VaultRegistryManager {
    address _endpoint;
    uint32 _endpointId;
    address _delegate;
    address[] authrizedCallers;

    constructor(address __endpoint, address __delegate)
        Ownable(__delegate)
        OApp(__endpoint, __delegate)
        VaultRegistryManager()
    {
        authrizedCallers.push(_delegate); //this authorized user should be the one we use in api
    }

    function deployHubVault(
        address deployer,
        address[] memory _authorizedVip,
        string memory vaultName,
        string memory vaultTicker,
        IERC20 _vaultAsset,
        address _creator,
        address vaultEndpoint,
        VaultAssets.FeesInfo memory _fees,
        VaultAssets.feeReceiversInfo memory _feeRecievers
    ) public returns (uint256) {
        VaultManager vaultDpeloyed = new VaultManager(
            _authorizedVip, vaultName, vaultTicker, _vaultAsset, _creator, vaultEndpoint, _fees, _feeRecievers
        );
        VaultFactory convertedVault = VaultFactory(payable(address(vaultDpeloyed)));

        address[] memory authroized;

        authroized[0] = deployer;
        VaultHelper.Vault memory vaultInfo =
            VaultHelper.Vault(deployer, 0, 0, vaultName, vaultTicker, _vaultAsset, authroized);
        setDeployedVaults(deployer, convertedVault);
        uint256 vaultId = setVault(vaultInfo);

        return vaultId;
    }

    function deployMultiChainVault(VaultHelper.BulkVaultDeployments[] memory deploymentQuotes) public {
        for (uint256 i = 0; i < deploymentQuotes.length - 1; i++) {
            VaultHelper.BulkVaultDeployments memory currentTarget = deploymentQuotes[i];

            textRegistry(currentTarget._dstEid, currentTarget.message, currentTarget.fee, currentTarget.refundAddress);
        }
    }

    //sends message to other registry
    function textRegistry(uint32 _dstEid, bytes memory _message, MessagingFee memory _fee, address _refundAddress)
        public
        payable
    {
        _lzSend(_dstEid, _message, options, _fee, _refundAddress);
    }

    function getMultiChainDpeloymentQuote() public {} //work on this tn almost done with registry
    bool payInLz = false;
    bytes options = bytes(""); //options we should througholy preconfigure o vaults get gas to do stuff

    function getMessageQuote(uint32 _dstEid, bytes memory _message) public view returns (MessagingFee memory) {
        MessagingFee memory fee = _quote(_dstEid, _message, options, false);
        return fee;
    }

    //vualts should only communicate with the registry with wirdawring depostiing etc registry in the main brnahc
    //managers are the subbranhces
    function addRegistryPeer(uint32 eid, bytes32 _registry) public {
        _setPeer(eid, _registry); //each peer should be vault registry on every chain
    }

    function vaultDeposit() public payable returns (bool) {
        return true;
    }

    function vaultWithdraw() public {}

    function setOnlyCaller() public {}

    function verifyOnlyCaller() public {}

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
    )
        internal
        override
    {
        // handle incoming LayerZero message
        address(this).call(_message);
    }
}
