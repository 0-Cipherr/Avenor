// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {VaultHelper} from "../src/VaultHelper.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CREATE3FACTORY} from "../src/CREATE3FACTORY.sol";
import {ICREATE3FACTORY} from "../src/ICREATE3FACTORY.sol";
import "forge-std/console.sol";
import {Create3FactoryMessenger} from "../src/Create3FactoryMessenger.sol";
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
import {Test as factoryDeployer} from "../src/Test.sol";
/**
 * template format for runing script 
forge script script/MessengerScript.s.sol --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast
/chains with funds sepolia op nd arbitrum
== Logs ==
== Logs ==
  Deployed CREATE3FACTORY:
  0x524975584071152Fbf323B701E34F5fe38B46a72
  Deployed Messenger:
  0x39373a4869e6c9dbF4b3dF808b4631E47bC2F869

## Setting up 1 EVM.


 */

contract MessengerScript is Script {
    CREATE3FACTORY factory;
    Create3FactoryMessenger messenger;

    ///left off deployinon another chain making sure address is the same
    function run() public {
        vm.startBroadcast();
        uint32 peerEndpointId = 40245;
        address peerAddress;
        // address endpoint = address(0x6EDCE65403992e310A62460808c4b910D972f10f);
        // bytes memory initialParams = abi.encode(endpoint);

        // initialSetters(initialParams);

        // console.log("Endpoint deployed on:");
        // console.logAddress(endpoint);
        // console.log("Endpoint id:");

        messenger = Create3FactoryMessenger(
            0x39373a4869e6c9dbF4b3dF808b4631E47bC2F869
        );
        addPeer(peerEndpointId, peerAddress);
        vm.stopBroadcast();
    }

    function initialSetters(bytes memory _params) public {
        (address _endpoint) = abi.decode(_params, (address));
        messenger = new Create3FactoryMessenger(msg.sender, _endpoint);
        deployCreate3Factory();
        console.log("Deployed Messenger:");
        console.logAddress(address(messenger));
    }

    function deployCreate3Factory() public {
        CREATE3FACTORY _factory = new CREATE3FACTORY();
        messenger.setFactory(_factory);
        console.log("Deployed CREATE3FACTORY:");
        console.logAddress(address(_factory));
    }
    function addPeer(uint32 _eid, address _peer) public {
        messenger.storeFactoryPeer(_eid, _peer);
    }
}
