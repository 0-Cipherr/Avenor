// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVaultManager} from "./IVaultManager.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {VaultHelper} from "../src/VaultHelper.sol";

contract VaultFactory is Ownable {
    //accounting hld in the manager
    uint256 currentVaultId;
    address authroized;

    constructor(address _delegate, address _authorized) Ownable(_delegate) {
        currentVaultId = 0;
        authroized = _authorized;
    }

    function deployVault(bytes memory deployVaultParams) public returns (uint256 vaultId, IVaultManager vaultDeployed) {
        (VaultHelper.VaultDeployParams memory deployParams) =
            abi.decode(deployVaultParams, (VaultHelper.VaultDeployParams));
        VaultManager vault = new VaultManager(deployParams);

        vaultDeployed = IVaultManager(address(vault));
        vaultId = currentVaultId;
        ++vaultId;
    }

    function addVaultPeer() public {}

    function registerVault() public {}

    function removePeer() public {}

    function getvault() public {}

    function stopVault() public {}
}
// initializeVault()
// configureVault()
// validateDeployParams()
//migrate these fucntions from registry tosave space wont deploy cuz of space
