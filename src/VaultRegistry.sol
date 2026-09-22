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
import {VaultManager} from "./VaultManager.sol";
import {IVaultManager as VaultFactory} from "./IVaultManager.sol";

contract VaultRegistry {
    mapping(address => VaultHelper.AvenorUser) avenorUsers;
    mapping(address => VaultHelper.AvenorCreator) avenorCreators;

    constructor(VaultFactory _vaultFactory) {
        vaultFactory = _vaultFactory;
    }

    function addUser(
        address _userAddr,
        VaultHelper.AvenorUser memory _newUser
    ) public {
        avenorUsers[_userAddr] = _newUser;
    }

    function addCreator(VaultHelper.AvenorCreator memory creator) public {
        require(creator.creatorAddress == address(msg.sender));
        avenorCreators[msg.sender] = creator;
    }

    function getCreator(
        address creator
    ) public returns (VaultHelper.AvenorCreator memory) {
        return avenorCreators[creator];
    }

    function getUser(
        address _user
    ) public view returns (VaultHelper.AvenorUser memory) {
        return avenorUsers[_user];
    }

    function setDeployedVaults(address deployer, VaultFactory vaults) public {
        require(deployer == address(msg.sender), "Deployer must be caller!");
        avenorCreators[deployer].vaultsDeployed.push(vaults);
    }

    function deployHubVault(address deployer) public {
        VaultFactory vaultDpeloyed = new VaultFactory();
        setDeployedVaults(deployer, vaultDpeloyed);
    }

    function deployMultiChainBridge() public {}

    function mcVaultDeployment() public {}

    function setOnlyCaller() public {}

    function verifyOnlyCaller() public {}
}
