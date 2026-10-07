// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVaultManager} from "./IVaultManager.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {IStrategyAdapter} from "./IStrategyAdapter.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract VaultFactory {
    //accounting hld in the manager
    uint256 currentVaultId;
    address authroized;
    address vaultRegistry;
    uint256 changeOwnerMax = 3;
    IStrategyAdapter strategyAdapter;
    address public immutable vaultImplementation;
    address vaultManager;

    mapping(address => uint256) changeOwnerChances;
    mapping(uint256 => VaultHelper.Vault) vaultsDeployed;
    mapping(uint256 => address) vaultAddress;
    //authorized shold only be the registry
    constructor(
        address _authorized,
        IStrategyAdapter _strategyAdapter,
        address _vaultImplementaiton
    ) {
        currentVaultId = 0;
        authroized = _authorized;
        strategyAdapter = _strategyAdapter;
        vaultImplementation = _vaultImplementaiton;
    }

    modifier onlyAUhtorized(address attemptedUser) {
        require(
            attemptedUser == authroized || attemptedUser == vaultRegistry,
            "Not authrized to perform "
        );
        _;
    }

    function setVaultAddress(uint256 vaultId, address vault) public {
        vaultAddress[vaultId] = vault;
    }

    function getVaultAddress(uint256 vaultId) public view returns (address) {
        return vaultAddress[vaultId];
    }

    function setVault(address _vaultRegistry) public {
        vaultRegistry = _vaultRegistry;
    }

    function verifyVault(uint256 vaultId) public view returns (bool isValid) {
        for (uint256 i = 0; i < currentVaultId; i++) {
            bool isVaultInitiated = vaultsDeployed[i].creator == address(0);
            if (isVaultInitiated == false && currentVaultId == i) {
                isValid = false;
            } else if (isVaultInitiated == true && vaultId == i) {
                isValid = true;
            }
        }
    }

    function setVaultsDeployed(
        uint256 vaultId,
        VaultHelper.Vault memory vaultInfo
    ) public onlyAUhtorized(msg.sender) {
        vaultsDeployed[vaultId] = vaultInfo;
    }

    function setStrategyId(
        uint256 vaultId,
        uint256 strategyId,
        bytes memory depositCallback
    ) public {
        vaultsDeployed[vaultId].vault.setStrategy(strategyId, depositCallback);
        //witdraw fromcurrent deposits into next
    }

    function deposit(uint256 vaultId, uint256 assets, address receiver) public {
        vaultsDeployed[vaultId].vault.depositAssets(assets, receiver);
    }

    function withdraw(
        uint256 vaultId,
        uint256 _shares,
        address receiver,
        bytes calldata callBackStrategy
    ) public {
        vaultsDeployed[vaultId].vault.withdrawAssets(
            _shares,
            receiver,
            callBackStrategy
        );
    }

    function deployVault(
        bytes memory deployVaultParams
    ) public returns (uint256 vaultId, IVaultManager vaultDeployed) {
        VaultHelper.VaultDeployParams memory deployParams = abi.decode(
            deployVaultParams,
            (VaultHelper.VaultDeployParams)
        );
        // /eip1167 impelementation upgradable contract save space
        //good standard for factories

        address vault = Clones.clone(address((vaultImplementation)));

        VaultManager(payable(vault)).__initialize_vault_(
            deployParams,
            strategyAdapter
        );
        (deployParams, strategyAdapter);

        vaultDeployed = IVaultManager(vault);
        vaultId = currentVaultId;

        address[] memory vaultAuthorized = new address[](1);
        vaultAuthorized[0] = deployParams.creator;

        registerVault(deployParams, vaultDeployed, vaultAuthorized);
    }

    function registerVault(
        VaultHelper.VaultDeployParams memory deployParams,
        IVaultManager vaultDeployed,
        address[] memory _vaultAuthorized
    ) public onlyAUhtorized(msg.sender) {
        setVaultsDeployed(
            currentVaultId,
            VaultHelper.Vault(
                deployParams.creator, //creator
                0, //tvl
                0, //alltimevolume
                vaultDeployed, //vault deployed
                deployParams.vaultName, //vault name
                deployParams.vaultTicker, //vault ticker
                deployParams.vaultAsset, //vaultAsset
                _vaultAuthorized // authorized users of the vault
            )
        );

        increaseVaultId(); // upthe vualt id evety time
    }

    function increaseVaultId() public onlyAUhtorized(msg.sender) {
        ++currentVaultId;
    }

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

    function verifyChances(
        address _owner
    ) public view onlyAUhtorized(msg.sender) {
        uint256 chance = getOwnerChangeChances(_owner);
        require(chance < changeOwnerMax, "You ran out of vault owner canges ");
    } //emergency use case one time use

    function changeVaultOwner(
        uint256 vaultId
    ) public onlyAUhtorized(msg.sender) {
        VaultHelper.Vault memory userVault = vaultsDeployed[vaultId];
        incrementChangeOwnerChances(userVault.creator);
    }

    function getOwnerChangeChances(
        address _owner
    ) public view onlyAUhtorized(msg.sender) returns (uint256) {
        return changeOwnerChances[_owner];
    }

    function incrementChangeOwnerChances(
        address _owner
    ) public onlyAUhtorized(msg.sender) {
        changeOwnerChances[_owner] += 1;
    }

    function getVaultTotalAssets(uint256 vaultId) public {}
}
// initializeVault()
// configureVault()
// validateDeployParams()
//migrate these fucntions from registry tosave space wont deploy cuz of space
