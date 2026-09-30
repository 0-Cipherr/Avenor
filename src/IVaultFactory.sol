// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IVaultManager} from "./IVaultManager.sol";
import {VaultHelper} from "../src/VaultHelper.sol";

interface IVaultFactory {
    function setVault(address _vaultRegistry) external;

    function setVaultsDeployed(uint256 vaultId, VaultHelper.Vault memory vaultInfo) external;

    function deployVault(bytes memory deployVaultParams) external returns (uint256 vaultId, IVaultManager vaultDeployed);

    function registerVault(
        VaultHelper.VaultDeployParams memory deployParams,
        IVaultManager vaultDeployed,
        address[] memory _vaultAuthorized
    ) external;

    function increaseVaultId() external;

    function getvault(uint256 vaultId) external view returns (VaultHelper.Vault memory vault);

    function verifyChances(address _owner) external;

    function changeVaultOwner(uint256 vaultId) external;

    function getOwnerChangeChances(address _owner) external view returns (uint256);

    function incrementChangeOwnerChances(address _owner) external;
}
