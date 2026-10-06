// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessagingHelper} from "../src/MessagingHelper.sol";
import {
    OwnableUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {
    OAppUpgradeable
} from "../lib/devtools/packages/oapp-evm-upgradeable/contracts/oapp/OAppUpgradeable.sol";

contract VaultOApp is Ownable, OApp {
    bool PAYINLZTOKEN = false;

    address vaultRegistryMessenger;
    address authorized;

    modifier onlyAUhtorized(address attemptedUser) {
        require(attemptedUser == authorized, "Not authrized to perform ");
        _;
    }
    constructor(
        address _endpoint,
        address _delegate
    ) Ownable(_delegate) OApp(_endpoint, _delegate) {}

    function updateAuthorized(address _delegate) public {
        authorized = _delegate;
    }

    function setVaultRegistryMessenger(address _vaultRegistryMessenger) public {
        vaultRegistryMessenger = _vaultRegistryMessenger;
    }

    function text(
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

    function setOAppPeer(uint32 dstEid, bytes32 peer) public {
        setPeer(dstEid, peer);
    }

    function quoteText(
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
            constructComposedMessage(
                _quoteParams._dstEid,
                fee,
                _quoteParams._message,
                _options,
                PAYINLZTOKEN,
                _quoteParams._refundAddress
            );
    }

    //duplicate functiion remove single it  (dup in VaultRegistry )
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

    function validateBulkQuote(
        MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection
    ) public pure returns (bool) {
        bool isValid = false;

        for (uint256 i = 0; i < _quoteParamsCollection.length; i++) {}

        return isValid;
    }

    function bulkTextQuote(
        MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection
    )
        public
        returns (MessagingHelper.ComposedMessage[] memory _composedMessage)
    {
        bool isValid = validateBulkQuote(_quoteParamsCollection);
        if (isValid) {
            for (uint256 i = 0; i < _quoteParamsCollection.length; i++) {
                MessagingHelper.ComposedMessageQuote
                    memory currentMessage = _quoteParamsCollection[i];
                MessagingHelper.ComposedMessage memory quote = quoteText(
                    currentMessage
                );

                _composedMessage[i] = (quote);
            }
        }
    }
    function createOptions() public returns (bytes memory options) {}

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
