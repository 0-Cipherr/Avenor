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
import {AvenorFactoryHub as factoryDeployer} from "../src/AvenorFactoryHub.sol";
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
        address _msgrAddr;
        uint32 _msgrEid;
        address _msgrEndpoint;
        factoryDeployer.MessengerInfo memory _msgrInfo = factoryDeployer
            .MessengerInfo(_msgrAddr, _msgrEid, _msgrEndpoint);
        deployFactory(delegate, endpoint);
        initialSetters(ICREATE3FACTORY(address(_factory)), _msgrEid, _msgrInfo);

        vm.stopBroadcast();
    }

    function deployFactory(address _creator, address _endpoint) public {
        deployer = new factoryDeployer(_creator, _endpoint);
    }

    function initialSetters(
        ICREATE3FACTORY _factory,
        uint32 _msgrPeerEid,
        factoryDeployer.MessengerInfo memory __msgrInfo
    ) public {
        deployer.setFactory(_factory);
        deployer.addMessenger(_msgrPeerEid, __msgrInfo);
    }

    function getDeployQuote(
        uint32 _dstEId,
        bytes memory _message,
        bool _payInLzToken
    ) public view returns (MessagingFee memory _quote) {
        _quote = deployer.getMessageQuote(_dstEId, _message, _payInLzToken);
    }

    function deployContractHub(
        address _creator,
        bytes32 salt,
        bytes memory creationCode
    ) public {
        deployer.deployContractHub(_creator, salt, creationCode);
    }

    function deployContractCrossChain(
        MessagingFee memory _quote,
        address _caller,
        bytes32 salt,
        bytes memory creationCode,
        uint32 _dstEid
    ) public {
        deployer.crossChainDeploy(_quote, _caller, salt, creationCode, _dstEid);
    }
}

contract TestContract {
    constructor() {}
}
