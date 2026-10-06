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
        (StrategyAdapter strategyAdapter, IVaultFactory _factory, IVaultRegistryMessenger _messenger) =
            testDeployRegistry();
        uint32 peerEndpointId;
        bytes32 peerAddr; //condiion  84532 ? 40245 : 40231;
        address[] memory authorized;
        authorized[0] = (msg.sender);
        testVaultCreationNative(
            strategyAdapter,
            _factory,
            _messenger,
            msg.sender,
            authorized,
            "TEST",
            "TST",
            msg.sender,
            _enpoint,
            VaultAssets.FeesInfo(0, 0),
            VaultAssets.feeReceiversInfo(address(0), address(0)),
            peerEndpointId,
            peerAddr
        );
    }

    // address deployer,
    //     address[] authorizedVip,
    //     string vaultName,
    //     string vaultTicker,
    //     address creator,
    //     address vaultEndpoint,
    //     VaultAssets.FeesInfo fees,
    //     VaultAssets.feeReceiversInfo feeReceivers,
    //     uint32 peerEndpointId,
    //     bytes32 peerAddr
    function testDeployRegistry()
        public
        returns (StrategyAdapter strategyAdapter, IVaultFactory _factory, IVaultRegistryMessenger _messenger)
    {
        address _delegate = msg.sender;
        _enpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        _endpointId = block.chainid == 84532 ? 40245 : 40231;
        strategyAdapter = deployStrategyAdapter(msg.sender);
        _factory = deployFacotry(msg.sender, strategyAdapter);
        _messenger = deployMessenger(_enpoint, msg.sender);
        address[] memory authorized;
        authorized[0] = msg.sender;

        deployRegistry(_delegate, _enpoint, _endpointId, _factory, _messenger);

        testDeployRegistryOutput(_factory, _messenger, strategyAdapter);
    }

    function testVaultCreationNative(
        StrategyAdapter strategyAdapter,
        IVaultFactory _factory,
        IVaultRegistryMessenger _messenger,
        address deployer,
        address[] memory authorizedVip,
        string memory vaultName,
        string memory vaultTicker,
        address creator,
        address vaultEndpoint,
        VaultAssets.FeesInfo memory fees,
        VaultAssets.feeReceiversInfo memory feeReceivers,
        uint32 peerEndpointId,
        bytes32 peerAddr
    ) public {
        IERC20 deployedToken = testDeployERC20("Gecko Coin", "GECKO");
        addRegistryPeer(peerEndpointId, peerAddr);

        VaultHelper.VaultDeployParams memory deployParams = constructDeployParams(
            deployer, authorizedVip, vaultName, vaultTicker, deployedToken, creator, vaultEndpoint, fees, feeReceivers
        );

        registry.deployHubVault(creator, abi.encode(deployParams));
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

    function testDeployERC20(string memory name, string memory ticker) public returns (IERC20) {
        TokenDeployer deployed = new TokenDeployer(name, ticker);
        deployed.mintTokens(msg.sender, 100000);
        IERC20 tokenDeployed = IERC20(address(deployed));

        return tokenDeployed;
    }

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
    ) public view returns (VaultHelper.VaultDeployParams memory params) {
        params = VaultHelper.VaultDeployParams(
            deployer, authorizedVip, vaultName, vaultTicker, vaultAsset, creator, vaultEndpoint, fees, feeReceivers
        );
    }
}
