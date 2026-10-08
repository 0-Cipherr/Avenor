// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {VaultHelper} from "./VaultHelper.sol";
import {IVaultManager} from "./IVaultManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVaultFactory {
    function setVault(address _vaultRegistry) external;

    function verifyVault(uint256 vaultId) external view returns (bool isValid);

    function setVaultsDeployed(
        uint256 vaultId,
        VaultHelper.Vault memory vaultInfo
    ) external;

    function enterStrategy(
        uint256 vaultId,
        address _user,
        uint256 strategyId,
        uint256 assets,
        bytes memory params
    ) external;

    function exitStrategy(
        uint256 vaultId,
        uint256 strategyId,
        uint256 assets,
        bytes memory params
    ) external;

    function deployVaultImplementation(address endpoint) external;

    function deployVault(
        bytes memory deployVaultParams
    ) external returns (uint256 vaultId, IVaultManager vaultDeployed);

    function registerVault(
        VaultHelper.VaultDeployParams memory deployParams,
        IVaultManager vaultDeployed,
        address[] memory _vaultAuthorized
    ) external;

    function increaseVaultId() external;

    function getvault(
        uint256 vaultId
    ) external view returns (VaultHelper.Vault memory vault);

    function verifyChances(address _owner) external view;

    function changeVaultOwner(uint256 vaultId) external;

    function getOwnerChangeChances(
        address _owner
    ) external view returns (uint256);

    function incrementChangeOwnerChances(address _owner) external;

    function getVaultTotalAssets(
        uint256 vaultId
    ) external view returns (uint256);

    function deposit(
        uint256 vaultId,
        uint256 assets,
        address reciever
    ) external;

    function withdraw() external;
    function getVaultAddress(uint256 vaultId) external view returns (address);
    function setVaultImplementation(address implementation) external;
    function approveVault(
        uint256 vaultId,
        IERC20 asset,
        uint256 _amount
    ) external;
}
