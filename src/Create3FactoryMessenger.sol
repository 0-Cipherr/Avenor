// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CREATE3FACTORY} from "../src/CREATE3FACTORY.sol";
import {ICREATE3FACTORY} from "../src/ICREATE3FACTORY.sol";

import "forge-std/console.sol";

//// @title A title that should describe the contract/interface

import {
    AddressCast
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/libs/AddressCast.sol";
import {
    MessagingFee,
    MessagingReceipt
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {Origin} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import {
    ReadCodecV1,
    EVMCallRequestV1
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import {OAppRead} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

/**
 * purpose allows for simple determistic depyoment for vaults accross all chains
 * deployed on all chains and called from hubwhen we deploy vaults on multiple chains makes deployment easier
 * same address for all vaults accross evm makes things easier
 */
contract Create3FactoryMessenger is OAppRead, OAppOptionsType3 {
    CREATE3FACTORY public factory; //factory deployed with deterministic addr
    address public factoryDeterministic;
    constructor(
        address _endpoint,
        address _delegate
    ) OAppRead(_endpoint, _delegate) Ownable(_delegate) {
        factory = new CREATE3FACTORY();
    }

    // function messageQuote() public returns (MessagingFee memory) {}

    function sendessage() public {}

    function deploy(
        bytes32 salt,
        bytes memory creationCode
    ) public returns (address) {
        (address deployed) = factory.deploy(salt, creationCode);
        return deployed;
    }

    function factoryInitDeployment(
        bytes32 salt,
        bytes memory creationCode
    ) public {
        address deployed = deploy(salt, creationCode);
        setFactory(deployed);
    }

    function setFactory(address deployed) public {
        factory = CREATE3FACTORY(deployed);
        factoryDeterministic = deployed; //we store this so its ez for devs to use
    }

    function getDeploymentAddress() public view returns (address) {
        return address(this);
    }

    function getDeterministicFactory() public view returns (address) {
        return factoryDeterministic;
    }

    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        (bool success, ) = address(this).call(_message);
        require(success, "Execution failed");
        // 1. Decode the returned data from bytes to uint256
        // uint256 data = abi.decode(_message, (uint256));
    }
}

//deployed messenger to test
/**
 * Deployed on arbitrum sepolia we will deploy the facotory deployer on op sepolia
 *   Deployed Messenger Address:
  0xF1BA2bD959776F699cc1071c8AC106dd5B729271
  Endpoint Deployed at:
  0x6EDCE65403992e310A62460808c4b910D972f10f
  Endpoint id Deployed at:
  40231
  Chain Id:
  421614

 */
