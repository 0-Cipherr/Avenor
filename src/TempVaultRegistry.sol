// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {StrategyHelper} from "./StrategyHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {VaultStrategies} from "./VaultStrategies.sol";

import {VaultManager} from "./VaultManager.sol";

import {VaultRegistryManager} from "./VaultRegistryManager.sol";

import {VaultRegistryMessenger} from "../src/VaultRegistryMessenger.sol";
import {VaultFactory} from "./VaultFacotry.sol";

contract TempVaultRegistry is Ownable {
    address endpoint;
    uint32 endpointId;
    address delegate;
    VaultFactory factory;
    VaultRegistryMessenger messenger;

    /**
     * _delegate - owner (deployer)
     * _endpoint: registry current endpoitn where  it lives
     * _endpoint id: registry current endpoint id  where it lives
     */
    modifier onlyAuhtorized(address attemptedUser) {
        require(attemptedUser == delegate, "Not authrized to perform ");
        _;
    }

    constructor(address _delegate, address _endpoint, uint32 _endpointId) Ownable(_delegate) {
        endpoint = _endpoint;
        endpointId = _endpointId;
        delegate = _delegate;
    }

    //initialize each dependenc no need to use interface we create here we makign like this to save space on deployment
    //update instead of using its instances deploy before adding and just use its interfaces
    //important we need noted above to save alot of space for dpeloyment

    function initializeDependencies() public {
        factory = new VaultFactory(delegate, endpoint);
        messenger = new VaultRegistryMessenger(delegate, endpoint);
    }

    //sets vault address for each dependency so it can communicate with us especially the messenger
    function setAddressDependencies(address vaultAddress) public {
        factory.setVault(vaultAddress);
        messenger.setVault(vaultAddress);
    }

    function vaultDeployQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote memory _quoteParams)
        public
        returns (MessagingHelper.ComposedMessage memory _composedMessage)
    {
        _composedMessage = messenger.textQuote(vaultId, _quoteParams);
    }

    function vaultDeploymentsQuote(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection
    ) public returns (MessagingHelper.ComposedMessage[] memory _composedMessage) {
        _composedMessage = messenger.bulkTextQuote(vaultId, _quoteParamsCollection);
    }

    function deployVault(uint256 vaultId) public {}

    function deployVaultsQuote(uint256 vaultId, MessagingHelper.ComposedMessage[] memory _composedMessages) public {}
    function deployVaults(uint256 vaultId, MessagingHelper.ComposedMessage[] memory _composedMessages) public {}

    function recieveText(bytes memory _text) public {
        (bool success,) = address(this).call(_text);
        require(success, "Text could not execute try again!");
    }

    function stopVault() public onlyAuhtorized(msg.sender) {}

    //flushes vault and returns funds to users immediatley this happens when vault is paused stopped or any sort of hack
    function SOSVault() public onlyAuhtorized(msg.sender) {}
}
