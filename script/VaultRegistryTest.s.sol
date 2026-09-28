// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {TokenDeployer} from "../src/TokenDeployer.sol";
import {VaultRegistry} from "../src/VaultRegistry.sol";

//flow deploy on both chains first -> add peers for each other on both chains addPeer()
//simulate a once chain vault simulateHubVaultDeployment() -> (deploy multichain vaults is if hub deployment works) ->
//getMultichainDeployQuote() ->
contract VaultRegistryTest is Test {
    VaultRegistry registry;
    address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;

    address delegate = msg.sender;
    address[] authorizedVip = [msg.sender];
    string vaultName = "MicroStrategy";
    string vaultTIcker = "MSTR";
    IERC20 vaultAsset;
    VaultAssets.FeesInfo fees;
    VaultAssets.feeReceiversInfo feeRecievers;
    constructor() {}

    function setUp() public {}

    //before doing anytthign we must deploy on multiple chains first
    function run() public {
        vm.startBroadcast();

        deployRegistry(endpoint, delegate);

        vm.stopBroadcast();
    }

    //deploy on two chains
    function deployRegistry(address _endpoint, address _delegate) public {
        registry = new VaultRegistry(_endpoint, _delegate);
    }

    function addPeer(uint32 eid, address vault) public {
        registry.addRegistryPeer(eid, vault);
    }

    //simulate multichain vault
    function simulateHubVaultDeployment() public {
        VaultHelper.VaultDeployParams memory deployParams = generateeConstructorParams();
        bytes memory params = abi.encode(deployParams); //constructor params
        uint256 deployedVaultId = registry.deployHubVault(params);
        getVaultInfo(deployedVaultId);
    }

    function generateeConstructorParams() public view returns (VaultHelper.VaultDeployParams memory vaultDeployParams) {
        vaultDeployParams = VaultHelper.VaultDeployParams(
            msg.sender, authorizedVip, vaultName, vaultTIcker, vaultAsset, msg.sender, endpoint, fees, feeRecievers
        );
    }

    // (
    //         address deployer,
    //         address[] memory _authorizedVip,
    //         string memory vaultName,
    //         string memory vaultTicker,
    //         IERC20 _vaultAsset,
    //         address _creator,
    //         address vaultEndpoint,
    //         VaultAssets.FeesInfo memory _fees,
    //         VaultAssets.feeReceiversInfo memory _feeRecievers
    //     )
    function getMultichainDeployQuote(bytes[] memory messages, uint32[] memory dstEids)
        public
        view
        returns (VaultHelper.BulkVaultDeployments[] memory quotes)
    {
        quotes = registry.getMultiChainDpeloymentQuote(msg.sender, messages, dstEids);
    }

    function simulateRegistryDeposit(uint256 vaultId, address _user, uint256 _amountAssets) public {
        registry.deposit(_user, vaultId, _amountAssets, _user);
    }

    function getUserInfo() public view {}

    function getVaultInfo(uint256 _vaultId) public view returns (VaultHelper.Vault memory info) {
        info = registry.getVault(_vaultId);

        console.log("creator:", info.creator);
        console.log("tvl:", info.tvl);
        console.log("allTimeVolume:", info.allTimeVolume);
        console.log("vault:", address(info.vault));
        console.log("name:", info.name);
        console.log("ticker:", info.ticker);
        console.log("depositAsset:", address(info.depositAsset));
    }

    //must quote first beofre peroforming
    function simulateRegistryWithdraw(uint256 vaultId, uint256 shares, address receiver) public {
        registry.vaultWithdraw(vaultId, shares, receiver);
    }
}
