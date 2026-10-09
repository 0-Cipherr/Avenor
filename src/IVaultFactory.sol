// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {VaultHelper} from "./VaultHelper.sol";
import {IVaultManager} from "./IVaultManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVaultFactory {
    // Custom Errors
    error NotApproved(uint256 amount, uint256 vaultId);

    // State Configuration & System Functions
    function setVaultImplementation(address vault) external;
    function setVaultAddress(uint256 vaultId, address vault) external;
    function getVaultAddress(uint256 vaultId) external view returns (address);
    function setVault(address _vaultRegistry) external;
    function verifyVault(uint256 vaultId) external view returns (bool isValid);

    // Authorization & Registry Helpers
    function setVaultsDeployed(uint256 vaultId, VaultHelper.Vault calldata vaultInfo) external;

    function increaseVaultId() external;
    function getvault(uint256 vaultId) external view returns (VaultHelper.Vault memory vault);

    // Vault Configuration & Strategy Management
    function setStrategyId(uint256 vaultId, uint256 strategyId, bytes calldata depositCallback) external;

    function updateVaultTVL(uint256 vaultId, uint256 value, bool isDeduction) external;

    function updateVaultallTimeVolume(uint256 vaultId, uint256 amount) external;

    function updateAuthorized(uint256 vaultId, address user, bool shouldAppend) external;

    // Asset Management & Token Mechanics
    function approveVault(uint256 vaultId, IERC20 asset, uint256 _amount) external;
    function approveVault(uint256 vaultId, uint256 _amount) external;

    function transferFromRegistry(IERC20 asset, address _from, address _to, uint256 _amount) external;

    function isApproved(IERC20 _asset, address _owner, address _spender, uint256 _amount) external view returns (bool);

    // Core Interaction Mechanics
    function deposit(uint256 vaultId, uint256 assets, address receiver) external;

    function withdraw(uint256 vaultId, uint256 _shares, address receiver, bytes calldata callBackStrategy) external;

    // Deployment & Registration Lifecycle
    function deployVault(bytes calldata deployVaultParams)
        external
        returns (uint256 vaultId, IVaultManager vaultDeployed);

    function registerVault(
        VaultHelper.VaultDeployParams calldata deployParams,
        IVaultManager vaultDeployed,
        address[] calldata _vaultAuthorized
    ) external;

    // Emergency Owner Administration
    function verifyChances(address _owner) external view;
    function changeVaultOwner(uint256 vaultId) external;
    function getOwnerChangeChances(address _owner) external view returns (uint256);
    function incrementChangeOwnerChances(address _owner) external;

    // Placeholders
    function getVaultTotalAssets(uint256 vaultId) external;
}
