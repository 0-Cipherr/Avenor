// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

import {VaultHelper} from "./VaultHelper.sol";

interface IVaultRegistry {
    function setMessengerAddr() external;

    function handleMessage() external;

    function deployHubVault(bytes calldata deployParamsEncoded) external returns (uint256 vaultId);

    function deployMultiChainVault(VaultHelper.BulkVaultDeployments[] calldata deploymentQuotes) external;

    function textRegistry(uint32 dstEid, bytes calldata message, MessagingFee calldata fee, address refundAddress)
        external
        payable;

    function getMultiChainDpeloymentQuote(address user, bytes[] calldata messages, uint32[] calldata dstEids)
        external
        view
        returns (VaultHelper.BulkVaultDeployments[] memory deployments);

    function verifyPeerExistence() external;

    function getMessageQuote(uint32 dstEid, bytes calldata message) external view returns (MessagingFee memory fee);

    function addressToBytes32(address addr) external pure returns (bytes32);

    function addRegistryPeer(uint32 eid, address registry) external;

    function deposit(address user, uint256 vaultId, uint256 amountAssets, address depositor)
        external
        payable
        returns (uint256 sharesSent);

    function verifyAssetAllownce(uint256 vaultId, address user, uint256 amount) external view;

    function assetBalanceCheck(IERC20 asset, uint256 amountNeeded, address caller) external view;

    function vaultWithdraw(uint256 vaultId, uint256 shares, address receiver) external;

    function verifyOnlyCaller(address caller) external view;
}
