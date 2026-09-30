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
    address vaultRegistry;

    //authorized shold only be the registry
    constructor(address _delegate, address _authorized) Ownable(_delegate) {
        currentVaultId = 0;
        authroized = _authorized;
    }

    modifier onlyAUhtorized(address attemptedUser) {
        require(attemptedUser == authroized, "Not authrized to perform ");
        _;
    }
    mapping(uint256 => VaultHelper.Vault) vaultsDeployed;

    function setVault(
        address _vaultRegistry
    ) public onlyAUhtorized(msg.sender) {
        vaultRegistry = _vaultRegistry;
    }

    function setVaultsDeployed(
        uint256 vaultId,
        VaultHelper.Vault memory vaultInfo
    ) public onlyAUhtorized(msg.sender) {
        vaultsDeployed[vaultId] = vaultInfo;
    }

    function deployVault(
        bytes memory deployVaultParams
    )
        public
        onlyAUhtorized(msg.sender)
        returns (uint256 vaultId, IVaultManager vaultDeployed)
    {
        (VaultHelper.VaultDeployParams memory deployParams) = abi.decode(
            deployVaultParams,
            (VaultHelper.VaultDeployParams)
        );
        VaultManager vault = new VaultManager(deployParams);

        vaultDeployed = IVaultManager(address(vault));
        vaultId = currentVaultId;
        address[] memory _vaultAuthorized;
        _vaultAuthorized[0] = deployParams.creator;
        registerVault(deployParams, vaultDeployed, _vaultAuthorized);
    }

    function registerVault(
        VaultHelper.VaultDeployParams memory deployParams,
        IVaultManager vaultDeployed,
        address[] memory _vaultAuthorized
    ) public onlyAUhtorized(msg.sender) {
        setVaultsDeployed(
            currentVaultId,
            VaultHelper.Vault(
                deployParams.creator,
                0,
                0,
                vaultDeployed,
                deployParams.vaultName,
                deployParams.vaultTicker,
                deployParams.vaultAsset,
                _vaultAuthorized
            )
        );

        increaseVaultId();
    }

    function increaseVaultId() public onlyAUhtorized(msg.sender) {
        ++currentVaultId;
    }
    function removePeer() public onlyAUhtorized(msg.sender) {}

    function getvault(
        uint256 vaultId
    )
        public
        view
        onlyAUhtorized(msg.sender)
        returns (VaultHelper.Vault memory vault)
    {
        vault = vaultsDeployed[vaultId];
    }

    function stopVault() public onlyAUhtorized(msg.sender) {}

    //flushes vault and returns funds to users immediatley this happens when vault is paused stopped or any sort of hack
    function SOSVault() public onlyAUhtorized(msg.sender) {}
}
// initializeVault()
// configureVault()
// validateDeployParams()
//migrate these fucntions from registry tosave space wont deploy cuz of space
