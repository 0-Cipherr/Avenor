// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {StrategyHelper} from "./StrategyHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";

import {VaultManager} from "./VaultManager.sol";

import {VaultRegistryManager} from "./VaultRegistryManager.sol";

import {VaultRegistryMessenger} from "../src/VaultRegistryMessenger.sol";
import {VaultFactory} from "./VaultFacotry.sol";
import {IVaultFactory} from "./IVaultFactory.sol";
import {IVaultRegistryMessenger} from "./IVaultRegistryMessenger.sol";
import {IVaultManager} from "./IVaultManager.sol";

contract TempVaultRegistry is Ownable {
    address endpoint;
    uint32 endpointId;
    address delegate;
    address authorized;
    IVaultFactory factory;
    IVaultRegistryMessenger messenger;

    /**
     * _delegate - owner (deployer)
     * _endpoint: registry current endpoitn where  it lives
     * _endpoint id: registry current endpoint id  where it lives
     */
    modifier onlyAuhtorized(address attemptedUser) {
        require(attemptedUser == authorized, "Not authrized to perform ");
        _;
    }

    //deploy factory and registry manager before deploying this we need it to pass in
    constructor(
        address _delegate,
        address _endpoint,
        uint32 _endpointId,
        address _authorized,
        IVaultFactory _factory,
        IVaultRegistryMessenger _messenger
    ) Ownable(_delegate) {
        endpoint = _endpoint;
        endpointId = _endpointId;
        delegate = _delegate;
        factory = _factory;
        messenger = _messenger;
        authorized = _authorized;
    }

    //initialize each dependenc no need to use interface we create here we makign like this to save space on deployment
    //update instead of using its instances deploy before adding and just use its interfaces
    //important we need noted above to save alot of space for dpeloyment

    //sets vault address for each dependency so it can communicate with us especially the messenger
    function setAddressDependencies(address vaultAddress) public onlyAuhtorized(msg.sender) {
        factory.setVault(vaultAddress);
        messenger.setVault(vaultAddress);
    }

    function vaultDeployQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote memory _quoteParams)
        public
        onlyAuhtorized(msg.sender)
        returns (MessagingHelper.ComposedMessage memory _composedMessage)
    {
        _composedMessage = messenger.textQuote(vaultId, _quoteParams);
    }

    function vaultDeploymentsQuote(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection
    ) public onlyAuhtorized(msg.sender) returns (MessagingHelper.ComposedMessage[] memory _composedMessage) {
        _composedMessage = messenger.bulkTextQuote(vaultId, _quoteParamsCollection);
    }

    function deployVault(address _owner, bytes memory deployParams) public returns (uint256) {
        (uint256 vaultCreatedId,) = factory.deployVault(deployParams);

        messenger.registerOapp(_owner, vaultCreatedId);

        return vaultCreatedId;
    }

    function deployVaultsQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote[] memory _composedMessages)
        public
    {
        messenger.bulkTextQuote(vaultId, _composedMessages);
    }

    function deployVaults(uint256 vaultId, MessagingHelper.ComposedMessage[] memory _composedMessages) public {
        bool deployed = messenger.bulkText(vaultId, _composedMessages);

        require(deployed, "Cannot dpeloy vaults multichain");
    }

    function recieveText(uint256 vaultId, bytes memory _text) public {
        (bool success,) = address(this).call(_text); //gotta pass in vault id to call try to encode as well
        require(success, "Text could not execute try again!");
    }

    function stopVault() public onlyAuhtorized(msg.sender) {}

    //flushes vault and returns funds to users immediatley this happens when vault is paused stopped or any sort of hack
    function SOSVault() public onlyAuhtorized(msg.sender) {}
}
