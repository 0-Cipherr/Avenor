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
        factoryDeployer.Create3FactoryPeerInfo memory peer = getPeer();
        address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        address delegate = msg.sender;
        uint32 endpointId = 40245;

        bytes memory params = abi.encode(
            peer,
            peer.endpointId,
            peer.endpoint,
            endpoint,
            delegate,
            endpointId
        );
        uint256 num = 0;
        // initialSetters(params);
        // deployCreate3Factory(num);
        deployer = factoryDeployer(0x1eEB9c27e93012a01907E7df3Fee5e1C722EeDA8);
        factoryDeployer.DeployQuote memory quote = getDeployQuote(num);
        deployPeer(num, quote);
        printQuote(quote);
        vm.stopBroadcast();
    }

    function printQuote(factoryDeployer.DeployQuote memory quote) public pure {
        console.log("Fee:");
        console.logUint(quote.fee.nativeFee);
        console.log("Destination endpoint id:");
        console.logUint(quote.dstEid);
    }

    function getPeer()
        public
        view
        returns (factoryDeployer.Create3FactoryPeerInfo memory)
    {
        //replace values with existing ones
        return
            factoryDeployer.Create3FactoryPeerInfo(
                0x6EDCE65403992e310A62460808c4b910D972f10f,
                0x4D175489c4e80B0C5Db20567db2fD569392A94c7, //messenger addr
                40231,
                421614,
                block.timestamp,
                false
            );
    }

    function initialSetters(bytes memory _params) public {
        (
            factoryDeployer.Create3FactoryPeerInfo memory peer,
            uint32 peerEndpointId,
            address peerEndpoint,
            address endpoint,
            address delegate,
            uint32 endpointId
        ) = abi.decode(
                _params,
                (
                    factoryDeployer.Create3FactoryPeerInfo,
                    uint32,
                    address,
                    address,
                    address,
                    uint32
                )
            );
        deployer = new factoryDeployer(delegate, endpoint, endpointId);
        deployer.storePeer(peerEndpointId, peer.messengerAddr);
        deployer.storeCreate3FactoryPeer(peer); //adds the messenger peer

        console.log("deployed deployer");
        console.logAddress(address(deployer));
        console.log("stored peer endpoint:");
        console.logAddress(peerEndpoint);
        console.log("Stored endpoint id");
        console.logUint(peerEndpointId);
    }

    function deployCreate3Factory(uint256 _num) public {
        CREATE3FACTORY _factory = new CREATE3FACTORY();
        bytes memory creationCode = type(CREATE3FACTORY).creationCode;
        deployer.setNativeFactory(ICREATE3FACTORY(_factory));
        deployer.setFactoryCreationCode(creationCode);
        deployer.deployDeterministicFactoryNative(_num);
        ICREATE3FACTORY deployed = deployer.getDeterministicFactory();
        console.log("Deterministic CREATE3Factory Deployed:");
        console.logAddress(address(deployed));
    }

    function getDeployQuote(
        uint256 index
    ) public view returns (factoryDeployer.DeployQuote memory) {
        factoryDeployer.DeployQuote memory quote = deployer.deployPeerQuote(
            index
        );
        console.log("Fee to pay:");
        console.logUint(quote.fee.nativeFee);

        return quote;
    }

    function deployPeer(
        uint256 index,
        factoryDeployer.DeployQuote memory quote
    ) public payable {
        deployer.deployFactoryCrossChain{value: quote.fee.nativeFee}(
            index,
            quote
        );

        console.log("Peer deployment requested:");
        console.log("Requested to endpoint id: ");
        console.logUint(quote.dstEid);
        console.log("Fee paid:");
        console.logUint(quote.fee.nativeFee);
        //       struct DeployQuote {
        //     uint32 dstEid;
        //     bytes message;
        //     bytes options;
        //     MessagingFee fee;
        //     address refundAddress;
        // }
    }
}
