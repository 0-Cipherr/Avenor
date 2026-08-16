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
import {ICREATE3FACTORY} from "../src/ICREATE3FACTORY.sol";
import {
    ILayerZeroEndpointV2
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {
    IMessageLibManager,
    SetConfigParam
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
//vault factory maybe on another file
contract Create3Deployer is OAppRead, OAppOptionsType3 {
    using OptionsBuilder for bytes;

    using VaultHelper for address;
    using VaultHelper for bytes32;
    ICREATE3FACTORY factory;

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
        address _receiveLib;
        address[] _requiredDVNs;
    }

    address endpoint_;
    ILayerZeroEndpointV2 interfacedEndpoint_;
    uint32 endpointId;
    uint256 chainId;
    address delegate;
    uint16 public constant SEND = 1;

    Factory public EVMFACTORYINFO;
    Create3FactoryPeerInfo[] public Create3FactoryPeers;

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
        uint32 _endpointId,
        ICREATE3FACTORY _factory
    ) OAppRead(_endpoint, _delegate) Ownable(_delegate) {
        endpoint_ = _endpoint;
        endpointId = _endpointId;
        chainId = block.chainid;
        delegate = _delegate;
        factory = _factory;
        interfacedEndpoint_ = ILayerZeroEndpointV2(_endpoint);
    }
    // ### Key Parameters
    // * **`oapp`**: The address of your deployed OApp contract.
    // * **`srcEid`**: The [Endpoint ID (EID)](https://docs.layerzero.network/v2/deployments/deployed-contracts) of the source blockchain network.
    // * **`receiveLib`**: The address of the incoming message library (such as `ReceiveUln302`).
    // * **`gracePeriod`**: The time or block number to wait before updating versions, or `0` for an immediate switch.

    function setReceiveLibrary(
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

    /**
         * _confirmations — the block-confirmation wait you already understand.
uint8(_requiredDVNs.length) — this isn't a separate input, it's derived from the array you're passing. The library needs to know upfront how many required DVNs to expect before it reads the array itself; you can't just hand it the array and let it infer the count, the struct format has count and content as separate fields.
uint8(0), uint8(0) — optionalDVNCount and optionalDVNT/l./hreshold, hardcoded to zero because your wrapper function doesn't support optional DVNs at all (no parameter for them exists). This is a simplification you baked in — if you later want optional DVN support, you'd need to add parameters for it here instead of hardcoding zero.
_requiredDVNs — the actual array of addresses, the meat of the config.
new address[](0) — an empty array standing in for "optional DVNs," matching the optionalDVNCount: 0 above (count and array need to agree, or the library's decode step would be inconsistent).

The result, ulnConfig, is just a blob of bytes — meaningless on its own until the receiving library decodes it back into a struct using the same field order.
         */
    function setUlnConfig(
        uint32 _srcEid, //where messages are coming from endpoint id
        address _receiveLib, //ReceiveUln302 address for this chain u can find on layer zero deployed endpoints
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
            

            ulnconfig values: 
            struct UlnConfig {
            uint64 confirmations; //15 should be default 
            uint8 requiredDVNCount; //elength of required dvns
            uint8 optionalDVNCount; //optional dvns should be zero empt arrray if optional
            uint8 optionalDVNThreshold;
            address[] requiredDVNs;//u find on layer zero dvn deployed page (use default layer zero one )
            address[] optionalDVNs;//huould be empty no optional dvn
        }
            
                */

        bytes memory ulnConfig = abi.encode(
            _confirmations, //should be 15 by deaultss
            uint8(_requiredDVNs.length), //how many required dvns we are passing in
            uint8(0),
            uint8(0),
            _requiredDVNs,
            new address[](0)
        );

        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam(_srcEid, 2, ulnConfig);

        interfacedEndpoint_.setConfig(address(this), _receiveLib, params);
    }

    function addFactoryMessengerPeers() public {
        for (uint256 i = 0; i < Create3FactoryPeers.length; i++) {
            Create3FactoryPeerInfo
                memory currentMessenger = Create3FactoryPeers[i];
            bytes32 messengerAddr = VaultHelper.addrToBytes32(
                currentMessenger.messengerAddr
            );
            _setPeer(currentMessenger.endpointId, messengerAddr);
            setReceiveLibrary(
                currentMessenger.endpointId,
                currentMessenger._receiveLib,
                uint32(0)
            );
            setUlnConfig(
                currentMessenger.endpointId,
                currentMessenger._receiveLib,
                currentMessenger._requiredDVNs, //fix list of trusted message verifiers its on dvn page layer zero
                uint64(15) //fix 15 by deafault
            );
        }
    }

    function flush(address reciever) public payable {
        payable(reciever).call{value: address(this).balance}("");
    }

    function setMessengerPeer(
        uint32 _eid,
        address _peer,
        uint256 index,
        address _receiveLib,
        address[] memory _requiredDVNs, //purpose: who do you trust to tell you a message is real?
        uint64 _confirmations //purpose: how sure do you need to be that the source chain won't reorg) public {
    ) public {
        uint32 _gracePeriod = 0;
        bytes32 convertedPeerAddr = addressToBytes(_peer);
        _setPeer(_eid, convertedPeerAddr);
        setReceiveLibrary(
            Create3FactoryPeers[index].endpointId,
            Create3FactoryPeers[index]._receiveLib,
            _gracePeriod
        );
        setUlnConfig(_eid, _receiveLib, _requiredDVNs, _confirmations);
    }

    function addressToBytes(address _addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function getCREATE3FactoryPeer(
        uint256 index
    ) public view returns (Create3FactoryPeerInfo memory) {
        return Create3FactoryPeers[index];
    }

    function setCREATE3FACTORY(Create3FactoryPeerInfo memory _peer) public {
        Create3FactoryPeers.push(_peer);
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

    function pushCREATE3FactoryPeer(
        Create3FactoryPeerInfo memory _Create3FactoryPeer
    ) public {
        Create3FactoryPeers.push(_Create3FactoryPeer);
    }

    function getFactoryInfo() public view returns (Factory memory) {
        return EVMFACTORYINFO;
    }

    //in order to recieve my fundign for tests contracts must always have this fucntion
    receive() external payable {}

    function getMessengerDeployQuote(
        uint256 index
    ) public view returns (uint256 total, MessagingFee memory fees) {
        // fees = new MessagingFee[](Create3FactoryPeers.length);
        bytes memory message = abi.encodeWithSignature(
            "factoryInitDeployment(bytes32,bytes)",
            EVMFACTORYINFO.factory.salt,
            EVMFACTORYINFO.factory.creationCode
        );
        bytes memory options = buildOptions();
        //fix properly add options and check for paying ith layerzero token
        MessagingFee memory fee = messageQuote(
            Create3FactoryPeers[index].endpointId,
            message,
            options,
            false
        );
        fees = (fee);

        total += fee.nativeFee;
    }

    function buildOptions() public pure returns (bytes memory) {
        return
            //gas limit should be reaosnable1500000ether
            OptionsBuilder.newOptions().addExecutorLzReceiveOption(
                1_900_000,
                0
            );
    }

    function _combineOptions(
        uint32 _eid,
        uint16 _msgType,
        bytes memory _extraOptions
    ) internal view returns (bytes memory) {
        bytes memory enforced = enforcedOptions[_eid][_msgType];

        // If no enforced options exist for this destination, return your generated loop options directly
        if (enforced.length == 0) {
            return _extraOptions;
        }

        // If loop options are empty, return the contract's enforced presets
        if (_extraOptions.length == 0) {
            return enforced;
        }

        // FIXED: Changed string() to bytes() to match the return type
        return bytes(abi.encodePacked(enforced, _extraOptions));
    }

    function _combineOptionsWrapped(
        uint32 _eid,
        uint16 _msgType,
        bytes calldata _extraOptions
    ) external view returns (bytes memory) {
        return combineOptions(_eid, _msgType, _extraOptions);
    }
    function getMessengerDeployQuotes()
        public
        view
        returns (uint256 total, MessagingFee[] memory fees)
    {
        fees = new MessagingFee[](Create3FactoryPeers.length);
        for (uint256 i = 0; i < Create3FactoryPeers.length; i++) {
            Create3FactoryPeerInfo
                memory currentMessenger = Create3FactoryPeers[i];
            bytes memory message = abi.encodeWithSelector(
                Create3FactoryMessenger.factoryInitDeployment.selector,
                EVMFACTORYINFO.factory.salt,
                EVMFACTORYINFO.factory.creationCode
            );
            // 1. Dynamic generation stays in memory

            // 2. Safe Assembly Pointer Overriding (Memory -> Calldata pointer mapping)

            bytes memory options = buildOptions();
            //fix properly add options and check for paying ith layerzero token
            MessagingFee memory fee = messageQuote(
                currentMessenger.endpointId,
                message,
                options,
                false
            );
            fees[i] = (fee);

            total += fee.nativeFee;
        }
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

    uint256 currentId = 0;

    //be careful how u make salts it can causecontracts not to deploy i used timestamp earlier wouldnt dpeoy
    function generateUniqueSalt(string memory name) public returns (bytes32) {
        ++currentId;

        return keccak256(abi.encodePacked(name, currentId));
    }

    function storeCREATE3Factory(
        bytes32 salt,
        bytes memory creationCode,
        address factoryAddr,
        bool isEVM,
        uint256 deployedChain
    ) public {
        FactoryInfo memory info = FactoryInfo(salt, creationCode, factoryAddr);
        EVMFACTORYINFO.isEVM = isEVM;
        EVMFACTORYINFO.factory = info;
        EVMFACTORYINFO.chains.push(deployedChain);
    }

    //only called once and upon deplyoment only
    function deployFactory(
        bytes memory creationCode,
        string memory name
    ) public returns (address) {
        bytes32 salt = generateUniqueSalt(name);
        //this is how we pass in constructor args to .deploy

        (address deployed) = factory.deploy(salt, creationCode);
        storeCREATE3Factory(salt, creationCode, deployed, true, block.chainid);
        return deployed; //returns deployed determisitic
        //      address _endpoint,
        // address _delegate,Eendpoint, delegate, endpointId, Create3FactoryPeers
        // uint32 _endpointId,
        // Create3FactoryPeerInfo[] memory _Create3FactoryPeers
    }

    function getEVMFACTORYINFO() public view returns (Factory memory) {
        return EVMFACTORYINFO;
    }

    function deployFactoryPeer(
        uint256 i,
        uint256 total,
        MessagingFee memory fee
    ) public payable returns (bool) {
        require(msg.value == total, "not enough");
        bytes memory message = abi.encodeWithSignature(
            "factoryInitDeployment(bytes32,bytes)",
            EVMFACTORYINFO.factory.salt,
            EVMFACTORYINFO.factory.creationCode
        );

        // 3. Pass the casted pointer to combineOptions (Resolves Error 9553)
        bytes memory options = buildOptions();
        sendMessage(
            Create3FactoryPeers[i].endpointId,
            message,
            options,
            fee,
            payable(msg.sender)
        );
        return true;
    }

    function deployFactoryPeersBulk(
        uint256 total,
        address caller,
        MessagingFee[] memory fees
    ) public payable returns (bool) {
        require(msg.value == total, "not enough");
        //make custom modifier to verifiy amount is total of fees call message quoter again modifier to proerly verify
        for (uint256 i = 0; i < Create3FactoryPeers.length; i++) {
            Create3FactoryPeerInfo
                memory currentMessenger = Create3FactoryPeers[i];
            bytes memory message = abi.encodeWithSelector(
                Create3FactoryMessenger.factoryInitDeployment.selector,
                EVMFACTORYINFO.factory.salt,
                EVMFACTORYINFO.factory.creationCode
            );
            // 1. Dynamic generation stays in memory
            bytes memory options = buildOptions();
            //fix options bytes("") shoudl be proper options and pay in lz
            //also check fees[] should not conflict verify length and validity or call bulk quoter again
            sendMessage(
                currentMessenger.endpointId,
                message,
                options,
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
    ) public payable returns (bool) {
        (MessagingReceipt memory receipt) = _lzSend(
            _dstEid,
            _message,
            _options,
            _fee,
            _refundAddress
        );
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

/**
 * trace error: 
 * Traces:
  [151335] Create2Deployer::create2()
    ├─ [118990] → new VaultHelper@0xAc84B2a1d251218be62d4d0683aeBA09cD734a3F
    │   └─ ← [Return] 594 bytes of code
    └─ ← [Return] 0xac84b2a1d251218be62d4d0683aeba09cd734a3f

  [6462747] → new VaultFactoryTest@0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519
    └─ ← [Return] 32161 bytes of code

  [122] VaultFactoryTest::setUp()
    └─ ← [Stop]

  [144091] VaultFactoryTest::run()
    ├─ [0] VM::startBroadcast()
    │   └─ ← [Return]
    ├─ [100947] → new <unknown>@0xB985501503d7758f9484aAaCF14766B1ae14bb62
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d)
    │   ├─ [23959] 0x6EDCE65403992e310A62460808c4b910D972f10f::setDelegate(0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d)
    │   │   ├─ emit DelegateSet(sender: 0xB985501503d7758f9484aAaCF14766B1ae14bb62, delegate: 0xa24e1426Bc37d0D1a9e7037f5De3322E800F2D7d)
    │   │   └─ ← [Stop]
    │   └─ ← [Revert] 0x4e487b710000000000000000000000000000000000000000000000000000000000000011
    └─ ← [Revert] panic: arithmetic underflow or overflow (0x11)



 */
