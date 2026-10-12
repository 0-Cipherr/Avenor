// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {VaultRegistry} from "../src/VaultRegistry.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {TokenDeployer} from "../src/TokenDeployer.sol";

contract VaultRegistryTest is Script {
    VaultRegistry registry;
    address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    uint32 peerEndpointId = block.chainid == 84532 ? 40231 : 40245;
    bytes32 peerAddr = block.chainid == 84532
        ? addressToBytes32(0xAA549afC3f1fad167Efb6c0ca495eF4b3882977C)
        : addressToBytes32(0x3268e6381462d25466e0b0B75c57fbcF53d42D26);
    address[] authorized = new address[](1);

    function run() external {
        vm.startBroadcast();
        registry = block.chainid == 84532
            ? VaultRegistry(0x3268e6381462d25466e0b0B75c57fbcF53d42D26)
            : VaultRegistry(0xAA549afC3f1fad167Efb6c0ca495eF4b3882977C);
        authorized[0] = (0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);

        // TEST VAULT CREATION

        //step one
        (uint256 vaultId, IERC20 deployedToken, address vaultAddress) = testVaultCreationNative(
            0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d,
            authorized,
            "TEST",
            "TST",
            0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d,
            endpoint,
            VaultAssets.FeesInfo(0, 0),
            VaultAssets.feeReceiversInfo(address(0), address(0))
        );

        //step two native deposit and withdraw
        //next test tm
        inAndOutNativeTest(vaultId, deployedToken, vaultAddress);

        vm.stopBroadcast();
    }

    function inAndOutNativeTest(uint256 vaultId, IERC20 deployedToken, address vaultAddress) public {
        uint256 approveAmount = 10000;
        uint256 depositAmount = 1000;
        uint256 _shares = 20;

        approveAssets(deployedToken, address(registry), approveAmount); //approve rregistry before depositing

        testDeposit(vaultId, depositAmount, 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);
        // approveAssets(deployedToken, address(vaultInfo.vault), 100000000);
        getERC20Balance(deployedToken, 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);

        testWithdraw(vaultId, _shares, 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);

        getERC20Balance(deployedToken, 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);
    }

    function getDepostor() public returns (VaultHelper.DepositorInfo memory _depositor) {}

    function previewWithdraw(uint256 vaultId, address _sharesOwner, uint256 _shares)
        public
        view
        returns (uint256 _assetsToRecieve)
    {
        _assetsToRecieve = registry.previewWithdrawRemote(vaultId, _sharesOwner, _shares);
        console.log("Assets to recieve:");
        console.logUint(_assetsToRecieve);
    }

    function previewDeposit(uint256 vaultId, uint256 _assets) public view returns (uint256 _sharesToRecieve) {
        _sharesToRecieve = registry.previewDepositRemote(vaultId, _assets);
        console.log("Shres recievied :");
        console.logUint(_sharesToRecieve);
    }

    function addressToBytes32(address _addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    /// @notice Transforms a zero-left-padded bytes32 structure back into a usable address
    function bytes32ToAddress(bytes32 _b32) public pure returns (address) {
        return address(uint160(uint256(_b32)));
    }

    function addRegistryPeer(uint32 endpointId, bytes32 peer) public {
        registry.addRegistryPeer(endpointId, peer);
    }

    function setRegistry(address _registry) public {
        registry = VaultRegistry(_registry);
    }

    function testVaultCreationNative(
        address deployer,
        address[] memory authorizedVip,
        string memory vaultName,
        string memory vaultTicker,
        address creator,
        address vaultEndpoint,
        VaultAssets.FeesInfo memory fees,
        VaultAssets.feeReceiversInfo memory feeReceivers
    ) public returns (uint256 vaultId, IERC20 deployedToken, address vaultAddress) {
        deployedToken = testDeployERC20("Gecko Coin", "GECKO");
        approveAssets(deployedToken, address(registry), 100000000);
        VaultHelper.VaultDeployParams memory deployParams = constructDeployParams(
            deployer, authorizedVip, vaultName, vaultTicker, deployedToken, creator, vaultEndpoint, fees, feeReceivers
        );

        vaultId = registry.deployHubVault(creator, abi.encode(deployParams));
        getVaultInfo(vaultId);

        vaultAddress = getVaultAddress(vaultId);
        console.log("Vault Deployed!");
    }

    function getVaultAddress(uint256 vaultId) public view returns (address) {
        return registry.getVaultAddress(vaultId);
    }

    function getERC20Balance(IERC20 token, address user) public view {
        console.log("ERC20 BALNCE:");
        console.logUint(token.balanceOf(user));
    }

    function testDeposit(uint256 vaultId, uint256 assets, address reciever) public {
        console.log("Depositing...");

        // asset.approve();
        // /we neeed to get the vaults address and set its allowance not towards the registry beofr edoing anything
        registry.deposit(vaultId, assets, reciever);
        getVaultInfo(vaultId);

        console.log("Deposit complete!");
    }

    //api should logically verify actual users alre calling the function
    function testWithdraw(uint256 vaultId, uint256 _shares, address reciever) public {
        console.log("Withdrawing...");

        registry.withdraw(vaultId, _shares, reciever, bytes(""));
        getVaultInfo(vaultId);
        console.log("Withdraw Complete");
    }

    function testVaultDeploymentOutput(VaultHelper.Vault memory _vault, uint256 vaultId, address vaultAddress)
        public
        pure
    {
        console.log("VAULT ID: ");
        console.logUint(vaultId);
        outputVaultInfo(_vault);
        console.log("Vault Address:");
        console.logAddress(vaultAddress);
    }

    function outputVaultInfo(VaultHelper.Vault memory _vault) public pure {
        console.log("Creator:          ", _vault.creator);
        console.log("TVL:              ", _vault.tvl);
        console.log("All-Time Volume:  ", _vault.allTimeVolume);
        console.log("Vault Factory:    ", address(_vault.vault));
        console.log("Name:             ", _vault.name);
        console.log("Ticker:           ", _vault.ticker);
        console.log("Deposit Asset:    ", address(_vault.depositAsset));
    }

    function getVaultInfo(uint256 vaultId) public view returns (VaultHelper.Vault memory) {
        VaultHelper.Vault memory vaultInfo = registry.getVault(vaultId);
        outputVaultInfo(vaultInfo);
        return vaultInfo;
    }

    function outputVaultInfo() public {}

    function testDeployERC20(string memory name, string memory ticker) public returns (IERC20) {
        TokenDeployer deployed = new TokenDeployer(name, ticker);
        deployed.mintTokens(0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d, 100000);
        console.log("miinted 100,000 tokens for deposit on your wallet ");
        IERC20 tokenDeployed = IERC20(address(deployed));

        return tokenDeployed;
    }

    function approveAssets(IERC20 asset, address spender, uint256 value) public {
        asset.approve(spender, value);
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
