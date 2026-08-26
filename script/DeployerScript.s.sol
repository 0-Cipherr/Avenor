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
import {AvenorFactoryHub as factoryDeployer} from "../src/Test.sol";
/**
 * template format for runing script 
forge script script/DeployerScript.s.sol --rpc-url wss://base-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast

== Logs ==

== Logs ==
  deployed deployer
  0x1eEB9c27e93012a01907E7df3Fee5e1C722EeDA8
  stored peer endpoint:
  0x6EDCE65403992e310A62460808c4b910D972f10f
  Stored endpoint id
  40231
  Deterministic CREATE3Factory Deployed:
  0xe728641Ac40A5A15C6155E43C0DC03282893aebb

## Setting up 1 EVM.






*/

contract DeployerScript is Script {
    CREATE3FACTORY factory;
    factoryDeployer deployer;

    ///left off deployinon another chain making sure address is the same
    function run() public {
        vm.startBroadcast();
        address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        address delegate = msg.sender;
        uint32 endpointId = 40245;
        address _factory;
        deployFactory(delegate, endpoint);
        initialSetters(_factory);

        vm.stopBroadcast();
    }

    function deployFactory(address _creator, address _endpoint) public {
        deplyoer = new factoryDeployer(_creator, _endpoint);
    }

    function initialSetters(ICREATE3FACTORY _factory) public {
        deployer.setFactory(_factory);
        // deployer.addMessenger();
    }
}
