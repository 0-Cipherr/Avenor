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

contract VaultRegistryTest is Test {
    VaultRegistry registry;
    constructor() {}

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;

        address delegate = msg.sender;
        deployRegistry(endpoint, delegate);

        vm.stopBroadcast();
    }

    //deploy on two chains
    function deployRegistry(address _endpoint, address _delegate) public {
        registry = new VaultRegistry(_endpoint, _delegate);
    }

    function addPeer(address endopoint, bytes32 vault) public {}

    //simulate multichain vault
    function simulateHubVaultDeployment() public {
        bytes memory params = abi.encode(""); //constructor params
        registry.deployHubVault(params);
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
    function getMultichainDpeloyQuote(bytes[] memory messages, uint32[] memory dstEids)
        public
        returns (VaultHelper.BulkVaultDeployments[] memory quotes)
    {
        quotes = registry.getMultiChainDpeloymentQuote(msg.sender, messages, dstEids);
    }

    function simulateRegistrDeposit(uint256 vaultId, address _user, uint256 _amountAssets) public {
        registry.deposit(_user, vaultId, _amountAssets, _user);
    }

    function getUserInfo() public view {}

    function getVaultInfo() public view {}

    //must quote first beofre peroforming
    function simulateRegistryWithdraw(uint256 vaultId, uint256 shares, address reciever) public {
        registry.vaultWithdraw(vaultId, shares, reciever);
    }
}
