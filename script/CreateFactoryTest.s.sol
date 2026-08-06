// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CREATE3FACTORY} from "../src/CREATE3FACTORY.sol";
import "forge-std/console.sol";
/**
 * template format for runing script 
forge script script/CreateFactoryTest.s.sol --rpc-url wss://robinhood-sepolia-rpc.publicnode.com --account Avenor_Tetnet --broadcast

 */

contract CreateFactoryTest is Script {
    CREATE3FACTORY public factory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        deployFactory();
        vm.stopBroadcast();
    }

    function generateDynamicSalt(
        string memory name,
        uint256 id
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(name, id));
    }

    function deployFactory() public {
        factory = new CREATE3FACTORY();
        bytes memory _creationCode = type(CREATE3FACTORY).creationCode;

        bytes32 _salt = generateDynamicSalt("Vault facotry", 2);
        /**
         * FOR _creationcode:
         * deployment provides these 4 values importat <init code> <runtime code> <constructor parameters>
         * to create the create3 function we must privde salt and creation code
         *  salt is any custom value u wanna generate but must be unique otherwise can cause coflict among users on the contract level
         * creation code however must be preciesly the creation code of the deployed contract
         * (reason prvide...)
         */
        console.log("Chain Deployed:");
        console.logUint(block.chainid);
        console.log("Factory deployed creation code: ");
        console.logBytes(_creationCode);
        console.log("Factory deployed salt: ");
        console.logBytes32(_salt);

        console.log("Factory address raw: ", address(factory));
        factory.deploy(_salt, _creationCode);
    }
}
