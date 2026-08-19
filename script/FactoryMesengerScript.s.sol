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

contract FactoryMesengerScript is Script {
    CREATE3FACTORY factory;
    factoryDeployer deployer;

    ///left off deployinon another chain making sure address is the same
    function run() public {
        vm.startBroadcast();

        bytes memory params = abi.encode();
        uint256 index = 0;
        initialSetters(params);
        // factoryDeployer.DeployQuote memory quote = getDeployQuote(index);
        // deployPeer(index, quote);
        vm.stopBroadcast();
    }

    function initialSetters(bytes memory _params) public {
        (
            factoryDeployer.Create3FactoryPeerInfo memory peer,
            uint32 _eid,
            address _peer
        ) = abi.decode(
                _params,
                (factoryDeployer.Create3FactoryPeerInfo, uint32, address)
            );
        deployer.storePeer(_eid, _peer);
        deployer.storeCreate3FactoryPeer(peer); //adds the messenger peer

        deployCreate3Factory();
    }

    function deployCreate3Factory() public {
        CREATE3FACTORY _factory = new CREATE3FACTORY();
        bytes memory creationCode = type(CREATE3FACTORY).creationCode;
        deployer.setNativeFactory(_factory);
        deployer.setFactoryCreationCode(creationCode);
        deployer.deployDeterministicFactoryNative(1);
    }

    function getDeployQuote(
        uint256 index
    ) public view returns (factoryDeployer.DeployQuote memory) {
        factoryDeployer.DeployQuote memory quote = deployer.deployPeerQuote(
            index
        );

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
    }
}
