// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // deployment code here

        vm.stopBroadcast();
    }
}
