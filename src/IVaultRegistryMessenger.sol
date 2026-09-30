// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {IVaultRegistry} from "./IVaultRegistry.sol";

interface IVaultRegistryMessenger {
    /**
     * @notice Sets the VaultRegistry used by this messenger.
     */
    function setVault(address _vaultRegistry) external;

    /**
     * @notice Sends a cross-chain vault message.
     */
    function textVault(MessagingHelper.ComposedMessage calldata _composedMessage) external payable;

    /**
     * @notice Deploys vaults across multiple chains.
     */
    function crossChainDeployVaults() external;

    /**
     * @notice Validates a collection of message quotes.
     */
    function validateBulkQuote(MessagingHelper.ComposedMessageQuote[] calldata _quoteParamsCollection)
        external
        pure
        returns (bool);

    /**
     * @notice Creates quotes for multiple messages for a vault.
     */
    function bulkTextQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote[] calldata _quoteParamsCollection)
        external
        returns (MessagingHelper.ComposedMessage[] memory _composedMessages);

    /**
     * @notice Creates and registers a new VaultOApp instance.
     */
    function registerOApp(address _delegate, address _vaultAddress) external;

    /**
     * @notice Handles deployment messages received from another chain.
     */
    function recieveDeploymentText(bytes calldata message) external;

    /**
     * @notice Sends a message to the VaultRegistry.
     */
    function textToRegistry() external;

    /**
     * @notice Creates a quote for a specific vault OApp.
     */
    function textQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote calldata _quoteParams)
        external
        returns (MessagingHelper.ComposedMessage memory composedMessage);

    /**
     * @notice Constructs a composed LayerZero message.
     */
    function constructComposedMessage(
        uint32 _dstEid,
        MessagingFee calldata _fee,
        bytes calldata _message,
        bytes calldata _options,
        bool _payInLzToken,
        address _refundAddress
    ) external pure returns (MessagingHelper.ComposedMessage memory composedMessage);

    /**
     * @notice Creates LayerZero options.
     */
    function createOptions() external returns (bytes memory options);
}
