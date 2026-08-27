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
import {
    OptionsBuilder
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

contract AvenorFactoryHub is Ownable, OApp, OAppOptionsType3 {
    using OptionsBuilder for bytes;

    address authDelegate; //authorized address that updates stuff in the contract
    address srcEndpoint; //source endpoint of chain this ca deploed on
    ICREATE3FACTORY factory;
    mapping(address => address[]) deployments;

    struct MessengerInfo {
        address addr;
        uint32 endpointId;
        address endpoint;
    }

    uint32 endpointId;

    mapping(uint32 => MessengerInfo) messengers;
    /**
     *
     * @param _creator - creator of this factory hubchain
     * @param _srcEndpoint endpoint from source chain of this deployment
     */
    constructor(
        address _creator,
        address _srcEndpoint,
        uint32 _endpointId
    ) Ownable(_creator) OApp(_creator, _srcEndpoint) {
        authDelegate = _creator;
        srcEndpoint = _srcEndpoint;
        endpointId = _endpointId;
    }

    function setFactory(ICREATE3FACTORY _factory) public {
        factory = _factory;
    }

    function setDeployment(address _creator, address _deployment) public {
        deployments[_creator].push(_deployment);
    }

    function getFactory() public view returns (ICREATE3FACTORY) {
        return factory;
    }

    function addMessenger(
        uint32 endpoint,
        MessengerInfo memory _messenger
    ) public {
        messengers[endpoint] = _messenger;
    }

    function generateOptions(
        uint128 gasLimit
    ) public pure returns (bytes memory) {
        return
            OptionsBuilder.newOptions().addExecutorLzReceiveOption(gasLimit, 0);
    }

    function getMessenger(
        uint32 _targetEndpoint
    ) public view returns (MessengerInfo memory _messenger) {
        return messengers[_targetEndpoint];
    }

    function crossChainBulkDepoyment(
        address _caller,
        uint32[] memory _chains,
        MessagingFee[] memory fees,
        bytes32 _salt,
        bytes memory _creationCode
    ) public payable {
        require(
            _chains.length != fees.length,
            "error chains  and fees dont match"
        );
        for (uint256 i = 0; i < _chains.length; i++) {
            uint32 _dstEid = _chains[i];
            MessagingFee memory _quote = fees[i];
            crossChainDeploy(_quote, _caller, _salt, _creationCode, _dstEid);
        }
    }
    function crossChainDeploy(
        MessagingFee memory _quote,
        address _caller,
        bytes32 salt,
        bytes memory creationCode,
        uint32 _dstEid
    ) public payable {
        MessengerInfo memory msgrInfo = getMessenger(_dstEid);
        bytes memory _options = generateOptions(1_000_000);
        bytes memory _msgParams = abi.encode(salt, creationCode, _caller);
        bytes memory _message = abi.encode(uint8(0), _msgParams);
        _lzSend(msgrInfo.endpointId, _message, _options, _quote, _caller);
    } //deploys a contract same address on another chain

    function deployContractHub(
        address _creator,
        bytes32 salt,
        bytes memory creationCode
    ) public {
        (address deployed) = factory.deploy(salt, creationCode);
        setDeployment(_creator, deployed);
    }

    function getMessageQuote(
        uint32 _dstEid,
        bytes memory _message,
        bool _payInLzToken
    ) public view returns (MessagingFee memory _deployQuote) {
        bytes memory _options = generateOptions(1_000_000);
        (MessagingFee memory fee) = _quote(
            _dstEid,
            _message,
            _options,
            _payInLzToken
        );
        _deployQuote = fee;
    }
    function bulkMessageQuote() public {}

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
