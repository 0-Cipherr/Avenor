// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {TokenDeployer} from "../src/TokenDeployer.sol";

contract VaultManagerTest is Test {
    VaultManager manager;
    TokenDeployer vaultAsset;

    struct FeesInfo {
        uint256 _creatorFee;
        uint256 _protocolFee;
    }

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // getFees();
        // mathTest();
        setUpENV();
        deployToken();
        test_deposit(100, msg.sender);
        vm.stopBroadcast();
    }

    function setUpENV() public {
        address[] memory authorized;
        string memory vaultName = "Avenor";
        string memory vaultTicker = "AV";
        vaultAsset = deployToken();
        address creator = msg.sender;
        address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        VaultAssets.FeesInfo memory fees = VaultAssets.FeesInfo(700, 500);
        VaultAssets.feeReceiversInfo memory feeRecievers =
            VaultAssets.feeReceiversInfo(msg.sender, 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d); //endpoint id for base 40245
        manager = new VaultManager(
            authorized, vaultName, vaultTicker, IERC20(address(vaultAsset)), creator, endpoint, fees, feeRecievers
        );

        console.log("Deployed manager: ");
        console.logAddress(address(manager));
    }

    function mintDeployedToken() public {
        vaultAsset.mintTokens(msg.sender, 1000);
    }

    function approveTokenSpending() public {
        vaultAsset.approve(address(manager), 1000);
    }

    function fundTokensWallet() public {}

    function getFees() public view {
        VaultAssets.FeesInfo memory _fees = manager.getFees();
        console.logUint(_fees._creatorFee);
        console.logUint(_fees._protocolFee);
    }

    function mathTest() public view {
        uint256 amount = 500e18;

        uint256 total = manager.calculateFees(amount);

        console.log("amount before:");
        console.logUint(amount);

        console.log("After arithmetic:");
        console.logUint(total);

        console.log("After arithmetic / 1e18:");
        console.logUint(total / 1e18);
    }

    function deployToken() public returns (TokenDeployer) {
        TokenDeployer deployedToken = new TokenDeployer("UnicornCoin", "UCC");
        console.log("Deployed token");
        console.log("Name: UnicornCoin , Ticker: UCC");
        console.log("Address");
        console.logAddress(address(deployedToken));
        return deployedToken;
    }

    function test_deposit(uint256 _assets, address _receiver) public {
        mintDeployedToken();
        approveTokenSpending();
        manager.depositAssets(_assets, _receiver);
        verifyDeposit();
    }

    function verifyDeposit() public view {
        VaultHelper.DepositorInfo memory _depositInfo = manager.getDepositor(msg.sender);
        console.log("Shares Balance:");
        console.logUint(_depositInfo.shares);
        console.log("Volume: ");
        console.log(_depositInfo.assetVolume);
        console.log("Assets deposited all time:");
        console.log(_depositInfo.assets);
        console.log("who is this dpeositor:");
        console.log(_depositInfo.depositor);
    }

    function test_withdraw() public {
        VaultHelper.DepositorInfo memory _depositInfo = manager.getDepositor(msg.sender);
        uint256 _amount = manager.previewWithdraw(_depositInfo.shares);
        manager.withdrawAssets(_depositInfo.shares, msg.sender, _amount, true);
    }
}

// address[] memory _authorizedVip,
// string memory vaultName,
// string memory vaultTicker,
// IERC20 _vaultAsset,
// address _creator,
// address _endpoint,
// FeesInfo memory _fees,
// feeReceiversInfo memory _feeRecievers
