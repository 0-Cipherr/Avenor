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
    UlnConfig
} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
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
import {ICREATE3FACTORY} from "../src/ICREATE3FACTORY.sol";
import {
    ILayerZeroEndpointV2
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {
    IMessageLibManager,
    SetConfigParam
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
/**
 * template format for runing script 
forge script script/FactoryMesengerScript.s.sol --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast
/chains with funds sepolia op nd arbitrum
== Logs ==
  Deployed Messenger Address:
  0x6050464021C9F2eB3280Da7A7604beD9823375b6
  Endpoint Deployed at:
  0x6EDCE65403992e310A62460808c4b910D972f10f
  Endpoint id Deployed at:
  40231
  Chain Id:
  421614




 */

contract Test is Ownable, OApp, OAppOptionsType3 {
    using OptionsBuilder for bytes;

    // using VaultHelper for address;
    // using VaultHelper for bytes32;
    bool PAYINLZTOKEN = false;

    struct Create3FactoryPeerInfo {
        address endpoint;
        address messengerAddr;
        uint32 endpointId;
        uint256 chainId;
        uint256 creationTime;
        bool deployed;
    }
    struct DeployQuote {
        uint32 dstEid;
        bytes message;
        bytes options;
        MessagingFee fee;
        address refundAddress;
    }
    struct FactoryInfo {
        bytes creationCode;
        bytes32 salt;
        ICREATE3FACTORY factoryDeployed;
        ICREATE3FACTORY deterministicFactory;
    }

    FactoryInfo factory;
    Create3FactoryPeerInfo[] factoryPeers;
    constructor(
        address _delegate,
        address _endpoint,
        uint32 endpointId
    ) Ownable(_delegate) OApp(_endpoint, _delegate) {}
    //set setPeer is alrady in OApp and is public

    function setNativeFactory(ICREATE3FACTORY _factory) public {
        factory.factoryDeployed = _factory;
    }

    function setFactoryCreationCode(bytes memory _creationCode) public {
        factory.creationCode = _creationCode;
    }
    function deployDeterministicFactoryNative(uint256 _num) public {
        bytes32 salt = generateSalt(_num);
        (address deployed) = factory.factoryDeployed.deploy(
            salt,
            factory.creationCode
        );

        setFactoryDeterministicFactory(deployed);
        storeFactorySalt(salt);
    }
    function storeFactorySalt(bytes32 _salt) public {
        factory.salt = _salt;
    }

    function setCreate3Factory(
        ICREATE3FACTORY _factory,
        bytes memory _creationCode,
        bytes32 _salt,
        ICREATE3FACTORY _deterministicFactory
    ) public {
        factory = FactoryInfo(
            _creationCode,
            _salt,
            _factory,
            _deterministicFactory
        );
    }

    function setFactoryDeterministicFactory(
        address _deterministicFactory
    ) public {
        factory.deterministicFactory = ICREATE3FACTORY(_deterministicFactory);
    }

    function setFactoryIsDeplyoed(uint256 index, bool isDeployed) public {
        factoryPeers[index].deployed = isDeployed;
    }

    function generateSalt(uint256 _num) public view returns (bytes32) {
        return keccak256(abi.encodePacked(msg.sender, uint256(_num)));
    }

    function deployFactoryCrossChain(
        uint256 index,
        DeployQuote memory quote
    ) public payable {
        require(factoryPeers[index].deployed == false, "Deployed already");
        _lzSend(
            quote.dstEid,
            quote.message,
            quote.options,
            quote.fee,
            quote.refundAddress
        );
        setFactoryIsDeplyoed(index, true);
    }

    function storePeer(uint32 _eid, address _peer) public {
        bytes32 addr = VaultHelper.addrToBytes32(_peer);
        setPeer(_eid, addr);
    }

    function storeCreate3FactoryPeer(
        Create3FactoryPeerInfo memory factoryPeer
    ) public {
        factoryPeers.push(factoryPeer);
    }

    function getOptions() public pure returns (bytes memory) {
        bytes memory options = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(200000, 0); // gas limit, msg.value to forward

        return options;
    }

    function isPeerDeployed(uint256 index) public view returns (bool) {
        return factoryPeers[index].deployed;
    }

    function deployPeerQuote(
        uint256 index
    ) public view returns (DeployQuote memory) {
        bytes memory options = getOptions();
        Create3FactoryPeerInfo memory peer = factoryPeers[index];
        bytes memory message = abi.encode(
            1,
            factory.salt,
            factory.creationCode
        );
        MessagingFee memory fee = messageQuote(peer.endpointId, message);
        return DeployQuote(peer.endpointId, message, options, fee, msg.sender);
    }
    function messageQuote(
        uint32 _dstEid,
        bytes memory _message
    ) public view returns (MessagingFee memory) {
        bytes memory _options = getOptions();
        (MessagingFee memory fee) = _quote(
            _dstEid,
            _message,
            _options,
            PAYINLZTOKEN
        );

        return fee;
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal override {
        // handle incoming LayerZero message
    }
}
