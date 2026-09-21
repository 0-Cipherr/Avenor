// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    ERC4626
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ReadCodecV1,
    EVMCallRequestV1
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {StrategyHelper} from "./StrategyHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {VaultStrategies} from "./VaultStrategies.sol";
import {
    MessagingReceipt
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

contract VaultRouter {
    mapping(address => VaultHelper.AvenorUser) avenorUsers;
    constructor() {}

    function addUser(
        address _userAddr,
        VaultHelper.AvenorUser memory _newUser
    ) public {
        avenorUsers[_userAddr] = _newUser;
    }

    function getUser(
        address _user
    ) public view returns (VaultHelper.AvenorUser memory) {
        return avenorUsers[_user];
    }

    function deployVault() public {}

    function mcVaultDeployment() public {}

    function setOnlyCaller() public {}

    function verifyOnlyCaller() public {}
}
