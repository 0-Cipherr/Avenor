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

import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

contract VaultRegistryManager {
    uint256 currentId = 0;
    mapping(address => VaultHelper.AvenorUser) avenorUsers;
    mapping(uint256 => VaultHelper.Vault) vaults; //vault[id] id are important

    constructor() {}

    function addUser(
        address _userAddr,
        VaultHelper.AvenorUser memory _newUser
    ) public {
        avenorUsers[_userAddr] = _newUser;
    }

    function verifyUserExistence(address _user) public {}

    function setVault(
        VaultHelper.Vault memory _vault
    ) public returns (uint256) {
        vaults[currentId] = _vault;
        uint256 vaultId = currentId;
        currentId++;
        return vaultId;
    }
    // struct Vault {
    //     address creator;
    //     uint256 tvl;
    //     uint256 allTimeVolume;
    //     string name;
    //     string ticker;
    //     IERC20 depoitAsset;
    //     address[] authorized;
    // }

    function setAvenorUser(
        address _user,
        VaultHelper.AvenorUser memory _userInfo
    ) public {
        avenorUsers[_user] = _userInfo;
    }

    function updateVaultTvl(uint256 vaultId, uint256 _volumeLocked) public {
        vaults[vaultId].tvl += _volumeLocked;
    }

    function upateVaultVolume(uint256 vaultId, uint256 _volume) public {
        vaults[vaultId].allTimeVolume += _volume;
    }

    function addVaultAuthorized(uint256 vaultId, address user) public {
        vaults[vaultId].authorized.push(user);
    }

    function getUser(
        address _user
    ) public view returns (VaultHelper.AvenorUser memory) {
        return avenorUsers[_user];
    }

    function setDeployedVaults(address deployer, VaultFactory vaults) public {
        require(deployer == address(msg.sender), "Deployer must be caller!");
        avenorUsers[deployer].vaultsDeployed.push(vaults);
    }

    function updateVaultsCreated() public {}

    function updateUserFeesEarned(address _user, uint256 _feesEarned) public {
        avenorUsers[_user]._feesEarned += _feesEarned;
    }

    function updateUserTotalVolume(address _user, uint256 _volume) public {
        avenorUsers[_user]._totalVolume += _volume;
    }

    //we may not need to use Creators mapings we can jsut use the user mappings
}
// struct AvenorUser {
//     address _userAdr;
//     uint256 _accountCreatedAt;
//     uint256 numVaultsCreated;
//     uint256 _feesEarned;
//     uint256 _totalVolume;
// }

// struct AvenorCreator {
//     address creatorAddress;
//     uint256 _vaulteVolumesTotal;
//     VaultFactory[] vaultsDeployed;
// }
