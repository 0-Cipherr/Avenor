// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {MessagingReceipt} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";

interface IVaultManager {
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    struct feeReceiversInfo {
        address protocolFee;
        address creatorFee;
    }

    struct FeesInfo {
        uint256 _creatorFee;
        uint256 _protocolFee;
    }

    struct Status {
        bool strategyActive;
        uint32 endpointId;
        address endpoint;
        uint256 strategyId;
    }

    /*//////////////////////////////////////////////////////////////
                            VAULT ASSETS
    //////////////////////////////////////////////////////////////*/

    function getFeeRecievers() external view returns (feeReceiversInfo memory);

    function getFees() external view returns (FeesInfo memory);

    function getTotalAssets() external view returns (uint256);

    function getIdleAssets() external view returns (uint256);

    function mintShares(uint256 amount, address minter) external;

    function burnTokens(uint256 amount, address burner) external;

    function calculateFees(uint256 amount)
        external
        view
        returns (uint256 total, uint256 protocolFeeDeducted, uint256 creatorFeeDeducted);

    function convertToShares(uint256 assets) external view returns (uint256 shares);

    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    function getSharePrice() external view returns (uint256);

    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    function calculateBurn(uint256 assets) external view returns (uint256 shares);

    function calculateReedem(uint256 shares) external view returns (uint256 redeemable);

    function previewWithdraw(uint256 shares) external view returns (uint256 assets);

    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    function verifyAssetApproval(address user, uint256 amount) external view returns (bool);

    /*//////////////////////////////////////////////////////////////
                            VAULT MANAGER
    //////////////////////////////////////////////////////////////*/

    function getDepositor(address user) external view returns (VaultHelper.DepositorInfo memory);

    function setPeer(uint32 eid, address peer) external;

    function getAsset() external view returns (IERC20);

    function getCreator() external view returns (address);

    function getAuthorizer(uint256 index) external view returns (address);

    function setAuthorizer(address authorized) external;

    function createDepositor(address depositor, VaultHelper.DepositorInfo memory info) external;

    function crossChainDeposit(uint32 dstEid, uint256 assets, address receiver) external;

    function depositAssets(uint256 assets, address receiver) external returns (uint256 shares);

    function hasDeposited(address user) external view returns (bool);

    function setAssetsDeposited(uint256 amount, address assetOwner, bool isDeducted) external;

    function setVolume(address user, uint256 newVolume) external;

    function setSharesOwned(uint256 amount, address shareOwner, bool isDeducted) external;

    function updateDepositorAssets(uint256 assetAmount, uint256 shareAmount, address user) external;

    function withdrawAssets(uint256 shares, address receiver) external;

    /*//////////////////////////////////////////////////////////////
                        CROSS-CHAIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function withdrawCrossChainQuote(address user, uint256 shares, uint32 dstEid, bytes memory options)
        external
        view
        returns (MessagingHelper.ComposedMessage memory quote);

    function withdrawCrossChain(MessagingHelper.ComposedMessage memory quote) external payable;

    function payUser(address user, uint256 amount) external returns (bool);

    function messageQuote(
        uint32 dstEid,
        bytes memory message,
        bytes memory options,
        bool payLzToken,
        address refundAddress
    ) external view returns (MessagingHelper.ComposedMessage memory);

    function sendMessage(MessagingHelper.ComposedMessage memory message) external returns (MessagingReceipt memory);

    /*//////////////////////////////////////////////////////////////
                        STRATEGY MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    function getStrategies() external view returns (address[] memory);

    function getStrategyPosition() external view returns (VaultHelper.StrategyPosition memory);

    function setPosition(VaultHelper.StrategyPosition memory positionInfo) external;

    function addStrategy(address strategy) external;

    function removeStrategy(address strategy) external;

    function deployCapital(address strategy, uint256 assets, bytes calldata data)
        external
        returns (uint256 assetsDeployed);

    function withdrawCapital(address strategy, uint256 assets, bytes calldata data)
        external
        returns (uint256 assetsReturned);

    function harvest(address strategy, bytes calldata data)
        external
        returns (uint256 currentAssets, int256 profitOrLoss);

    function flush(address receiver) external;
}
