// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ICREATE3FACTORY} from "../src/ICREATE3FACTORY.sol";
import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AvenorFactoryHub is Ownable, OApp, OAppOptionsType3 {
    address authDelegate; //authorized address that updates stuff in the contract
    address srcEndpoint; //source endpoint of chain this ca deploed on
    ICREATE3FACTORY factory;

    struct MessengerInfo {
        address addr;
        uint32 endpointId;
        address endpoint;
    }

    MessengerInfo[] messengers;
    /**
     *
     * @param _creator - creator of this factory hubchain
     * @param _srcEndpoint endpoint from source chain of this deployment
     */
    constructor(
        address _creator,
        address _srcEndpoint
    ) Ownable(_creator) OApp(_creator, _srcEndpoint) {
        authDelegate = _creator;
        srcEndpoint = _srcEndpoint;
    }

    function setFactory(ICREATE3FACTORY _factory) public {
        factory = _factory;
    }

    function getFactory() public view returns (ICREATE3FACTORY) {
        return factory;
    }

    function addMessenger(MessengerInfo memory _messenger) public {
        messengers.push(_messenger);
    }

    function generateOptions(uint256 gasLimit) public returns (bytes memory) {
        Options.newOptions().addExecutorLzReceiveOption(gasLimit, 0);
    }

    function crossChainDeployment(
        address _caller,
        MessagingFee memory _quote,
        uint256 _msgrIndex
    ) public payable {
        MessengerInfo memory msgrInfo = messengers[_msgrIndex];
        bytes memory_options = generateOptions(1_000_000);
        _lzSend(msgrInfo.endpointId, _message, _options, _quote._fee, _caller);
    } //deploys a contract same address on another chain

    function crossChainBulkDepoyment() public view {}

    /**
     *
     * @param _dstEid - destination endpoint (what chain we are sedning this message too)
     * @param _message - the message we are sending to another chain
     * @param _options - options fo the message ex if we wanna send gas to the other chain
     * @param _fee- fee to pay wether native or lzero token
     * @param _refundAddress - refund address to return if fails
     */
    function sendMessage(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        MessagingFee memory _fee,
        address _refundAddress
    ) public payable {
        _lzSend(_dstEid, _message, _options, _fee, _refundAddress);
    }

    //only parameter that truly matters in my opinion is the message param

    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {}
}
