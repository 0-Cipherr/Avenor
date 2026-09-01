// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

library MessagingHelper {
    struct ComposedMessage {
        uint32 _dstEid;
        MessagingFee _fee;
        bytes _message;
        bytes _options;
        bool payInLzToken;
        address _refundAddress;
    }
}
