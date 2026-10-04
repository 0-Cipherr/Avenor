// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVaultManager} from "./IVaultManager.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {IStrategyAdapter} from "./IStrategyAdapter.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract VaultFactory is Clones {
    //accounting hld in the manager
    uint256 currentVaultId;
    address authroized;
    address vaultRegistry;
    uint256 changeOwnerMax = 3;
    IStrategyAdapter strategyAdapter;
    address private vaultImplementation;

    mapping(address => uint256) changeOwnerChances;
    mapping(uint256 => VaultHelper.Vault) vaultsDeployed;

    //authorized shold only be the registry
    constructor(address _authorized, IStrategyAdapter _strategyAdapter) {
        currentVaultId = 0;
        authroized = _authorized;
        strategyAdapter = _strategyAdapter;
    }

    modifier onlyAUhtorized(address attemptedUser) {
        require(attemptedUser == authroized, "Not authrized to perform ");
        _;
    }

    function setVault(address _vaultRegistry) public onlyAUhtorized(msg.sender) {
        vaultRegistry = _vaultRegistry;
    }

    function setVaultsDeployed(uint256 vaultId, VaultHelper.Vault memory vaultInfo) public onlyAUhtorized(msg.sender) {
        vaultsDeployed[vaultId] = vaultInfo;
    }

    //all thats left to fix

    //set implementation use initalize() to st variables

    /////////////////////////////////////////////
    //IMPORTANT FLOW TO DPELO CONTRACTS
    //SET IMPLEMENTATION FIRST
    //CLONE WITH IMPLEMENTATION

    // CLL INTIALIZE IN VAULT TO SET CONSTRUCTOR PARAMS >. PLEASE NOT_e VAULT SHOULD NOT HAVE CONSTRUCTOR PARAMS
    function setVaultImplemntation(address implementation) public onlyAUhtorized(msg.sender) {
        vaultImplementation = implementation;
    }

    function cloneVaultImplementation() public returns (address) {
        address clonedImplementation = clone(vaultImplementation);
        return clonedImplementation;
    }

    function initalizeVault(address implementation, bytes memory initializeParams) public {
        IVaultManager vault = IVaultManager(implementation);
        vault.initialize(initializeParams);
    }

    function deployVault(bytes memory deployVaultParams) public returns (uint256 vaultId, IVaultManager vaultDeployed) {
        VaultHelper.VaultDeployParams memory deployParams =
            abi.decode(deployVaultParams, (VaultHelper.VaultDeployParams));

        address vault = Clones.clone(address((vaultImplementation)));

        VaultManager(vault).initialize(deployParams, strategyAdapter);

        vaultDeployed = IVaultManager(vault);
        vaultId = currentVaultId;

        address[] memory vaultAuthorized = new address[](1);
        vaultAuthorized[0] = deployParams.creator;

        registerVault(deployParams, vaultDeployed, vaultAuthorized);
    }

    ///////////////////////////////////

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

    function getvault(uint256 vaultId) public view onlyAUhtorized(msg.sender) returns (VaultHelper.Vault memory vault) {
        vault = vaultsDeployed[vaultId];
    }

    function verifyChances(address _owner) public view onlyAUhtorized(msg.sender) {
        uint256 chance = getOwnerChangeChances(_owner);
        require(chance < changeOwnerMax, "You ran out of vault owner canges ");
    } //emergency use case one time use

    function changeVaultOwner(uint256 vaultId) public onlyAUhtorized(msg.sender) {
        VaultHelper.Vault memory userVault = vaultsDeployed[vaultId];
        incrementChangeOwnerChances(userVault.creator);
    }

    function getOwnerChangeChances(address _owner) public view onlyAUhtorized(msg.sender) returns (uint256) {
        return changeOwnerChances[_owner];
    }

    function incrementChangeOwnerChances(address _owner) public onlyAUhtorized(msg.sender) {
        changeOwnerChances[_owner] += 1;
    }

    function getVaultTotalAssets(uint256 vaultId) public {}
}
// initializeVault()
// configureVault()
// validateDeployParams()
//migrate these fucntions from registry tosave space wont deploy cuz of space
