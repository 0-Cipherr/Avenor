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
            peer.endpointId,
            peer.endpoint,
            endpoint,
            delegate,
            endpointId,
            1
        );
        uint256 num = 0;
        initialSetters(params);
        // factoryDeployer.DeployQuote memory quote = getDeployQuote(index);
        // deployPeer(index, quote);
        vm.stopBroadcast();
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
                0x39373a4869e6c9dbF4b3dF808b4631E47bC2F869, //messenger addr
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
            uint32 endpointId,
            uint256 _num
        ) = abi.decode(
                _params,
                (
                    factoryDeployer.Create3FactoryPeerInfo,
                    uint32,
                    address,
                    address,
                    address,
                    uint32,
                    uint256
                )
            );
        deployer = new factoryDeployer(delegate, endpoint, endpointId);
        deployer.storePeer(peerEndpointId, peerEndpoint);
        deployer.storeCreate3FactoryPeer(peer); //adds the messenger peer

        console.log("deployed deployer");
        console.logAddress(address(deployer));
        console.log("stored peer endpoint:");
        console.logAddress(peerEndpoint);
        console.log("Stored endpoint id");
        console.logUint(peerEndpointId);
    }

    function deployCrossChain(uint256 _num) public {
        deployCreate3Factory(_num);
        console.log("Deploy successful");
    }

    function deployCreate3Factory(uint256 _num) public {
        CREATE3FACTORY _factory = new CREATE3FACTORY();
        bytes memory creationCode = type(CREATE3FACTORY).creationCode;
        deployer.setNativeFactory(_factory);
        deployer.setFactoryCreationCode(creationCode);
        deployer.deployDeterministicFactoryNative(_num);
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
