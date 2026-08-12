// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CREATE3FACTORY} from "../src/CREATE3FACTORY.sol";
import "forge-std/console.sol";

import {Create3FactoryMessenger} from "../src/Create3FactoryMessenger.sol";

/**
 * template format for runing script 
forge script script/VaultFactoryTest.s.sol --rpc-url https://sepolia.gateway.tenderly.co --account Avenor_Multi --broadcast
forge script script/FactoryMesengerScript.s.sol --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast
/chains with funds sepolia op nd arbitrum
== Logs ==
  Deployed Messenger Address:
  0xb023AA16d370dcC7e9c1Ce6B9BAb50aD60fEd0F7
  Endpoint Deployed at:
  0x6EDCE65403992e310A62460808c4b910D972f10f
  Endpoint id Deployed at:
  40231
  Chain Id:
  421614

 */

contract FactoryMesengerScript is Script {
    Create3FactoryMessenger messengerDeployed;
    function setUp() public {}
    ///left off deployinon another chain making sure address is the same
    function run() public {
        vm.startBroadcast();
        //settings for arbitrum seploia
        address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        address delegate = msg.sender;
        uint32 endpointId = 40231;
        deployFactoryMessenger(endpoint, delegate, endpointId);
        vm.stopBroadcast();
    }

    function deployFactoryMessenger(
        address _endpoint,
        address _delegate,
        uint32 _endpointId
    ) public {
        messengerDeployed = new Create3FactoryMessenger(_endpoint, _delegate);

        console.log("Deployed Messenger Address:");
        console.logAddress(messengerDeployed.getDeploymentAddress());
        console.log("Endpoint Deployed at:");
        console.logAddress(_endpoint);
        console.log("Endpoint id Deployed at:");
        console.logUint(_endpointId);
        console.log("Chain Id:");
        console.logUint(block.chainid);
    }
}
