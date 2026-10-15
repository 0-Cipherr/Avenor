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

contract VaultRegistryMessenger is Ownable, OApp {
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

    //already a endpoitn and delegate variables in oapp incae we need them
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

    function setVaultDVNNative(uint256 vaultId, uint32 dstEid) public {
        deployedOApps[vaultId].oapp
            .configureSendPath(dstEid, sendLibrary, executor, maxMessageSize, confirmations, requiredDvn);
    }

    function textRegistry(uint256 vaultId, MessagingHelper.ComposedMessage memory _composedMessage)
        public
        payable
        onlyAuhtorized(msg.sender)
        onlyVaultExists(vaultId)
    {
        deployedOApps[vaultId].oapp.text{value: _composedMessage._fee.nativeFee}(_composedMessage);
    }

    //vault should only communicate with registry at all times
    function addPeer(uint256 vaultId, uint32 eid, bytes32 peer)
        public
        onlyAuhtorized(msg.sender)
        onlyVaultExists(vaultId)
    {
        deployedOApps[vaultId].oapp.setPeerOApp(eid, peer);
    }

    function bulkTextRegistryQuote() public {}

    function crossChainDeployVaults() public {}

    function validateBulkQuote(MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection)
        public
        view
        onlyAuhtorized(msg.sender)
        returns (bool)
    {
        bool isValid = false;

        for (uint256 i = 0; i < _quoteParamsCollection.length; i++) {}

        return isValid;
    }

    function setMessengerPeer(uint32 eid, bytes32 peer) public {}

    //fix using deployed vault to interact without it existing
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
            MessagingHelper.ComposedMessage memory quote = deployedOApps[vaultId].oapp.quoteText(currentMessage);

            _composedMessage[i] = (quote);
            _total += quote._fee.nativeFee;
        }
    }

    //instantiaties oapp for every vault created we need to make sperate instances because one peer per oaap per endpoint

    function registerOapp(address _delegate, uint256 vaultId) public onlyAuhtorized(msg.sender) {
        address _endpoint = address(endpoint);
        VaultOApp registeredOApp = new VaultOApp(_endpoint, address(this), _delegate); //rvew this funccton

        registeredOApp.setVaultRegistryMessenger(address(this));
        deployedOApps[vaultId] = VaultHelper.Destination(registeredOApp, vaultId, true);
    }

    function recieveText(bytes memory call) public {
        (bool success,) = address(vaultRegistry).call(call);
        require(success, "TX reverted could not execute message!");
    }

    function textToRegistry(uint256 vaultId, bytes memory text) public onlyAuhtorized(msg.sender) {
        vaultRegistry.recieveText(vaultId, text);
    }

    //fix using deployed vault to interact without it existing
    //nvm works cuz vault will be deployed beofre hand adn registered
    function textRegistryQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote memory _quoteParams)
        public
        onlyAuhtorized(msg.sender)
        returns (MessagingHelper.ComposedMessage memory composedMessage)
    {
        bytes memory options = createOptions();
        _quoteParams._options = options;

        MessagingHelper.ComposedMessage memory fee = deployedOApps[vaultId].oapp.quoteText(_quoteParams);

        composedMessage = fee;
    }

    function bulkText(uint256 vaultId, MessagingHelper.ComposedMessage[] memory _quoteParams)
        external
        payable
        onlyAuhtorized(msg.sender)
        onlyVaultExists(vaultId)
        returns (bool)
    {
        for (uint256 i = 0; i < _quoteParams.length; i++) {
            MessagingHelper.ComposedMessage memory _currentQuote = _quoteParams[i];
            textRegistry(vaultId, _currentQuote);
        }

        return true;
    }

    //duplicate fucntion in VaultOApp
    function constructComposedMessage(
        uint32 _dstEid,
        MessagingFee memory _fee,
        bytes memory _message,
        bytes memory _options,
        bool payInLzToken,
        address _refundAddress
    ) public view onlyAuhtorized(msg.sender) returns (MessagingHelper.ComposedMessage memory composedMessage) {
        composedMessage =
            MessagingHelper.ComposedMessage(_dstEid, _fee, _message, _options, payInLzToken, _refundAddress);
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
    function createOptions() public onlyAuhtorized(msg.sender) returns (bytes memory) {} //create proper options for vaults so messages are sent properly

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
