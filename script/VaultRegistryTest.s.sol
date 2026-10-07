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

    //it fucking works keep working hard:
    //     == Logs ==
    //   Creator:           0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d
    //   TVL:               0
    //   All-Time Volume:   0
    //   Vault Factory:     0x31e19E3d02107b6f735257ca0C0BbDDcF5a9d666
    //   Name:              TEST
    //   Ticker:            TST
    //   Deposit Asset:     0x9b1c96050aB791b2077460dae3B45071C1204b69

    //next flow to test is testing depositing and withdrawing in the vault each step is commented out we must call addPeer before doing anything
    function run() external {
        vm.startBroadcast();
        registry = block.chainid == 84532
            ? VaultRegistry(0xE55dE713dcB8027F0deeF02a68381BC3ca6a9a23)
            : VaultRegistry(0x889A6bFB5eFc76643AF1D4320d013f6D326a500b);

        // deployment code here
        address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        uint32 peerEndpointId = block.chainid == 84532 ? 40231 : 40245;
        bytes32 peerAddr = block.chainid == 84532
            ? addressToBytes32(0x889A6bFB5eFc76643AF1D4320d013f6D326a500b)
            : addressToBytes32(0xE55dE713dcB8027F0deeF02a68381BC3ca6a9a23);
        address[] memory authorized = new address[](1);
        authorized[0] = (tx.origin);
        // STEP ONE ALWAYS
        // addRegistryPeer(peerEndpointId, peerAddr);

        // TEST VAULT CREATION
        (uint256 vaultId, IERC20 deployedToken, VaultHelper.Vault memory vaultInfo) = testVaultCreationNative(
            tx.origin,
            authorized,
            "TEST",
            "TST",
            0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d,
            endpoint,
            VaultAssets.FeesInfo(0, 0),
            VaultAssets.feeReceiversInfo(address(0), address(0))
        );

        testVaultDeploymentOutput(vaultInfo); //fill in this function
        getERC20Balance(deployedToken, 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);

        vm.stopBroadcast();
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
    ) public returns (uint256 vaultId, IERC20 deployedToken, VaultHelper.Vault memory vaultInfo) {
        deployedToken = testDeployERC20("Gecko Coin", "GECKO");

        VaultHelper.VaultDeployParams memory deployParams = constructDeployParams(
            deployer, authorizedVip, vaultName, vaultTicker, deployedToken, creator, vaultEndpoint, fees, feeReceivers
        );

        vaultId = registry.deployHubVault(creator, abi.encode(deployParams));
        testDeposit(vaultId, deployedToken, 10000, 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d);
        vaultInfo = getVaultInfo(vaultId);
    }

    function getERC20Balance(IERC20 token, address user) public view {
        console.log("ERC20 BALNCE:");
        console.logUint(token.balanceOf(user));
    }

    function testDeposit(uint256 vaultId, IERC20 asset, uint256 assets, address reciever) public {
        // asset.approve();
        // /we neeed to get the vaults address and set its allowance not towards the registry beofr edoing anything
        registry.deposit(vaultId, assets, reciever);
    }

    function testVaultDeploymentOutput(VaultHelper.Vault memory _vault) public pure {
        console.log("Creator:          ", _vault.creator);
        console.log("TVL:              ", _vault.tvl);
        console.log("All-Time Volume:  ", _vault.allTimeVolume);
        console.log("Vault Factory:    ", address(_vault.vault));
        console.log("Name:             ", _vault.name);
        console.log("Ticker:           ", _vault.ticker);
        console.log("Deposit Asset:    ", address(_vault.depositAsset));
    }

    function getVaultInfo(uint256 vaultId) public view returns (VaultHelper.Vault memory) {
        return registry.getVault(vaultId);
    }

    function outputVaultInfo() public {}

    function testDeployERC20(string memory name, string memory ticker) public returns (IERC20) {
        TokenDeployer deployed = new TokenDeployer(name, ticker);
        deployed.mintTokens(tx.origin, 100000);
        console.log("miinted 100,000 tokens for deposit on your wallet ");
        IERC20 tokenDeployed = IERC20(address(deployed));
        deployed.approve(address(registry), 100000000000);

        return tokenDeployed;
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
