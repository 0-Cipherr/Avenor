// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {VaultRegistry} from "../src/VaultRegistry.sol";

import {Script} from "forge-std/Script.sol";
import {IVaultFactory} from "../src/IVaultFactory.sol";
import {IVaultRegistryMessenger} from "../src/IVaultRegistryMessenger.sol";
import {VaultFactory} from "../src/VaultFacotry.sol";
import {VaultRegistryMessenger} from "../src/VaultRegistryMessenger.sol";
import {StrategyAdapter} from "../src/StrategyAdapter.sol";
contract Deploy is Script {
    VaultRegistry registry;
    function run() external {
        vm.startBroadcast();

        // deployment code here

        vm.stopBroadcast();
    }

    function setUp() public {
        deployRegistry();
    }

    function deployRegistry() public {
        address _delegate;
        address _endpoint;
        uint32 _endpointId;
        address _authorized;
        StrategyAdapter strategyAdapter = deployStrategyAdapter();
        IVaultFactory _factory = deployFacotry(msg.sender, strategyAdapter);
        IVaultRegistryMessenger _messenger = deployMessenger(
            _endpoint,
            msg.sender
        );
    }

    function deployStrategyAdapter() public returns (StrategyAdapter adapter) {
        adapeter = new StrategyAdapter(msg.sender);
    }
    function deployFacotry(
        address _authorized,
        StrategyAdapter adapter
    ) public returns (IVaultFactory factory) {
        factor = IVaultFactory(new VaultFactory(msg.sender, adapter));
    }

    function deployMessenger(
        address endpoint,
        address delegate
    ) public returns (IVaultRegistryMessenger messenger) {
        messenger = IVaultRegistryMessenger(
            new VaultRegistryMessenger(endpoint, msg.sender)
        );
    }

    function deployRegistry() public {}
}
