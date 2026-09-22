// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {MessagingReceipt} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

interface IVaultManager {
    // -------------------------------------------------------------------------
    // Views
    // -------------------------------------------------------------------------

    function getDepositor(address user) external view returns (VaultHelper.DepositorInfo memory);

    function getAsset() external view returns (IERC20);

    function getCreator() external view returns (address);

    function getAuthorizer(uint256 index) external view returns (address);

    function hasDeposited(address user) external view returns (bool);

    function messageQuote(
        uint32 dstEid,
        bytes calldata message,
        bytes calldata options,
        bool payLzToken,
        address refundAddress
    ) external view returns (MessagingHelper.ComposedMessage memory);

    function withdrawCrossChainQuote(address user, uint256 shares, uint32 dstEid, bytes calldata options)
        external
        view
        returns (MessagingHelper.ComposedMessage memory);

    // -------------------------------------------------------------------------
    // Authorizer / access management
    // -------------------------------------------------------------------------

    function setPeer(uint32 eid, address peer) external;

    function setAuthorizer(address authorized) external;

    // -------------------------------------------------------------------------
    // Depositor management
    // -------------------------------------------------------------------------

    function createDepositor(address depositor, VaultHelper.DepositorInfo calldata info) external;

    function setAssetsDeposited(uint256 amount, address assetOwner, bool isDeducted) external;

    function setVolume(address user, uint256 newVolume) external;

    function setSharesOwned(uint256 amount, address shareOwner, bool isDeducted) external;

    function updateDepositorAssets(uint256 assetAmount, uint256 shareAmount, address user) external;

    // -------------------------------------------------------------------------
    // Deposits / withdrawals
    // -------------------------------------------------------------------------

    function depositAssets(uint256 assets, address receiver) external returns (uint256 shares);

    function crossChainDeposit(uint32 dstEid, uint256 assets, address receiver) external;

    function withdrawAssets(uint256 shares, address receiver) external;

    function withdrawCrossChain(MessagingHelper.ComposedMessage calldata quote) external payable;

    // -------------------------------------------------------------------------
    // Messaging
    // -------------------------------------------------------------------------

    function sendMessage(MessagingHelper.ComposedMessage calldata message) external returns (MessagingReceipt memory);

    // -------------------------------------------------------------------------
    // Cross-chain execution
    // -------------------------------------------------------------------------

    function payUser(address user, uint256 amount) external returns (bool);

    // -------------------------------------------------------------------------
    // ETH
    // -------------------------------------------------------------------------

    receive() external payable;
}
