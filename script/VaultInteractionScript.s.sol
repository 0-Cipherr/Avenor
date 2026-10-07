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
import {VaultAssets} from "../src/VaultAssets.sol";
import {TokenDeployer} from "../src/TokenDeployer.sol";

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
        testDeployRegistry();
    }

    function testDeployRegistry()
        public
        returns (StrategyAdapter strategyAdapter, IVaultFactory _factory, IVaultRegistryMessenger _messenger)
    {
        address _delegate = tx.origin;
        _enpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        _endpointId = block.chainid == 84532 ? 40245 : 40231;
        strategyAdapter = deployStrategyAdapter(tx.origin);
        _factory = deployFacotry(tx.origin, strategyAdapter);
        _messenger = deployMessenger(_enpoint, tx.origin);
        address[] memory authorized = new address[](1);
        authorized[0] = tx.origin;

        deployRegistry(_delegate, _enpoint, _endpointId, _factory, _messenger);

        testDeployRegistryOutput(_factory, _messenger, strategyAdapter);
    }

    function testVaultDeploymentOutput() public {}

    function testDeployRegistryOutput(IVaultFactory factory, IVaultRegistryMessenger messenger, StrategyAdapter adapter)
        public
        view
    {
        console.log("STEP ONE: Strategy Adapter deployed: ");
        console.logAddress(address(adapter));
        console.log("STEP TWO: Facotry Deployed: ");
        console.log(address(factory));
        console.log("STEP THREE: Messenger Deployed: ");
        console.log(address(messenger));
        console.log("REGISTRY DEPLOYED:");
        console.logAddress(address(registry));
    }

    //next step
    function testVaultDeposit() public {}

    function mintERC20Tokens(IERC20 asset) public {}

    function addRegistryPeer(uint32 endpointId, bytes32 peer) public {
        registry.addRegistryPeer(endpointId, peer);
    }

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
        address __endpoint,
        uint32 __endpointId,
        IVaultFactory _factory,
        IVaultRegistryMessenger _messenger
    ) public {
        registry = new VaultRegistry(_delegate, __endpoint, __endpointId, _delegate, _factory, _messenger);
    }

    function constructDeployParams(
        address deployer,
        address[] memory authorizedVip,
        string memory vaultName,
        string memory vaultTicker,
        IERC20 vaultAsset,
        address creator,
        address vaultEndpoint,
        VaultAssets.FeesInfo memory fees,
        VaultAssets.feeReceiversInfo memory feeReceivers
    ) public pure returns (VaultHelper.VaultDeployParams memory params) {
        params = VaultHelper.VaultDeployParams(
            deployer, authorizedVip, vaultName, vaultTicker, vaultAsset, creator, vaultEndpoint, fees, feeReceivers
        );
    }
}
