// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessagingHelper} from "../src/MessagingHelper.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {OAppUpgradeable} from "../lib/devtools/packages/oapp-evm-upgradeable/contracts/oapp/OAppUpgradeable.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {SetConfigParam} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import {ExecutorConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

contract VaultOApp is Ownable, OApp {
    using OptionsBuilder for bytes;
    bool PAYINLZTOKEN = false;

    address vaultRegistryMessenger;
    address authorized;

    modifier onlyAUhtorized(address attemptedUser) {
        require(attemptedUser == authorized, "Not authrized to perform ");
        _;
    }
    address creator;

    constructor(address _endpoint, address _delegate, address _creator) Ownable(_delegate) OApp(_endpoint, _delegate) {
        creator = _creator;
    }

    function updateAuthorized(address _delegate) public {
        authorized = _delegate;
    }

    function setVaultRegistryMessenger(address _vaultRegistryMessenger) public {
        vaultRegistryMessenger = _vaultRegistryMessenger;
        updateAuthorized(_vaultRegistryMessenger);
    }

    function configureSendPath(
        uint32 dstEid,
        address sendLibrary,
        address executor,
        uint32 maxMessageSize,
        uint64 confirmations,
        address requiredDvn
    ) external onlyOwner {
        address[] memory requiredDvns = new address[](1);
        requiredDvns[0] = requiredDvn;

        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam({
            eid: dstEid,
            configType: 1, // Executor
            config: abi.encode(ExecutorConfig({maxMessageSize: maxMessageSize, executor: executor}))
        });
        params[1] = SetConfigParam({
            eid: dstEid,
            configType: 2, // ULN/DVN
            config: abi.encode(
                UlnConfig({
                    confirmations: confirmations,
                    requiredDVNCount: 1,
                    optionalDVNCount: type(uint8).max, // explicitly no optional DVNs
                    optionalDVNThreshold: 0,
                    requiredDVNs: requiredDvns,
                    optionalDVNs: new address[](0)
                })
            )
        });

        endpoint.setConfig(address(this), sendLibrary, params);
    }

    function setPeerOApp(uint32 _eid, bytes32 _peer) public virtual onlyAUhtorized(msg.sender) {
        // 1. Enforce your custom restriction logic instead of 'onlyOwner'

        // 2. Directly update the internal tracking mapping from OAppCore
        setPeer(_eid, _peer);
        emit PeerSet(_eid, _peer);
    }

    function text(MessagingHelper.ComposedMessage memory _composedMessage) public payable {
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

    function quoteText(MessagingHelper.ComposedMessageQuote memory _quoteParams)
        public
        view
        returns (MessagingHelper.ComposedMessage memory composedMessage)
    {
        bytes memory _options = createOptions();

        MessagingFee memory fee = _quote(_quoteParams._dstEid, _quoteParams._message, _options, PAYINLZTOKEN);

        return constructComposedMessage(
            _quoteParams._dstEid, fee, _quoteParams._message, _options, PAYINLZTOKEN, _quoteParams._refundAddress
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
    ) public pure returns (MessagingHelper.ComposedMessage memory composedMessage) {
        composedMessage = MessagingHelper.ComposedMessage(
            _dstEid, _fee, _message, _options, payInLzToken, _refundAddress
        );
    }

    function validateBulkQuote(MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection)
        public
        pure
        returns (bool)
    {
        bool isValid = false;

        for (uint256 i = 0; i < _quoteParamsCollection.length; i++) {}

        return isValid;
    }

    function bulkTextQuote(MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection)
        public
        returns (MessagingHelper.ComposedMessage[] memory _composedMessage)
    {
        bool isValid = validateBulkQuote(_quoteParamsCollection);
        if (isValid) {
            for (uint256 i = 0; i < _quoteParamsCollection.length; i++) {
                MessagingHelper.ComposedMessageQuote memory currentMessage = _quoteParamsCollection[i];
                MessagingHelper.ComposedMessage memory quote = quoteText(currentMessage);

                _composedMessage[i] = (quote);
            }
        }
    }

    function createOptions() public pure returns (bytes memory) {
        // Now this syntax will compile perfectly
        return OptionsBuilder.newOptions().addExecutorLzReceiveOption(3_000_000, 0);
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
        (bool success,) = address(vaultRegistryMessenger).call(_message);

        require(success, "Message recieved but tx reverted!");
    }
}
