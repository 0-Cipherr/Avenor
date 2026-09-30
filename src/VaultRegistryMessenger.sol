// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVaultManager} from "./IVaultManager.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {VaultHelper} from "../src/VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultHelper} from "./VaultHelper.sol";

contract VaultRegistryMessenger is Ownable, OApp {
    address authorized;
    address vaultRegistry; //should be vault registr interface not address for now
    bool PAYINLZTOKEN = false;

    //already a endpoitn and delegate variables in oapp incae we need them
    constructor(
        address _endpoint,
        address _delegate
    ) Ownable(_delegate) OApp(_endpoint, _delegate) {}

    function setVault(address _vaultRegistry) public {
        vaultRegistry = _vaultRegistry;
    }

    function textVault(
        MessagingHelper.ComposedMessage memory _composedMessage
    ) public {
        _lzSend(
            _composedMessage._dstEid,
            _composedMessage._message,
            _composedMessage._options,
            _composedMessage._fee,
            _composedMessage._refundAddress
        );
    }

    function textQuote(
        MessagingHelper.ComposedMessageQuote memory _quoteParams
    ) public returns (MessagingHelper.ComposedMessage memory composedMessage) {
        bytes memory _options = createOptions();
        MessagingFee memory fee = _quote(
            _quoteParams._dstEid,
            _quoteParams._message,
            _options,
            PAYINLZTOKEN
        );

        return
            composedMessage = constructComposedMessage(
                _quoteParams._dstEid,
                fee,
                _quoteParams._message,
                _options,
                PAYINLZTOKEN,
                _quoteParams._refundAddress
            );
    }

    function constructComposedMessage(
        uint32 _dstEid,
        MessagingFee memory _fee,
        bytes memory _message,
        bytes memory _options,
        bool payInLzToken,
        address _refundAddress
    )
        public
        pure
        returns (MessagingHelper.ComposedMessage memory composedMessage)
    {
        composedMessage = MessagingHelper.ComposedMessage(
            _dstEid,
            _fee,
            _message,
            _options,
            payInLzToken,
            _refundAddress
        );
    }

    //logic to be executed on desitnatioon chain
    /**
     * layer zero doc notes:
     * its a structured byte array that contain multiple nstructions for desitnaton chain
     * these options are forwarded the the service provider on destination endpoint (workers) such as :
     *  Decentralized Verifier Networks (DVNs): These provide verification to ensure the message is valid and has not been tampered with.
     * Executors: These are responsible for delivering and executing the message on the destination chain.
     * -its important to note what i stated above is alread  created and deployed by layer zero:
     * to find go to the dpeloed endpoints list layer zero has
     * Options are how applications communicate verification and execution preferences to the off-chain workers that carry out crosschain messages.
     */
    function createOptions() public returns (bytes memory) {} //create proper options for vaults so messages are sent properly

    function textVault(
        MessagingHelper.ComposedMessage memory composedMessage
    ) public {
        _lzSend(
            composedMessage._dstEid,
            composedMessage._message,
            composedMessage._options,
            composedMessage._fee,
            composedMessage._refundAddress
        );
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
    ) internal override {
        // handle incoming LayerZero message
        (bool success, ) = address(this).call(_message);

        require(success, "Message recieved but tx reverted!");
    }
}

// forge build --sizes for size stats
