// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {CREATE3FACTORY} from "../src/CREATE3FACTORY.sol";
import {ICREATE3FACTORY} from "../src/ICREATE3FACTORY.sol";

//// @title A title that should describe the contract/interface

import {
    AddressCast
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/libs/AddressCast.sol";
import {
    UlnConfig
} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
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
import {VaultHelper} from "../src/VaultHelper.sol";

import {
    ILayerZeroEndpointV2
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {
    IMessageLibManager,
    SetConfigParam
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
/**
 * purpose allows for simple determistic depyoment for vaults accross all chains
 * deployed on all chains and called from hubwhen we deploy vaults on multiple chains makes deployment easier
 * same address for all vaults accross evm makes things easier
 */
contract Create3FactoryMessenger is OApp, OAppOptionsType3 {
    ICREATE3FACTORY public factory; //factory deployed with deterministic addr

    ICREATE3FACTORY public factoryDeterministic;
    struct DeploymentInfo {
        bytes32 _salt;
        bytes creationCode;
        address deployment;
    }
    mapping(address => DeploymentInfo[]) deployments;
    enum MessageType {
        DeployFactoryDeterministic
    }

    constructor(
        address _delegate,
        address _endpoint
    ) Ownable(_delegate) OApp(_endpoint, _delegate) {}
    function setFactory(ICREATE3FACTORY _factory) public {
        factory = _factory;
    }

    function getDeploymentInfo(
        address _caller,
        uint256 _index
    ) public view returns (DeploymentInfo memory) {
        return deployments[_caller][_index];
        //should be the owner of the dpeloyment only uses for developer to check deployment information
    }

    function setDeterministicFactory(ICREATE3FACTORY _deployed) public {
        factoryDeterministic = _deployed;
    }

    function getDeterministicFactory() public view returns (address) {
        return address(factoryDeterministic);
    }

    function storeFactoryPeer(uint32 _eid, address _peer) public {
        bytes32 peer = VaultHelper.addrToBytes32(_peer);
        setPeer(_eid, peer);
    }

    function setDeployment(
        address _creator,
        DeploymentInfo memory _deployment
    ) public {
        deployments[_creator].push(_deployment);
    }

    function deployContract(bytes memory _params) public {
        (bytes32 salt, bytes memory creationCode, address _caller) = abi.decode(
            _params,
            (bytes32, bytes, address)
        );

        (address deployed) = factoryDeterministic.deploy(salt, creationCode);
        DeploymentInfo memory _deployment = DeploymentInfo(
            salt,
            creationCode,
            deployed
        );
        setDeployment(_caller, _deployment);
    }
    function executeMessageType(
        MessageType _type,
        bytes memory _params
    ) public {
        if (_type == MessageType.DeployFactoryDeterministic) {
            deployContract(_params);
        }
    }
    function addressToBytes(address _addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function sendMessage() public {}

    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        (uint8 callType, bytes memory params) = abi.decode(
            _message,
            (uint8, bytes)
        );
        MessageType messageType = MessageType(callType);
        executeMessageType(messageType, params);
        // require(success, "Execution failed");
        // 1. Decode the returned data from bytes to uint256
        // uint256 data = abi.decode(_message, (uint256));
    }
    function flush(address reciever) public payable {
        payable(reciever).call{value: address(this).balance}("");
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
