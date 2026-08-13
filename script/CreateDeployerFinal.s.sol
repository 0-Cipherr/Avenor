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
forge script script/CreateDeployerFinal.s.sol --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com --account Avenor_Multi --broadcast
forge script script/CreateDeployerFinal.s.sol --rpc-url https://base-sepolia.gateway.tenderly.co --account Avenor_Multi --broadcast






factory messenger deployment logs:

= Logs ==
  Deployed Messenger Address:
  0x5079cb98DE8b4eADF6f921a9b2B02c71e929048e
  Endpoint Deployed at:
  0x6EDCE65403992e310A62460808c4b910D972f10f
  Endpoint id Deployed at:
  40231
  Chain Id:
  421614

## Setting up 1 EVM.


== Logs ==
  Deployed deployer addr:
  0x38a9b81a3C8E2702b94fB12f3E44374a93EFC416
  Determistic create 3 deployed:
  0x7DB007f829C2feC3714DD8A937e906dCdCA87FF0
  Deployed Factory Address:
  0x7DB007f829C2feC3714DD8A937e906dCdCA87FF0
  SALT:
  0xfa0fbf7933c2a2662e775941739bd30daff37c89371a487c3e81d3ab546c554d
  Initial create3Factory Address:
  0x0e6aa0891Ec162B7c3474042862f7F1108452890

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
        //         payable(0x5079cb98DE8b4eADF6f921a9b2B02c71e929048e)
        //     )
        // );

        // setMessengerPeer(40245, 0x38a9b81a3C8E2702b94fB12f3E44374a93EFC416);

        //STEP 2:

        setDeployer(
            Create3Deployer(payable(0x38a9b81a3C8E2702b94fB12f3E44374a93EFC416))
        );
        // use in step3 too

        // setDeployerPeer(40231, 0x5079cb98DE8b4eADF6f921a9b2B02c71e929048e);

        //STEP 3:
        /**gets quote and deplyos factory iwth same address n another chain  */
        (
            uint256 totalAmount,
            MessagingFee[] memory feesList
        ) = getDeployFactoriesQuote();
        console.log("Total:");
        console.logUint(totalAmount);
        deployDeployerFactories(totalAmount, msg.sender, feesList);

        //used to test the dpeloyment works on determistic:
        // testDeterministicFactory(0x48bBcC635d67099dff95F6Cda7679363Cff60b57);
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
        returns (uint256 totalAmount, MessagingFee[] memory feesList)
    {
        (uint256 total, MessagingFee[] memory fees) = deployer
            .getMessengerDeployQuote();

        totalAmount = total;
        feesList = fees;
    }

    function deployDeployerFactories(
        uint256 total,
        address _caller,
        MessagingFee[] memory fees
    ) public payable {
        deployer.deployFactories{value: total}(total, _caller, fees);
    }
}

contract TestContract {
    uint256 public value = 123;
}
