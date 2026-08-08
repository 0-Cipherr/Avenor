// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {VaultHelper} from "./VaultHelper.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CREATE3FACTORY} from "../src/CREATE3FACTORY.sol";
import {ICREATE3FACTORY} from "../src/ICREATE3FACTORY.sol";
import "forge-std/console.sol";
import {Create3FactoryMessenger} from "./Create3FactoryMessenger.sol";
/////////
import {
    OptionsBuilder
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

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

//vault factory maybe on another file
contract Create3Deployer is OAppRead, OAppOptionsType3 {
    using OptionsBuilder for bytes;

    using VaultHelper for address;
    using VaultHelper for bytes32;

    /**
     * KEY TAKEAWAY:
     * This Create3Deployer factory is only deployed nce the Factory Messenger facilitates
     *   Deployment on the chains we want to use
     *
     * Factory:
     * This struct is information about the factory including:
     * isEVM: factories can only be deployed on evm chains other chains have
     *    different address standards so factory wont work there for example solana
     *    comparision example for addresses:
     *    EVM : 0xD187f06f49d18c63062602A3653b5ad8D8055645
     *    SOLANA: Ge87EtsjwRQbHaqQmKRno69RFTwh9bfSsm99XNxTpump
     *
     * factory :
     *  information of the factory deployed:
     *    salt :
     *      unique value we created
     *    creationCode:
     *      this is important this is the creation code of the deployed factory on the chain the
     *      Vault Factory lives
     *    factory:
     *      address of the factory deployed after calling .deploy(salt, creationCode) in create3factory contract
     *
     *    How deterministic addressses work:
     *    u deploy on one chain using .deploy
     *    we create a salt and get creation code from deployment , we use both salt and
     *    creation code ame values on all chains when we call .deploy in create3factory this allows all address to
     *    be the same on all chains
     *
     * EVMFACTORYINFO:
     * Info of the factory deployed on the ub chain where this factory lives
     *
     * Create3FactoryPeers:
     *   factory messenger peers on many chains we have we use this list
     *   to deploy ou own create3factory for our protocol so its same address on our chains
     *   and its our own factory as well
     *
     *   endpoint: layer zero endpoint address where the Factory messenger lives each evm chain has different
     *    endpoints
     *
     *   messengerAddr: address of contract on that specific chain important
     *
     *   endpoint id: chains endpoint id where factory messenger lives same as endpoint is unique on all evm chains
     *
     *   chain id : raw solidity format chain id where factory messenger lives in
     */
    struct FactoryInfo {
        bytes32 salt;
        bytes creationCode;
        address factory;
    }

    struct Factory {
        bool isEVM;
        FactoryInfo factory;
        uint256[] chains;
    }

    struct Create3FactoryPeerInfo {
        address endpoint;
        address messengerAddr;
        uint32 endpointId;
        uint256 chainId;
    }

    Factory public EVMFACTORYINFO;
    Create3FactoryPeerInfo[] Create3FactoryPeers;

    /**
     * _endpoint :
     *   layer zero endpoint address where this contract lives (IMPORTANT)
     * _delegate:
     *    Owner of theVaultFactory deployed in this case its me i can make it secure so users can trust
     *
     * _Create3FactoryPeers:
     *   list of FactoryMessengers deployed with their proper info to bulk deploy
     *
     * flow call constructor add peers (addFactoryMessengerPeers)
     *
     * then get quote for dpeloying facotrie on available chains getMessengerDeployQuote()
     *
     * then deploy factories on all chains detemrinistic with deployFactories()
     *
     * after this users can deploy vaults how they want on what chians they want
     *
     */
    constructor(
        address _endpoint,
        address _delegate,
        Create3FactoryPeerInfo[] memory _Create3FactoryPeers
    ) OAppRead(_endpoint, _delegate) Ownable(_delegate) {
        if (_Create3FactoryPeers.length > 0) {
            pushCREATE3FactoryPeers(_Create3FactoryPeers);
            addFactoryMessengerPeers();
        }
    }

    /**
     * Pushes Fctory peers to Create3FactoryPeers upon deployment if it exists important must exist
     */
    function pushCREATE3FactoryPeers(
        Create3FactoryPeerInfo[] memory _Create3FactoryPeers
    ) public {
        for (uint256 i = 0; i < _Create3FactoryPeers.length; i++) {
            Create3FactoryPeers.push(_Create3FactoryPeers[i]);
        }
    }

    function getFactoryInfo() public view returns (Factory memory) {
        return EVMFACTORYINFO;
    }

    function getMessengerDeployQuote() public view returns (uint256) {
        uint256 total;

        for (uint256 i = 0; i < Create3FactoryPeers.length; i++) {
            Create3FactoryPeerInfo
                memory currentMessenger = Create3FactoryPeers[i];
            bytes memory message = abi.encodeWithSelector(
                Create3FactoryMessenger.deploy.selector,
                EVMFACTORYINFO.factory.salt,
                EVMFACTORYINFO.factory.creationCode
            );
            //fix properly add options and check for paying ith layerzero token
            MessagingFee memory fee = messageQuote(
                currentMessenger.endpointId,
                message,
                bytes(""),
                false
            );

            total += fee.nativeFee;
        }

        return total;
    }

    function createOptions() public {}
    /**
     * optinal function to add singular peers one by one if doenst exist upon dpeloyment in constructor
     */
    function addCreate3FactoryPeer(
        Create3FactoryPeerInfo memory _Create3FactoryPeers
    ) public {
        Create3FactoryPeers.push(_Create3FactoryPeers);
    }

    function generateUniqueSalt(
        string memory name
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(name, block.timestamp));
    }

    function addFactoryMessengerPeers() public {
        for (uint256 i = 0; i < Create3FactoryPeers.length; i++) {
            Create3FactoryPeerInfo
                memory currentMessenger = Create3FactoryPeers[i];
            bytes32 messengerAddr = VaultHelper.addrToBytes32(
                currentMessenger.messengerAddr
            );
            setPeer(currentMessenger.endpointId, messengerAddr);
        }
    }

    function storeCREATE3Factory(
        bytes32 salt,
        bytes memory creationCode,
        address factory,
        bool isEVM,
        uint256 deployedChain
    ) public {
        FactoryInfo memory info = FactoryInfo(salt, creationCode, factory);
        EVMFACTORYINFO.isEVM = isEVM;
        EVMFACTORYINFO.factory = info;
        EVMFACTORYINFO.chains.push(deployedChain);
    }

    function deployFactory(string memory name) public {
        CREATE3FACTORY factory = new CREATE3FACTORY();
        bytes memory creationCode = type(CREATE3FACTORY).creationCode;
        bytes32 salt = generateUniqueSalt(name);
        (address deployed) = factory.deploy(salt, creationCode);
        storeCREATE3Factory(salt, creationCode, deployed, true, block.chainid);
    }

    function deployFactories(
        uint256 total,
        address caller,
        MessagingFee[] memory fees
    ) public payable returns (bool) {
        require(total == msg.value, "Not enough to cover fees!");
        //make custom modifier to verifiy amount is total of fees call message quoter again modifier to proerly verify
        for (uint256 i = 0; i < Create3FactoryPeers.length; i++) {
            Create3FactoryPeerInfo
                memory currentMessenger = Create3FactoryPeers[i];
            bytes memory message = abi.encodeWithSignature(
                "deploy(bytes,bytes32)",
                EVMFACTORYINFO.factory.salt,
                EVMFACTORYINFO.factory.creationCode
            );
            //fix options bytes("") shoudl be proper options and pay in lz
            //also check fees[] should not conflict verify length and validity or call bulk quoter again
            sendMessage(
                currentMessenger.endpointId,
                message,
                bytes(""),
                fees[i],
                caller
            );
        }
        return true;
    }
    function messageQuote(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        bool _payInLzToken
    ) public view returns (MessagingFee memory) {
        (MessagingFee memory fee) = _quote(
            _dstEid,
            _message,
            _options,
            _payInLzToken
        );

        return fee;
    }

    function sendMessage(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        MessagingFee memory _fee,
        address _refundAddress
    ) public returns (bool) {
        _lzSend(_dstEid, _message, _options, _fee, _refundAddress);
        return true;
    }

    ///layer zero reciever
    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        // 1. Decode the returned data from bytes to uint256
        // uint256 data = abi.decode(_message, (uint256));
    }
}
