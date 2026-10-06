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
import {IStrategyAdapter} from "./IStrategyAdapter.sol";
import {
    MessagingReceipt
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {IVaultManager as VaultFactory} from "./IVaultManager.sol";
import {
    OwnableUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {
    OAppUpgradeable
} from "../lib/devtools/packages/oapp-evm-upgradeable/contracts/oapp/OAppUpgradeable.sol";

abstract contract VaultManager is
    OwnableUpgradeable,
    OAppUpgradeable,
    ERC1967Proxy,
    VaultAssets
{
    address creator;
    address[] authorizedVip; //th api wallet should be inclided
    IERC20 vaultAsset;
    uint256 vaultId;

    IStrategyAdapter strategyAdapter;
    mapping(address => VaultHelper.DepositorInfo) depositors;
    bool isInStrategy = false;
    uint256 currentStrategyId;
    VaultManager vaultImplementation;

    struct Status {
        //use this on deposit if strategy is live we check this struct to verify and if its on other chain we bridge
        bool strategyActive;
        uint32 endpointId;
        address endpoint;
        uint256 strategyId;
    }
    modifier onlyAuhtorized(address attemptedUser) {
        bool isValid = false;
        for (uint256 i = 0; i < authorizedVip.length; i++) {
            if (authorizedVip[i] == attemptedUser) {
                isValid = true;
            }
        }
        require(isValid, "Not authrized to perform ");

        _;
    }

    constructor(address _endpoint) OAppUpgradeable(_endpoint) {}

    //vaultId should be in parameter

    //this funciton is suerd to iniitalize the clone
    function __initialize_vault_(
        VaultHelper.VaultDeployParams memory _deployParams,
        IStrategyAdapter _strategyAdapter
    ) external {
        authorizedVip = _deployParams.authorizedVip;

        vaultAsset = _deployParams.vaultAsset;
        creator = _deployParams.creator;
        strategyAdapter = _strategyAdapter;
        _initializeVaultAsssets_(
            _deployParams.vaultName,
            _deployParams.vaultTicker,
            _deployParams.vaultAsset,
            _deployParams.fees,
            _deployParams.feeReceivers
        );
        __Ownable_init(_deployParams.creator);
        __OApp_init(_deployParams.creator); //_deployParams.vaultEndpoint, _deployParams.creator
    }

    function getDepositorInfo(
        address _user
    )
        public
        view
        onlyAuhtorized(msg.sender)
        returns (VaultHelper.DepositorInfo memory)
    {
        return depositors[_user];
    }
    // bytes strategyInfo //bytes suppose dot be strategy info struct containing info and addresses
    function setPeer(
        uint32 _eid,
        address _peer
    ) public onlyAuhtorized(msg.sender) {}

    //must swap into strategy deposit asset before doing this

    function setStrategy(
        uint256 strategyId,
        bytes memory depositCallback
    ) public {
        if (isInStrategy) {
            strategyAdapter.withdrawAll(strategyId, bytes(""));
            strategyAdapter.deposit(
                vaultId,
                strategyId,
                _totalAssets,
                depositCallback
            );
        }
        currentStrategyId = strategyId;
    }

    function enterStrategy(
        address _user, //this we use to make sure user has enough in the vault
        uint256 strategyId,
        uint256 assets,
        bytes memory params
    ) public onlyAuhtorized(msg.sender) {
        bool isStrategyValid = strategyAdapter.verifyStrategyId(strategyId);
        if (isStrategyValid) {
            strategyAdapter.deposit(vaultId, strategyId, assets, params);
            if (isInStrategy == false) {
                activateStrategy(strategyId);
            }
        }
        deductTotalAssets(assets); //decreases since we are entering strategy
    }

    function activateStrategy(
        uint256 strategyId
    ) public onlyAuhtorized(msg.sender) {
        currentStrategyId = strategyId;
        isInStrategy = true;
    }

    function deactivateStrategy() public {
        isInStrategy = false;
    }

    //convertion rates in avenor api
    function exitStrategy(
        uint256 strategyId,
        uint256 assets,
        bytes memory params
    ) public {
        strategyAdapter.withdraw(strategyId, assets, params);
    }

    function emergencyExit(uint256 strategyId, bytes memory params) public {
        strategyAdapter.withdrawAll(strategyId, params);
    }

    function getStrategyInfo(
        uint256 _vaultId
    ) public view returns (VaultHelper.StrategyInfo memory) {
        uint256 totalAssets = strategyAdapter.getStrategyTotalAssets(_vaultId);
        address asset = strategyAdapter.getStategyAsset(_vaultId);
        uint256[] memory _vaultsDeposited = strategyAdapter.getStrategyVaults(
            _vaultId
        );

        return (VaultHelper.StrategyInfo(totalAssets, asset, _vaultsDeposited));
    }

    function getAsset() public view returns (IERC20) {
        return vaultAsset;
    }

    function getCreator() public view returns (address) {
        return creator;
    }

    function getAuthorizer(uint256 index) public view returns (address) {
        return authorizedVip[index];
    }

    function setAuthorizer(address authroized) public {
        authorizedVip.push(authroized);
    }

    function createDepositor(
        address _depositor,
        VaultHelper.DepositorInfo memory _info
    ) public {
        depositors[_depositor] = _info;
    }

    function crossChainDeposit(
        uint32 _dstEid,
        uint256 assets,
        address receiver
    ) public {}

    function depositAssets(
        uint256 assets,
        address receiver
    ) public returns (uint256 _shares) {
        //use status check here
        _shares = convertToShares(assets);
        bool successfulTransfer = vaultAsset.transferFrom(
            receiver,
            msg.sender,
            assets
        ); //must be approved
        require(
            successfulTransfer,
            "Transfer did not go through check approvals;"
        );
        mintShares(_shares, receiver);
        if (hasDeposited(receiver) != true) {
            createDepositor(
                receiver,
                VaultHelper.DepositorInfo(receiver, assets, _shares, assets)
            );
        } else {
            setSharesOwned(_shares, receiver, false);
            setAssetsDeposited(assets, receiver, false);
            setVolume(receiver, assets);
        }

        emit Deposit(receiver, receiver, assets, _shares);

        //deposit into vault
    }

    function checkStrategyCurrent(
        address _user,
        uint256 strategyId,
        uint256 assets,
        bytes memory params
    ) public {
        if (isInStrategy) {
            enterStrategy(_user, currentStrategyId, assets, params);
        }
    }

    receive() external payable {}

    function hasDeposited(address _user) public view returns (bool) {
        return depositors[_user].assetVolume > 0;
    }

    function setAssetsDeposited(
        uint256 _amount,
        address _assetOwner,
        bool isDeducted
    ) public {
        if (isDeducted) {
            require(
                depositors[_assetOwner].shares >= _amount,
                "Not enogh o perform arethmetic"
            );
            depositors[_assetOwner].assets -= _amount;
        } else {
            depositors[_assetOwner].assets += _amount;
        }
    }

    function setVolume(address _user, uint256 _newVolume) public {
        depositors[_user].assetVolume += _newVolume;
    }

    function setSharesOwned(
        uint256 _amount,
        address _shareOwner,
        bool isDeducted
    ) public {
        if (isDeducted) {
            require(
                depositors[_shareOwner].shares >= _amount,
                "Not enogh o perform arethmetic"
            );
            depositors[_shareOwner].shares -= _amount;
        } else {
            depositors[_shareOwner].shares += _amount;
        }
    }

    function updateDepositorAssets(
        uint256 _assetAmount,
        uint256 _shareAmount,
        address _user
    ) public {
        require(
            address(msg.sender) == address(_user),
            "Not user only sender can call this !"
        );
        require(
            depositors[_user].shares >= _shareAmount,
            "Not enough shares to withdraw!"
        );
        depositors[_user].shares -= _shareAmount;
        depositors[_user].assets -= _assetAmount;

        //    _deposit -= _withdrawAmount;;
    }

    //_user user performing action
    function splitRewards(uint256 _amount, address _user) internal {
        (, uint256 protocolFeeDeducted, ) = calculateFees(_amount);
        //needs approval first remmember in and out
        vaultAsset.transferFrom(
            msg.sender,
            feeRecievers.protocolFee,
            protocolFeeDeducted
        ); //make sure allowance is set up for user
        if (_user != address(msg.sender)) {
            //creators dont pay there own vaults fees would make no sense
            vaultAsset.transferFrom(
                msg.sender,
                feeRecievers.creatorFee,
                creatorFee
            );
        }
    }

    //this is performed with api synchrounosly
    //callback stragey is params if vualt doesnt have enoguh pass into exit stragey to flush funds
    function withdrawAssets(
        uint256 _shares,
        address receiver,
        bytes memory callBackStrategy
    ) public {
        VaultHelper.DepositorInfo memory _depositor = getDepositorInfo(
            receiver
        );
        require(
            _depositor.shares >= _shares,
            "Not enough shares deposited to withdraw!"
        );
        require(receiver == msg.sender, "Not owner");
        uint256 _total = previewWithdraw(_shares);
        vaultHasWithdraw(_total, callBackStrategy);
        splitRewards(_total, receiver); //splitrewards before paying out
        bool successfulTransfer = vaultAsset.transferFrom(
            //send funds to user when done
            msg.sender,
            address(this),
            _total
        ); //must be approved
        require(
            successfulTransfer,
            "Transfer did not go through check approvals;"
        );
        setSharesOwned(_shares, receiver, true);
        setAssetsDeposited(_total, receiver, true);
        setVolume(receiver, _total);
        emit VaultHelper.VaultWithdraw(
            receiver,
            receiver,
            receiver,
            _total,
            _shares
        );
        // withdraw out of vault to user
    }

    function vaultHasWithdraw(
        uint256 _assetsTotal,
        bytes memory params
    ) public {
        uint256 vaultAssetBalance = vaultAsset.balanceOf(address(this));
        if (vaultAssetBalance < _assetsTotal) {
            exitStrategy(currentStrategyId, _assetsTotal, params);
        }
    }

    function withdrawCrossChainQuote(
        address _user,
        uint256 _shares,
        uint32 _dstEid,
        bytes memory _options
    ) public view returns (MessagingHelper.ComposedMessage memory _quote) {
        uint256 assetsTotal = previewWithdraw(_shares);
        bytes memory _message = abi.encodeWithSignature(
            "payUser(address,uint256)",
            _user,
            assetsTotal
        );
        (MessagingHelper.ComposedMessage memory fee) = messageQuote(
            _dstEid,
            _message,
            _options,
            false,
            _user
        );
        _quote = fee;
    }

    function withdrawCrossChain(
        MessagingHelper.ComposedMessage memory _quote
    ) public payable {
        sendMessage(_quote);
    }

    //must verify asset is bridged before using or executing
    function payUser(address _user, uint256 _amount) public returns (bool) {
        require(address(this).balance > _amount, "Not enough in contract");
        (bool success, ) = payable(_user).call{value: _amount}("");
        require(success != false, "User was not paid");
        return success;
    }

    /*/////////////////////////////////////////////////////////////
                           STRATEGY MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                VIEWS
    //////////////////////////////////////////////////////////////*/

    function messageQuote(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        bool _payLzToken,
        address _refundAddress
    ) public view returns (MessagingHelper.ComposedMessage memory) {
        MessagingFee memory _fee = _quote(
            _dstEid,
            _message,
            _options,
            _payLzToken
        );
        return
            MessagingHelper.ComposedMessage(
                _dstEid,
                _fee,
                _message,
                _options,
                _payLzToken,
                _refundAddress
            );
    }

    function sendMessage(
        MessagingHelper.ComposedMessage memory _msg
    ) public returns (MessagingReceipt memory) {
        MessagingReceipt memory _reciept = _lzSend(
            _msg._dstEid,
            _msg._message,
            _msg._options,
            _msg._fee,
            _msg._refundAddress
        );

        return _reciept;
    }

    //cross chain deposit we call deposit

    function _lzReceive(
        Origin calldata,
        /*_origin*/
        bytes32,
        /*_guid*/
        bytes calldata _message,
        address,
        /*_executor*/
        bytes calldata /*_extraData*/
    ) internal override {
        (uint256 _amount, bytes memory message) = abi.decode(
            _message,
            (uint256, bytes)
        );
        (bool success, ) = address(this).call{value: _amount}(message);
        require(success, "Tx revert executing message");
    }
}

//forge fmt --check for debugging before publishing to github thats why commits filw e dont chekc the code
