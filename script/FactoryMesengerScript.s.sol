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

contract FactoryMesengerScript is OApp, OAppOptionsType3 {
    using OptionsBuilder for bytes;
    using VaultHelper for address;
    using VaultHelper for bytes32;
    Create3FactoryMessenger messengerDeployed;
    function setUp() public {}
    ///left off deployinon another chain making sure address is the same
    function run() public {
        vm.startBroadcast();
        //settings for arbitrum seploia
        address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        address delegate = msg.sender;
        uint32 endpointId = 40231;
        address[] memory dvns = new address[](2);
        dvns[0] = 0x53f488E93b4f1b60E8E83aa374dBe1780A1EE8a8;
        dvns[1] = 0x5C8C267174e1F345234FF5315D6cfd6716763BaC;
        deployFactoryMessenger(
            endpoint,
            delegate,
            0x75Db67CDab2824970131D5aa9CECfC9F69c69636,
            uint32(0),
            dvns
        );
        (bool success, ) = address(messengerDeployed).call{value: 0.01 ether}(
            ""
        );
        require(success, "ETH Transfer Failed");
        vm.stopBroadcast();
    }

    function deployFactoryMessenger(
        address _endpoint,
        address _delegate,
        address _receiveLib,
        uint32 _gracePeriod,
        address[] memory _requiredDVNs
    ) public {
        messengerDeployed = new Create3FactoryMessenger(
            _endpoint,
            _delegate,
            _receiveLib,
            _gracePeriod,
            _requiredDVNs
        );

        console.log("Deployed Messenger Address:");
        console.logAddress(address(messengerDeployed));
        console.log("Endpoint Deployed at:");
        console.logAddress(_endpoint);

        console.log("Chain Id:");
        console.logUint(block.chainid);
    }
}
