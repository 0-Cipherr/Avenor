// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {VaultRegistry} from "../src/VaultRegistry.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Script} from "forge-std/Script.sol";
import {IVaultFactory} from "../src/IVaultFactory.sol";
import {IVaultRegistryMessenger} from "../src/IVaultRegistryMessenger.sol";
import {VaultFactory} from "../src/VaultFacotry.sol";
import {VaultRegistryMessenger} from "../src/VaultRegistryMessenger.sol";
import {StrategyAdapter} from "../src/StrategyAdapter.sol";
import {IStrategyAdapter} from "../src/IStrategyAdapter.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {VaultAssets} from "./";

contract VaultInteractionScript is Script {
    VaultRegistry registry;
    address _enpoint;
    uint32 _endpointId;

    function run() external {
        vm.startBroadcast();

        // deployment code here
        setUp();

        vm.stopBroadcast();
    }

    function setUp() public {
        (StrategyAdapter strategyAdapter, IVaultFactory _factory, IVaultRegistryMessenger _messenger) =
            testDeployRegistry();
        testVaultCreationNative(strategyAdapter, _factory, _messenger);
    }

    function testDeployRegistry()
        public
        returns (StrategyAdapter strategyAdapter, IVaultFactory _factory, IVaultRegistryMessenger _messenger)
    {
        address _delegate = msg.sender;
        _endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        _endpointId = block.chainid == 84532 ? 40245 : 40231;
        strategyAdapter = deployStrategyAdapter(msg.sender);
        _factory = deployFacotry(msg.sender, strategyAdapter);
        _messenger = deployMessenger(_endpoint, msg.sender);
        address[] memory authorized;
        authorized[0] = msg.sender;
        deployRegistry(_delegate, _endpoint, _endpointId, _factory, _messenger);

        // testDeployRegistryOutput(_factory, _messenger, strategyAdapter, msg.sender,authorized, "TEST", "TST", address(0), msg.sender, endpoint,);
    }

    function testVaultCreationNative(
        StrategyAdapter strategyAdapter,
        IVaultFactory _factory,
        IVaultRegistryMessenger _messenger,
        address deployer,
        address[] authorizedVip,
        string vaultName,
        string vaultTicker,
        IERC20 vaultAsset,
        address creator,
        address vaultEndpoint,
        VaultAssets.FeesInfo fees,
        VaultAssets.feeReceiversInfo feeReceivers
    ) public {
        VaultHelper.VaultDeployParams memory deployParams =
            constructDeployParams(
                deployer, authorizedVip, vaultName, vaultTicker, vaultAsset, creator, vaultEndpoint, fees, feeReceivers
            );

        VaultRegistry.deployHubVault(creator, deployParams);
    }

    function testDeployRegistryOutput(IVaultFactory factory, IVaultRegistryMessenger messenger, StrategyAdapter adapter)
        public
        pure
    {
        console.log("STEP ONE: Strategy Adapter deployed: ");
        console.logAddress(address(adapter));
        console.log("STEP TWO: Facotry Deployed: ");
        console.log(address(factory));
        console.log("STEP THREE: Messenger Deployed: ");
        console.log(address(messenger));
    }

    function testVaultCreationNativeOutput(
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

    function adddRegistryPeers() public {}

    function deployStrategyAdapter(address _delegate) public returns (StrategyAdapter adapter) {
        adapter = new StrategyAdapter(_delegate);
    }

    function deployFacotry(address _authorized, StrategyAdapter adapter) public returns (IVaultFactory factory) {
        factory = IVaultFactory(address(new VaultFactory(_authorized, IStrategyAdapter(address(adapter)))));
    }

    function deployMessenger(address endpoint, address delegate) public returns (IVaultRegistryMessenger messenger) {
        messenger = IVaultRegistryMessenger(address(new VaultRegistryMessenger(endpoint, delegate)));
    }

    function deployRegistry(
        address _delegate,
        address _endpoint,
        uint32 _endpointId,
        IVaultFactory _factory,
        IVaultRegistryMessenger _messenger
    ) public {
        registry = new VaultRegistry(_delegate, _endpoint, _endpointId, _delegate, _factory, _messenger);
    }

    function constructDeployParams(
        address deployer,
        address[] authorizedVip,
        string vaultName,
        string vaultTicker,
        IERC20 vaultAsset,
        address creator,
        address vaultEndpoint,
        VaultAssets.FeesInfo fees,
        VaultAssets.feeReceiversInfo feeReceivers
    ) public view returns (VaultHelper.VaultDeployParams memory params) {
        params = VaultHelper.VaultDeployParams(
            deployer, authorizedVip, vaultName, vaultTicker, vaultAsset, creator, vaultEndpoint, fees, feeReceivers
        );
    }
}
