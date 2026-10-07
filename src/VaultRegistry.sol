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

contract VaultRegistry is Ownable {
    address endpoint;
    uint32 endpointId;
    address delegate;
    address authorized;
    IVaultFactory factory;
    IVaultRegistryMessenger messenger;

    struct RegistryPeerInfo {
        uint32 eid;
        bytes32 peer;
    }

    RegistryPeerInfo[] public peerInfo;

    /**
     * _delegate - owner (deployer)
     * _endpoint: registry current endpoitn where  it lives
     * _endpoint id: registry current endpoint id  where it lives
     */
    modifier onlyAuhtorized(address attemptedUser) {
        require(
            attemptedUser == authorized || attemptedUser == address(this),
            "Not authrized to perform "
        );
        _;
    }

    modifier vaultExists(uint256 vaultId) {
        bool isVaultValid = factory.verifyVault(vaultId);

        require(isVaultValid, "Vault is not valid!");
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
        setAddressDependencies(address(this));
    }

    function getVault(
        uint256 vaultId
    ) public view returns (VaultHelper.Vault memory) {
        return factory.getvault(vaultId);
    }

    function getVaultAddress(
        uint256 vaultId
    ) public view vaultExists(vaultId) returns (address) {
        return factory.getVaultAddress(vaultId);
    }

    //initialize each dependenc no need to use interface we create here we makign like this to save space on deployment
    //update instead of using its instances deploy before adding and just use its interfaces
    //important we need noted above to save alot of space for dpeloyment

    //sets vault address for each dependency so it can communicate with us especially the messenger
    function setAddressDependencies(address vaultAddress) public {
        factory.setVault(vaultAddress);
        messenger.setVault(vaultAddress);
    }

    //need to add all registry peers before making
    function addRegistryPeer(
        uint32 eid,
        bytes32 registryAddr
    ) public onlyOwner {
        peerInfo.push(RegistryPeerInfo(eid, registryAddr));
    }

    //used to get quote to deploy one vault on another chain
    function vaultDeployQuote(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote memory _quoteParams
    )
        public
        onlyAuhtorized(msg.sender)
        vaultExists(vaultId)
        returns (MessagingHelper.ComposedMessage memory _composedMessage)
    {
        _composedMessage = messenger.textRegistryQuote(vaultId, _quoteParams);
    }

    //used to get quote to deploy multiple vaults on multiple chains

    function vaultDeploymentsQuote(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection
    )
        public
        onlyAuhtorized(msg.sender)
        vaultExists(vaultId)
        returns (MessagingHelper.ComposedMessage[] memory _composedMessage)
    {
        _composedMessage = messenger.bulkTextRegistriesQuote(
            vaultId,
            _quoteParamsCollection
        );
    }

    //deploys vault on the products hub chain

    //directyl use factry here since same chain tx
    //before making multichain vaults this must bcreate d first
    //all registries mut be deployed and added as peers before proceeding
    function deployHubVault(
        address _owner,
        bytes memory deployParams
    ) public returns (uint256) {
        (uint256 vaultCreatedId, ) = factory.deployVault(deployParams);

        messenger.registerOapp(_owner, vaultCreatedId);

        addRegistiryPeersVault(vaultCreatedId); //addd peers upon creation

        return vaultCreatedId;
    }

    //important we must do after deploying vault
    function addRegistiryPeersVault(uint256 vaultId) public {
        for (uint256 i = 0; i < peerInfo.length; i++) {
            uint32 eid = peerInfo[i].eid;
            bytes32 peer = peerInfo[i].peer;
            messenger.addPeer(vaultId, eid, peer);
        }
    }

    //quote to deploy vaults on multlpe chains vault mst be deploye don hub first
    function deployVaultsCrossChainQuotes(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote[] memory _composedMessages
    ) public vaultExists(vaultId) {
        messenger.bulkTextRegistriesQuote(vaultId, _composedMessages);
    }

    //should use function called textRegistry instead of vault check make sure used properly
    function deployVaultCrossChain(
        uint256 vaultId,
        MessagingHelper.ComposedMessage[] memory _composedMessages
    ) public vaultExists(vaultId) {
        bool deployed = messenger.bulkText(vaultId, _composedMessages);

        require(deployed, "Cannot dpeloy vaults multichain");
    }

    function recieveText(
        uint256 vaultId,
        bytes memory _text
    ) public vaultExists(vaultId) {
        (bool success, ) = address(this).call(_text); //gotta pass in vault id to call try to encode as well
        require(success, "Text could not execute try again!");
    }

    function deposit(uint256 vaultId, uint256 assets, address reciever) public {
        factory.deposit(vaultId, assets, reciever);
    }

    function withdraw() public {}

    function setStrategy() public {}

    function stopVault() public onlyAuhtorized(msg.sender) {}

    //flushes vault and returns funds to users immediatley this happens when vault is paused stopped or any sort of hack
    function SOSVault() public onlyAuhtorized(msg.sender) {}
}
