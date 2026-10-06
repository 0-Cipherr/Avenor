// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {MessagingHelper} from "./MessagingHelper.sol";

interface IVaultRegistry {
    function setAddressDependencies(address vaultAddress) external;

    function addRegistryPeer(uint256 vaultId, uint32 eid, bytes32 registryAddr) external;

    function vaultDeployQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote memory quoteParams)
        external
        returns (MessagingHelper.ComposedMessage memory composedMessage);

    function vaultDeploymentsQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote[] memory quoteParamsCollection)
        external
        returns (MessagingHelper.ComposedMessage[] memory composedMessage);

    function deployHubVault(address owner, bytes memory deployParams) external returns (uint256);

    function addRegistiryPeersVault(uint256 vaultId) external;

    function deployVaultsCrossChainQuotes(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote[] memory composedMessages
    ) external;

    function deployVaultCrossChain(uint256 vaultId, MessagingHelper.ComposedMessage[] memory composedMessages) external;

    function recieveText(uint256 vaultId, bytes memory text) external;

    function deposit() external;

    function withdraw() external;

    function setStrategy() external;

    function stopVault() external;

    function SOSVault() external;
}
