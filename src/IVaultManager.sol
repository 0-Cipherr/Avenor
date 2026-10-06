// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {IStrategyAdapter} from "./IStrategyAdapter.sol";

import {
    MessagingReceipt
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

interface IVaultManager {
    // =============================================================
    //                           STRUCTS
    // =============================================================

    struct Status {
        bool strategyActive;
        uint32 endpointId;
        address endpoint;
        uint256 strategyId;
    }

    // =============================================================
    //                         INITIALIZATION
    // =============================================================

    function __initialize_vault_(
        VaultHelper.VaultDeployParams calldata _deployParams,
        IStrategyAdapter _strategyAdapter
    ) external;

    // =============================================================
    //                       DEPOSITOR INFO
    // =============================================================

    function getDepositorInfo(
        address _user
    ) external view returns (VaultHelper.DepositorInfo memory);

    function hasDeposited(address _user) external view returns (bool);

    function createDepositor(
        address _depositor,
        VaultHelper.DepositorInfo calldata _info
    ) external;

    function setAssetsDeposited(
        uint256 _amount,
        address _assetOwner,
        bool isDeducted
    ) external;

    function setVolume(address _user, uint256 _newVolume) external;

    function setSharesOwned(
        uint256 _amount,
        address _shareOwner,
        bool isDeducted
    ) external;

    function updateDepositorAssets(
        uint256 _assetAmount,
        uint256 _shareAmount,
        address _user
    ) external;

    // =============================================================
    //                         VAULT INFO
    // =============================================================

    function getAsset() external view returns (IERC20);

    function getCreator() external view returns (address);

    function getAuthorizer(uint256 index) external view returns (address);

    function setAuthorizer(address authorized) external;

    // =============================================================
    //                         STRATEGY
    // =============================================================

    function setStrategy(
        uint256 strategyId,
        bytes memory depositCallback
    ) external;

    function enterStrategy(
        address _user,
        uint256 strategyId,
        uint256 assets,
        bytes calldata params
    ) external;

    function activateStrategy(uint256 strategyId) external;

    function deactivateStrategy() external;

    function exitStrategy(
        uint256 strategyId,
        uint256 assets,
        bytes calldata params
    ) external;

    function emergencyExit(uint256 strategyId, bytes calldata params) external;

    function checkStrategyCurrent(
        address _user,
        uint256 strategyId,
        uint256 assets,
        bytes calldata params
    ) external;

    function getStrategyInfo(
        uint256 _vaultId
    ) external view returns (VaultHelper.StrategyInfo memory);

    function vaultHasWithdraw(
        uint256 _assetsTotal,
        bytes calldata params
    ) external;

    // =============================================================
    //                           DEPOSITS
    // =============================================================

    function depositAssets(
        uint256 assets,
        address receiver
    ) external returns (uint256 shares);

    function crossChainDeposit(
        uint32 _dstEid,
        uint256 assets,
        address receiver
    ) external;

    // =============================================================
    //                         WITHDRAWALS
    // =============================================================

    function withdrawAssets(
        uint256 _shares,
        address receiver,
        bytes calldata callBackStrategy
    ) external;

    function withdrawCrossChainQuote(
        address _user,
        uint256 _shares,
        uint32 _dstEid,
        bytes calldata _options
    ) external view returns (MessagingHelper.ComposedMessage memory);

    function withdrawCrossChain(
        MessagingHelper.ComposedMessage calldata _quote
    ) external payable;

    function payUser(address _user, uint256 _amount) external returns (bool);

    // =============================================================
    //                       LAYERZERO
    // =============================================================

    function setPeer(uint32 _eid, address _peer) external;

    function messageQuote(
        uint32 _dstEid,
        bytes calldata _message,
        bytes calldata _options,
        bool _payLzToken,
        address _refundAddress
    ) external view returns (MessagingHelper.ComposedMessage memory);

    function sendMessage(
        MessagingHelper.ComposedMessage calldata _msg
    ) external returns (MessagingReceipt memory);
}
