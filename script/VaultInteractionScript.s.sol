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
import {VaultManager} from "../src/VaultManager.sol";
import {VaultImplementation} from "../src/VaultImplementation.sol";

contract VaultInteractionScript is Script {
    VaultRegistry registry;
    address _enpoint;
    uint32 _endpointId;
    IStrategyAdapter adapter;

    function run() external {
        vm.startBroadcast();

        // deployment code here
        setUp();

        vm.stopBroadcast();
    }

    function setUp() public {
        testDeployRegistry();
        address implementation = deployVaultImplementation(_enpoint);
        setVaultImplementation(implementation);
    }

    function testDeployRegistry()
        public
        returns (StrategyAdapter strategyAdapter, IVaultFactory _factory, IVaultRegistryMessenger _messenger)
    {
        address _delegate = 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d;
        _enpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        _endpointId = block.chainid == 84532 ? 40245 : 40231;
        strategyAdapter = deployStrategyAdapter(0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);
        adapter = IStrategyAdapter(address(strategyAdapter));
        _factory = deployFacotry(tx.origin, strategyAdapter);
        _messenger = deployMessenger(_enpoint, 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);
        address[] memory authorized = new address[](1);
        authorized[0] = 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d;

        deployRegistry(_delegate, _enpoint, _endpointId, _factory, _messenger);

        testDeployRegistryOutput(_factory, _messenger, strategyAdapter);
    }

    function testVaultDeploymentOutput() public {}

    function testDeployRegistryOutput(
        IVaultFactory factory,
        IVaultRegistryMessenger messenger,
        StrategyAdapter _adapter
    ) public view {
        console.log("STEP ONE: Strategy Adapter deployed: ");
        console.logAddress(address(_adapter));
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

    function deployStrategyAdapter(address _delegate) public returns (StrategyAdapter _adapter) {
        _adapter = new StrategyAdapter(_delegate);
    }

    function deployFacotry(address _authorized, StrategyAdapter _adapter) public returns (IVaultFactory factory) {
        factory = IVaultFactory(address(new VaultFactory(_authorized, IStrategyAdapter(address(_adapter)))));
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

    function deployVaultImplementation(address _endpoint) public returns (address implementation) {
        VaultManager implementationDeployed = new VaultImplementation(_endpoint);
        implementation = address(implementationDeployed);
    }

    function constructVaultDeployParamsImplementation()
        public
        view
        returns (VaultHelper.VaultDeployParams memory _deployParams)
    {
        address[] memory authorized = new address[](1);
        authorized[0] = 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d;
        _deployParams = VaultHelper.VaultDeployParams(
            0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d,
            authorized,
            "Mock",
            "MCK",
            IERC20(address(0)),
            0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d,
            _enpoint,
            VaultAssets.FeesInfo(0, 0),
            VaultAssets.feeReceiversInfo(address(0), address(0))
        );
    }

    function setVaultImplementation(address implementation) public {
        registry.setVaultImplementation(implementation);
    }
}
