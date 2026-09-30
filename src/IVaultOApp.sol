// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

import {MessagingHelper} from "./MessagingHelper.sol";

interface IVaultOApp {
    function updateAuthorized(address _delegate) external;

    function setVaultRegistryMessenger(address _vaultRegistryMessenger) external;

    function textVault(MessagingHelper.ComposedMessage calldata _composedMessage) external payable;

    function quoteText(MessagingHelper.ComposedMessageQuote calldata _quoteParams)
        external
        returns (MessagingHelper.ComposedMessage memory composedMessage);

    function constructComposedMessage(
        uint32 _dstEid,
        MessagingFee calldata _fee,
        bytes calldata _message,
        bytes calldata _options,
        bool _payInLzToken,
        address _refundAddress
    ) external pure returns (MessagingHelper.ComposedMessage memory composedMessage);

    function validateBulkQuote(MessagingHelper.ComposedMessageQuote[] calldata _quoteParamsCollection)
        external
        pure
        returns (bool);

    function bulkTextQuote(MessagingHelper.ComposedMessageQuote[] calldata _quoteParamsCollection)
        external
        returns (MessagingHelper.ComposedMessage[] memory _composedMessage);

    function createOptions() external returns (bytes memory options);
}
