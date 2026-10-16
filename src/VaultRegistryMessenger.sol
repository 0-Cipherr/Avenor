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
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {SetConfigParam} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import {ExecutorConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

//messenger used to handle vault messaging in the vault regitry
//comminicate messenger t messenger
contract VaultRegistryMessenger is Ownable, OApp {
    using OptionsBuilder for bytes;
    address authorized;
    bool PAYINLZTOKEN = false;
    IVaultRegistry vaultRegistry; //should be vault registr interface not address for now
    uint32 maxMessageSize;
    uint64 confirmations;
    address sendLibrary;
    address requiredDvn;
    address executor;
    mapping(uint256 => VaultHelper.Destination) deployedOApps;
    modifier onlyAuhtorized(address attemptedUser) {
        require(attemptedUser == authorized || attemptedUser == address(vaultRegistry), "Not authrized to perform ");
        _;
    }
    modifier onlyVaultExists(uint256 _vaultId) {
        bool isActive = deployedOApps[_vaultId].isActive;

        require(isActive, "Vault does not exist");
        _;
    }

    constructor(
        address _endpoint,
        address _delegate,
        uint32 _maxMessageSize,
        uint64 _confirmations,
        address _sendLibrary,
        address _requiredDvn,
        address _executor
    ) Ownable(_delegate) OApp(_endpoint, _delegate) {
        maxMessageSize = _maxMessageSize;
        confirmations = _confirmations;
        sendLibrary = _sendLibrary;
        requiredDvn = _requiredDvn;
        executor = _executor;
    }

    function newOwner(address owner) public {
        transferOwnership(owner);
    }

    function updateMaxMessagingSize(uint32 _newSize) public {
        maxMessageSize = _newSize;
    }

    function updateuahtorized(address _authorized) public {
        authorized = _authorized;
    }

    function setVault(address _vaultRegistry) public {
        vaultRegistry = IVaultRegistry(_vaultRegistry);
        updateuahtorized(_vaultRegistry);
    }

    function setVaultDVNNative(uint32 dstEid) public {
        configureSendPath(dstEid);
    }

    function configureSendPath(uint32 dstEid) public onlyOwner {
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

    function textMessengerQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote memory _quoteParams)
        public
        view
        onlyAuhtorized(msg.sender)
        returns (MessagingHelper.ComposedMessage memory composedMessage)
    {
        bytes memory options = createOptions();
        _quoteParams._options = options;

        MessagingFee memory fee = _quote(_quoteParams._dstEid, _quoteParams._message, _quoteParams._options, false);
        composedMessage = MessagingHelper.ComposedMessage(
            _quoteParams._dstEid, fee, _quoteParams._message, _quoteParams._options, false, _quoteParams._refundAddress
        );
    }

    function createOptions() public pure returns (bytes memory) {
        // Now this syntax will compile perfectly
        return OptionsBuilder.newOptions().addExecutorLzReceiveOption(3_000_000, 0);
    }

    function bulkTextRegistriesQuote(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection
    )
        public
        view
        onlyAuhtorized(msg.sender)
        returns (MessagingHelper.ComposedMessage[] memory _composedMessage, uint256 _total)
    {
        _composedMessage = new MessagingHelper.ComposedMessage[](_quoteParamsCollection.length);
        for (uint256 i = 0; i < _quoteParamsCollection.length; i++) {
            MessagingHelper.ComposedMessageQuote memory currentMessage = _quoteParamsCollection[i];
            MessagingHelper.ComposedMessage memory quote = textMessengerQuote(vaultId, currentMessage);

            _composedMessage[i] = (quote);
            _total += quote._fee.nativeFee;
        }
    }

    function bulkText(uint256 vaultId, MessagingHelper.ComposedMessage[] memory _quoteParams)
        external
        payable
        onlyAuhtorized(msg.sender)
        returns (bool)
    {
        for (uint256 i = 0; i < _quoteParams.length; i++) {
            MessagingHelper.ComposedMessage memory _currentQuote = _quoteParams[i];
            textMessengerPeer(vaultId, _currentQuote);
        }

        return true;
    }

    function textMessengerPeer(uint256 vaultId, MessagingHelper.ComposedMessage memory _composedMessage)
        public
        payable
        onlyAuhtorized(msg.sender)
    {
        _lzSend(
            _composedMessage._dstEid,
            _composedMessage._message,
            _composedMessage._options,
            _composedMessage._fee,
            _composedMessage._refundAddress
        );
    }

    function recieveText(bytes memory call) public {
        (bool success,) = address(vaultRegistry).call(call); //forwards call to registry
        require(success, "TX reverted could not execute message!");
    }

    function setMessagePeer(uint32 _eid, bytes32 _peer) internal virtual {
        peers[_eid] = _peer;
        emit PeerSet(_eid, _peer);
    }

    function addPeer(uint32 eid, bytes32 peer) public {
        setMessagePeer(eid, peer);
        setVaultDVNNative(eid);
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
        recieveText(_message);
    }
}
