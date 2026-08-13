// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CREATE3FACTORY} from "../src/CREATE3FACTORY.sol";
import "forge-std/console.sol";
import {Create3Deployer} from "../src/Create3Deployer.sol";
import {
    MessagingFee,
    MessagingReceipt
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
/**
 * template format for runing script 
forge script script/VaultFactoryTest.s.sol --rpc-url wss://base-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast



 */

contract VaultFactoryTest is Script {
    Create3Deployer factory;
    function setUp() public {}
    ///left off deployinon another chain making sure address is the same
    function run() public {
        vm.startBroadcast();
        //all parameters are wrong here make sure its right before testing and logic is proper dpeloy factory test is right dont chnage
        //0x6EDCE65403992e310A62460808c4b910D972f10f is base sepolia endpint
        //fill in the array this address in array is wrong put to prevent annoying red error thing
        Create3Deployer.Create3FactoryPeerInfo[]
            memory peers = new Create3Deployer.Create3FactoryPeerInfo[](1);

        //create the necessary struct with information about the messenger we deployed on arbitrum

        Create3Deployer.Create3FactoryPeerInfo
            memory Create3FactoryPeer = Create3Deployer.Create3FactoryPeerInfo(
                0x6EDCE65403992e310A62460808c4b910D972f10f,
                0x5079cb98DE8b4eADF6f921a9b2B02c71e929048e,
                40231,
                421614
            );

        //add it to the peers array to pass into our custom deployer
        peers[0] = Create3FactoryPeer;

        //the create factory on hb is base the factry messenger is deployedon abitrum
        //deploys our deployer adds the peer and calls the peer to deploy matching address
        deployFactoryTest(
            0x6EDCE65403992e310A62460808c4b910D972f10f,
            msg.sender,
            peers,
            40245
        );

        // deployDeteministicFactory(total, fees);
        vm.stopBroadcast();
    }
    //     bytes memory creationCode = abi.encodePacked(
    //     type(Vault).creationCode,
    //     abi.encode(owner, fee)
    // );

    function deployFactoryTest(
        address endpoint,
        address delegate,
        Create3Deployer.Create3FactoryPeerInfo[] memory _Create3FactoryPeers,
        uint32 _endpointId
    ) public {
        CREATE3FACTORY create3factory = new CREATE3FACTORY();
        bytes memory creationCode = type(CREATE3FACTORY).creationCode;

        factory = new Create3Deployer(
            endpoint,
            delegate,
            _endpointId,
            _Create3FactoryPeers,
            create3factory
        );
        (bool success, ) = address(factory).call{value: 0.05 ether}("");
        require(success, "ETH Transfer Failed");
        address deterministicFactory = factory.deployFactory(
            creationCode,
            "Default Factory"
        );

        Create3Deployer.Factory memory factoryDeployedInfo = factory
            .getFactoryInfo();

        console.log("Deployed deployer addr:");
        console.logAddress(address(factory));
        console.log("Determistic create 3 deployed:");
        console.logAddress(deterministicFactory);

        console.log("Deployed Factory Address:");
        console.logAddress(address(factoryDeployedInfo.factory.factory));

        console.log("SALT:");
        console.logBytes32(factoryDeployedInfo.factory.salt);
        console.log("Initial create3Factory Address:");
        console.logAddress(address(create3factory));
    }
}
