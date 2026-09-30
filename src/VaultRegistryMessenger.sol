// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVaultManager} from "./IVaultManager.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

contract VaultRegistryMessenger is Ownable, OApp {
    address authorized;
    function setVualt() public {}

    //already a endpoitn and delegate variables in oapp incae we need them
    constructor(address _endpoint, address _delegate) Ownable(_delegate) OApp(_endpoint, _delegate) {}

    function textVault() public {}

    function _lzReceive(
        Origin calldata,
        /*_origin*/
        bytes32,
        /*_guid*/
        bytes calldata _message,
        address,
        /**
         * _executor
         */
        bytes calldata //_extraData
    )
        internal
        override
    {
        // handle incoming LayerZero message
        (bool success,) = address(this).call(_message);

        require(success, "Message recieved but tx reverted!");
    }
}

// forge build --sizes for size stats
