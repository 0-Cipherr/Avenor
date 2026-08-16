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
  0x6198D3E0fc96Ecce7AD7c203E28EdFFc85110319
  Endpoint Deployed at:
  0x6EDCE65403992e310A62460808c4b910D972f10f
  Endpoint id Deployed at:
  40231
  Chain Id:
  421614

## Setting up 1 EVM.




== Logs ==
  Deployed deployer addr:
  0xb877c142c4213a78413fcE09279A107379aacC8e
  Determistic create 3 deployed:
  0x10e1CDEf2350c1dDe2fAB521d267e8740d70B522
  Deployed Factory Address:
  0x10e1CDEf2350c1dDe2fAB521d267e8740d70B522
  SALT:
  0x00ec7745f44a3a8f867e60a3c6bedc9be63ba7456732a7189419a4380b870389
  Initial create3Factory Address:
  0xDc9Aa333AE22dfa036D620bAC8081590Ad7F9204

## Setting up 1 EVM.



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
        setMessenger(
            Create3FactoryMessenger(
                payable(0x6198D3E0fc96Ecce7AD7c203E28EdFFc85110319)
            )
        );

        address[] memory dvn = new address[](2);
        dvn[0] = 0xbf6FF58f60606EdB2F190769B951D825BCb214E2;
        dvn[1] = 0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6;

        setMessengerPeer(
            40245,
            0xb877c142c4213a78413fcE09279A107379aacC8e,
            0x12523de19dc41c91F7d2093E0CFbB76b17012C8d,
            uint32(0), //default grace 0
            dvn,
            uint64(15) //default confirmations 15
        );
        // messenger.flush(msg.sender);
        //STEP 2:

        // setDeployer(
        //     Create3Deployer(payable(0xb877c142c4213a78413fcE09279A107379aacC8e))
        // );
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
        // // deployer.flush(msg.sender); // use in step3 too
        // address[] memory deployerdvn = new address[](2);
        // deployerdvn[0] = 0xbf6FF58f60606EdB2F190769B951D825BCb214E2;
        // deployerdvn[1] = 0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6;

        // setDeployerPeer(
        //     40231,
        //     0xbf6FF58f60606EdB2F190769B951D825BCb214E2, //change this on deployment
        //     0,
        //     0x75Db67CDab2824970131D5aa9CECfC9F69c69636,
        //     uint32(0),
        //     deployerdvn,
        //     uint64(15)
        // );

        //STEP 3:
        /**gets quote and deplyos factory iwth same address n another chain  */
        // (
        //     uint256 totalAmount,
        //     MessagingFee memory feesList
        // ) = getDeployFactoriesQuote();
        // console.log("Total:");
        // console.logUint(totalAmount);
        // console.log("NATIVE FEE");
        // console.logUint(feesList.nativeFee);
        // console.log("options");
        // deployDeployerFactories(totalAmount, msg.sender, feesList);

        //used to test the dpeloyment works on determistic:
        testDeterministicFactory(0x10e1CDEf2350c1dDe2fAB521d267e8740d70B522);
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

    function setMessengerPeer(
        uint32 _eid,
        address _peer,
        address _receiveLib,
        uint32 _gracePeriod,
        address[] memory _requiredDVNs, //purpose: who do you trust to tell you a message is real?
        uint64 _confirmations //purpose: how sure do you need to be that the source chain won't reorg) public {) public {
    ) public {
        messenger.setMessengerPeer(
            _eid,
            _peer,
            _receiveLib,
            _gracePeriod,
            _requiredDVNs,
            _confirmations
        );
    }
    function setDeployerPeer(
        uint32 _eid,
        address _peer,
        uint256 index,
        address _receiveLib,
        uint32 _gracePeriod,
        address[] memory _requiredDVNs, //purpose: who do you trust to tell you a message is real?
        uint64 _confirmations //purpose: how sure do you need to be that the source chain won't reorg) public {) public {
    ) public {
        deployer.setMessengerPeer(
            _eid,
            _peer,
            index,
            _receiveLib,
            _requiredDVNs,
            _confirmations
        );
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
