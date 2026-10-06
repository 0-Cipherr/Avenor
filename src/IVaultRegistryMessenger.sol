// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {MessagingHelper} from "./MessagingHelper.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
//messenger used to handle vault messaging in the vault regitry
interface IVaultRegistryMessenger {
    function setVault(address _vaultRegistry) external;

    function textRegistry(
        uint256 vaultId,
        MessagingHelper.ComposedMessage memory _composedMessage
    ) external;

    function crossChainDeployVaults() external;

    function validateBulkQuote(
        MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection
    ) external pure returns (bool);

    function bulkTextRegistriesQuote(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote[] memory _quoteParamsCollection
    )
        external
        returns (MessagingHelper.ComposedMessage[] memory _composedMessage);

    function registerOapp(address _delegate, uint256 vaultId) external;

    function recieveDeploymentText(bytes memory message) external;

    function textToRegistry() external;

    function textRegistryQuote(
        uint256 vaultId,
        MessagingHelper.ComposedMessageQuote memory _quoteParams
    ) external returns (MessagingHelper.ComposedMessage memory composedMessage);

    function constructComposedMessage(
        uint32 _dstEid,
        MessagingFee memory _fee,
        bytes memory _message,
        bytes memory _options,
        bool payInLzToken,
        address _refundAddress
    )
        external
        pure
        returns (MessagingHelper.ComposedMessage memory composedMessage);

    function createOptions() external returns (bytes memory);
    function addPeer(uint256 vaultId, uint32 eid, bytes32 peer) external;
    function bulkText(
        uint256 vaultId,
        MessagingHelper.ComposedMessage[] memory _quoteParams
    ) external returns (bool);
}
