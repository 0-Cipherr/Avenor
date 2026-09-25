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

        vm.stopBroadcast();
    }

    function deployRegistry(address _endpoint, address _delegate) public {
        registry = new VaultRegistry(_endpoint, _delegate);
    }

    function simulateVaultDeployment() public {}

    function simulateRegistrDeposit() public {}

    function simulateRegistryWithdraw() public {}
}
