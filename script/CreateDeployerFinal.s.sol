// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CREATE3FACTORY} from "../src/CREATE3FACTORY.sol";
import "forge-std/console.sol";
import {Create3Deployer} from "../src/Create3Deployer.sol";
import {ICREATE3FACTORY} from "../src/ICREATE3FACTORY.sol";
import {Create3FactoryMessenger} from "../src/Create3FactoryMessenger.sol";
import {
    MessagingFee,
    MessagingReceipt
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
/**
 * template format for runing script 
forge script script/VaultFactoryTest.s.sol --rpc-url https://base-sepolia.gateway.tenderly.co --account Avenor_Multi --broadcast
forge script script/FactoryMesengerScript.s.sol --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast 
forge script script/FactoryMesengerScript.s.sol --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast && forge script script/VaultFactoryTest.s.sol --rpc-url https://base-sepolia.gateway.tenderly.co --account Avenor_Tetnet --broadcast
forge script script/CreateDeployerFinal.s.sol --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast --tc CreateDeployerFinal
forge script script/CreateDeployerFinal.s.sol --rpc-url https://base-sepolia.gateway.tenderly.co --account Avenor_Multi --broadcast --tc CreateDeployerFinal






factory messenger deployment logs:
== Logs ==
  Deployed Messenger Address:
  0x9F17fa841bAF641bfE4F969A20f5dff30890CBCE
  Endpoint Deployed at:
  0x6EDCE65403992e310A62460808c4b910D972f10f
  Endpoint id Deployed at:
  40231
  Chain Id:
  421614

## Setting up 1 EVM.



.


== Logs ==
  Deployed deployer addr:
  0x9062B83ccC52faa9eb74a4d72Be68923323D9c39
  Determistic create 3 deployed:
  0x649c73116b3df1a9B1406421D82540F9b53C6c49
  Deployed Factory Address:
  0x649c73116b3df1a9B1406421D82540F9b53C6c49
  SALT:
  0x00ec7745f44a3a8f867e60a3c6bedc9be63ba7456732a7189419a4380b870389
  Initial create3Factory Address:
  0x6690dB1c8Dd95A7e994f9d19ab5d33619B908c8D

## Setting up 1 EVM.







 forge script script/CreateDeployerFinal.s.sol --rpc-url https://base-sepolia.gateway.tenderly.co --account Avenor_Multi --broadcast --tc CreateDeployerFinal.s.sol



 */

contract CreateDeployerFinal is Script {
    Create3FactoryMessenger messenger;
    Create3Deployer deployer;
    Create3Deployer deterministicDeployer;

    function run() public {
        vm.startBroadcast();

        // STEP 1:
        // setMessenger(
        //     Create3FactoryMessenger(
        //         payable(0x9F17fa841bAF641bfE4F969A20f5dff30890CBCE)
        //     )
        // );

        // setMessengerPeer(40245, 0x9062B83ccC52faa9eb74a4d72Be68923323D9c39);
        // messenger.flush(msg.sender);
        //STEP 2:

        setDeployer(
            Create3Deployer(payable(0x9062B83ccC52faa9eb74a4d72Be68923323D9c39))
        );
        // Create3Deployer.Create3FactoryPeerInfo memory info = getPeer(0);
        // console.log("=== Create3FactoryPeerInfo ===");

        // console.log("Endpoint:");
        // console.logAddress(info.endpoint);

        // console.log("Messenger Address:");
        // console.logAddress(info.messengerAddr);

        // console.log("Endpoint ID:");
        // console.logUint(uint256(info.endpointId));

        // console.log("Chain ID:");
        // console.logUint(info.chainId);

        // console.log("==============================");
        // deployer.flush(msg.sender); // use in step3 too

        setDeployerPeer(40231, 0x9F17fa841bAF641bfE4F969A20f5dff30890CBCE);

        //STEP 3:
        /**gets quote and deplyos factory iwth same address n another chain  */
        (
            uint256 totalAmount,
            MessagingFee memory feesList
        ) = getDeployFactoriesQuote();
        console.log("Total:");
        console.logUint(totalAmount);
        console.log("NATIVE FEE");
        console.logUint(feesList.nativeFee);
        deployDeployerFactories(totalAmount, msg.sender, feesList);

        //used to test the dpeloyment works on determistic:
        // testDeterministicFactory(0xb59c8b0EC1bA61410319A7D6a69696F3A8f86222);
        vm.stopBroadcast();
    }

    function testDeterministicFactory(address deterministic) public {
        ICREATE3FACTORY factoryDeterministic = ICREATE3FACTORY(deterministic);

        bytes32 salt = keccak256(abi.encodePacked("MyUniqueSaltString"));

        address deployed = factoryDeterministic.deploy(
            salt,
            type(TestContract).creationCode
        );

        console.log("Deployed contract address:");
        console.logAddress(deployed);

        console.log("Code length:");
        console.logUint(deployed.code.length);

        console.log("Chain id:");
        console.logUint(block.chainid);

        require(deployed.code.length > 0, "DEPLOY FAILED");
    }

    function setDeterministicDeployer(
        Create3Deployer _deterministicDeployer
    ) public {
        deterministicDeployer = _deterministicDeployer;
    }

    function setDeployer(Create3Deployer _deplyoer) public {
        deployer = _deplyoer;
    }

    function getFactoryInfo()
        public
        view
        returns (Create3Deployer.Factory memory)
    {
        return deployer.getFactoryInfo();
    }

    function setMessenger(Create3FactoryMessenger _messenger) public {
        messenger = _messenger;
    }

    function setMessengerPeer(uint32 _eid, address _peer) public {
        messenger.setMessengerPeer(_eid, _peer);
    }
    function setDeployerPeer(uint32 _eid, address _peer) public {
        deployer.setMessengerPeer(_eid, _peer);
    }
    function getDeployFactoriesQuote()
        public
        view
        returns (uint256 totalAmount, MessagingFee memory feesList)
    {
        (uint256 total, MessagingFee memory fees) = deployer
            .getMessengerDeployQuote(0);

        totalAmount = total;
        feesList = fees;
    }

    function getPeer(
        uint256 index
    ) public view returns (Create3Deployer.Create3FactoryPeerInfo memory) {
        return deployer.getCREATE3FactoryPeer(index);
    }

    function deployDeployerFactories(
        uint256 total,
        address _caller,
        MessagingFee memory fee
    ) public payable {
        deployer.deployFactoryPeer{value: total}(0, total, fee);
    }
}

contract TestContract {
    uint256 public value = 123;
}
