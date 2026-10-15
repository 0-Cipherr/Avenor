// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {MessagingHelper} from "./MessagingHelper.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

interface IVaultRegistryMessenger {
    function updateMaxMessagingSize(uint32 newSize) external;
    function newOwner(address owner) external;
    function updateuahtorized(address authorized) external;

    function setVault(address vaultRegistry) external;

    function setVaultDVNNative(uint256 vaultId, uint32 dstEid) external;

    function textMessengerQuote(uint256 vaultId, MessagingHelper.ComposedMessageQuote memory quoteParams)
        external
        view
        returns (MessagingHelper.ComposedMessage memory composedMessage);

    function createOptions() external pure returns (bytes memory);

    function bulkTextRegistriesQuote(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote[] memory quoteParamsCollection
    ) external view returns (MessagingHelper.ComposedMessage[] memory composedMessages, uint256 total);

    function bulkText(uint256 vaultId, MessagingHelper.ComposedMessage[] memory quoteParams)
        external
        payable
        returns (bool);

    function textMessengerPeer(uint256 vaultId, MessagingHelper.ComposedMessage memory composedMessage) external payable;

    function recieveText(bytes memory call) external;

    function addPeer(uint32 eid, bytes32 peer) external;
}
