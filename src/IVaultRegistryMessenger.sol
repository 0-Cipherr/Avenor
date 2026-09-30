import {MessagingHelper} from "./MessagingHelper.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

interface IVaultRegistryMessenger {
    function setVault(address _vaultRegistry) external;

    function textVault(MessagingHelper.ComposedMessage calldata _composedMessage) external;

    function crossChainDeployVaults() external;

    function validateBulkQuote(MessagingHelper.ComposedMessageQuote[] calldata _quoteParamsCollection)
        external
        pure
        returns (bool);

    function bulkTextQuote(MessagingHelper.ComposedMessageQuote[] calldata _quoteParamsCollection)
        external
        returns (MessagingHelper.ComposedMessage[] memory _composedMessages);

    function registerOApp(address _delegate, address vaultAddress) external;

    function textQuote(MessagingHelper.ComposedMessageQuote calldata _quoteParams)
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

    function createOptions() external returns (bytes memory);
}
