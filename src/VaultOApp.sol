// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract VaultOApp is Ownable, OApp {
    address vaultRegistryMessenger;
    constructor(address _endpoint, address _delegate) Ownable(_delegate) OApp(_endpoint, _delegate) {}

    function setVaultRegistryMessenger(address _vaultRegistryMessenger) public {
        vaultRegistryMessenger = _vaultRegistryMessenger;
    }

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
