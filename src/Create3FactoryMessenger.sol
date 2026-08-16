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
contract Create3FactoryMessenger is OAppRead, OAppOptionsType3 {
    CREATE3FACTORY public factory; //factory deployed with deterministic addr
    address public factoryDeterministic;
    ILayerZeroEndpointV2 interfacedEndpoint_;
    address Endpoint;
    constructor(
        address _endpoint,
        address _delegate
    ) OAppRead(_endpoint, _delegate) Ownable(_delegate) {
        factory = new CREATE3FACTORY();
        Endpoint = _endpoint;
        interfacedEndpoint_ = ILayerZeroEndpointV2(_endpoint);
    }

    function setReceiveConfig(
        uint32 _srcEid,
        address _receiveLib,
        uint32 _gracePeriod
    ) public onlyOwner {
        interfacedEndpoint_.setReceiveLibrary(
            address(this), //contrat recieving the messages which is this
            _srcEid, //source endpooint id , endpoint id where messages are coming from for ex: form base
            _receiveLib, // this is the ReceiveUln302 located in layer zero dpeloyed endpoints page they give it to us
            _gracePeriod /**	If you're switching away from an old library, this is how long (in blocks) the old library 
            keeps working before being disabled */
        );
    }

    function setUlnConfig(
        uint32 _srcEid, //where messages are coming from endpoint id
        address _receiveLib, //ReceiveUln302 address for this chain u can find on layer zero deployed endpoints
        /**e get equired dvns from dvn deployed website layer zero choose layer zero labs dvn there are
         * multiple options u can choose whichever but make sure its available on the other chians
         */
        address[] memory _requiredDVNs, //purpose: who do you trust to tell you a message is real?
        uint64 _confirmations //purpose: how sure do you need to be that the source chain won't reorg?
    ) public onlyOwner {
        /**
         * _confirmations — the block-confirmation wait you already understand.
uint8(_requiredDVNs.length) — this isn't a separate input, it's derived from the array you're passing. The library needs to know upfront how many required DVNs to expect before it reads the array itself; you can't just hand it the array and let it infer the count, the struct format has count and content as separate fields.
uint8(0), uint8(0) — optionalDVNCount and optionalDVNT/l./hreshold, hardcoded to zero because your wrapper function doesn't support optional DVNs at all (no parameter for them exists). This is a simplification you baked in — if you later want optional DVN support, you'd need to add parameters for it here instead of hardcoding zero.
_requiredDVNs — the actual array of addresses, the meat of the config.
new address[](0) — an empty array standing in for "optional DVNs," matching the optionalDVNCount: 0 above (count and array need to agree, or the library's decode step would be inconsistent).

The result, ulnConfig, is just a blob of bytes — meaningless on its own until the receiving library decodes it back into a struct using the same field order.
         */
        bytes memory ulnConfig = abi.encode(
            _confirmations,
            uint8(_requiredDVNs.length), //how many required dvns we are passing in
            uint8(0),
            uint8(0),
            _requiredDVNs,
            new address[](0)
        );

        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam({
            eid: _srcEid,
            configType: 2,
            config: ulnConfig
        });

        interfacedEndpoint_.setConfig(address(this), _receiveLib, params);
    }
    receive() external payable {}
    // function messageQuote() public returns (MessagingFee memory) {}

    function sendessage() public {}

    function deploy(
        bytes32 salt,
        bytes memory creationCode
    ) public returns (address) {
        (address deployed) = factory.deploy(salt, creationCode);
        return deployed;
    }

    // function setPeer

    function setMessengerPeer(
        uint32 _eid,
        address _peer,
        address _receiveLib,
        uint32 _gracePeriod,
        address[] memory _requiredDVNs, //purpose: who do you trust to tell you a message is real?
        uint64 _confirmations //purpose: how sure do you need to be that the source chain won't reorg) public {
    ) public {
        bytes32 convertedPeerAddr = addressToBytes(_peer);
        _setPeer(_eid, convertedPeerAddr);
        setReceiveConfig(_eid, _receiveLib, _gracePeriod);
        setUlnConfig(_eid, _receiveLib, _requiredDVNs, _confirmations);
    }

    function addressToBytes(address _addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
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
