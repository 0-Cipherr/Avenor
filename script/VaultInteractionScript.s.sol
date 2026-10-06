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
import {IStrategyAdapter} from "../src/IStrategyAdapter.sol";
contract VaultInteractionScript is Script {
    VaultRegistry registry;
    function run() external {
        vm.startBroadcast();

        // deployment code here
        setUp();

        vm.stopBroadcast();
    }

    function setUp() public {
        testDeployRegistry();
    }

    function testDeployRegistry() public {
        address _delegate = msg.sender;
        address _endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        uint32 _endpointId = block.chainid == 84532 ? 40245 : 40231;
        StrategyAdapter strategyAdapter = deployStrategyAdapter(msg.sender);
        IVaultFactory _factory = deployFacotry(msg.sender, strategyAdapter);
        IVaultRegistryMessenger _messenger = deployMessenger(
            _endpoint,
            msg.sender
        );

        deployRegistry(_delegate, _endpoint, _endpointId, _factory, _messenger);

        testDeployRegistryOutput(_factory, _messenger, strategyAdapter);
    }
    function testDeployRegistryOutput(
        IVaultFactory factory,
        IVaultRegistryMessenger messenger,
        StrategyAdapter adapter
    ) public pure {
        console.log("STEP ONE: Strategy Adapter deployed: ");
        console.logAddress(address(adapter));
        console.log("STEP TWO: Facotry Deployed: ");
        console.log(address(factory));
        console.log("STEP THREE: Messenger Deployed: ");
        console.log(address(messenger));
    }
    function deployStrategyAdapter(
        address _delegate
    ) public returns (StrategyAdapter adapter) {
        adapter = new StrategyAdapter(_delegate);
    }
    function deployFacotry(
        address _authorized,
        StrategyAdapter adapter
    ) public returns (IVaultFactory factory) {
        factory = IVaultFactory(
            address(
                new VaultFactory(
                    _authorized,
                    IStrategyAdapter(address(adapter))
                )
            )
        );
    }

    function deployMessenger(
        address endpoint,
        address delegate
    ) public returns (IVaultRegistryMessenger messenger) {
        messenger = IVaultRegistryMessenger(
            address(new VaultRegistryMessenger(endpoint, delegate))
        );
    }

    function deployRegistry(
        address _delegate,
        address _endpoint,
        uint32 _endpointId,
        IVaultFactory _factory,
        IVaultRegistryMessenger _messenger
    ) public {
        registry = new VaultRegistry(
            _delegate,
            _endpoint,
            _endpointId,
            _delegate,
            _factory,
            _messenger
        );
    }
}
