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
forge script script/VaultFactoryTest.s.sol --rpc-url https://sepolia.gateway.tenderly.co --account Avenor_Tetnet --broadcast
forge script script/VaultFactoryTest.s.sol --rpc-url https://base-sepolia.gateway.tenderly.co --account Avenor_Tetnet --broadcast


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
        Create3Deployer.Create3FactoryPeerInfo
            memory Create3FactoryPeer = Create3Deployer.Create3FactoryPeerInfo(
                0x6EDCE65403992e310A62460808c4b910D972f10f,
                0xF1BA2bD959776F699cc1071c8AC106dd5B729271,
                40231,
                421614
            );

        peers[0] = Create3FactoryPeer;
        deployFactoryTest(
            0x6EDCE65403992e310A62460808c4b910D972f10f,
            msg.sender,
            peers,
            40232
        );
        (uint256 total, MessagingFee[] memory fees) = factory
            .getMessengerDeployQuote();

        console.log("Fee total to deploy");
        console.logUint(total);
        deployDeteministicFactory(total, fees);
        vm.stopBroadcast();
    }

    function deployFactoryTest(
        address endpoint,
        address delegate,
        Create3Deployer.Create3FactoryPeerInfo[] memory _Create3FactoryPeers,
        uint32 _endpointId
    ) public {
        factory = new Create3Deployer(
            endpoint,
            delegate,
            _endpointId,
            _Create3FactoryPeers
        );
        factory.deployFactory("Default Factory");
        Create3Deployer.Factory memory factoryDeployedInfo = factory
            .getFactoryInfo();

        console.log("Deployed Factory Address:");
        console.logAddress(address(factoryDeployedInfo.factory.factory));

        console.log("SALT:");
        console.logBytes32(factoryDeployedInfo.factory.salt);
        console.log("CREATIONCODE:");
        console.logBytes(factoryDeployedInfo.factory.creationCode);
    }

    function deployDeteministicFactory(
        uint256 total,
        MessagingFee[] memory fees
    ) public payable {
        factory.deployFactories{value: msg.value}(total, msg.sender, fees);
    }
}
