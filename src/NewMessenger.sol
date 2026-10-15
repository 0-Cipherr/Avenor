// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVaultManager} from "./IVaultManager.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultHelper} from "./VaultHelper.sol";

import {VaultOApp} from "./VaultOApp.sol";
import {IVaultRegistry} from "./IVaultRegistry.sol";

//messenger used to handle vault messaging in the vault regitry
//comminicate messenger t messenger
contract VaultRegistryMessenger is Ownable, OApp {
    constructor(address _endpoint, address _delegate) Ownable(_delegate) OApp(_endpoint, _delegate) {}

    function bulkTextQuote() public {}

    function addPeer() public {}

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
