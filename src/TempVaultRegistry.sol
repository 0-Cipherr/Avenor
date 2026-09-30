// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {OAppOptionsType3} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReadCodecV1, EVMCallRequestV1} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {StrategyHelper} from "./StrategyHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {VaultStrategies} from "./VaultStrategies.sol";
import {MessagingReceipt} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultManager} from "./VaultManager.sol";

import {VaultRegistryManager} from "./VaultRegistryManager.sol";

import {VaultRegistryMessenger} from "../src/VaultRegistryMessenger.sol";
import {VaultFactory} from "./VaultFacotry.sol";

contract TempVaultRegistry is Ownable {
    address endpoint;
    uint32 endpointId;
    address delegate;
    VaultFactory factory;
    VaultRegistryMessenger messenger;

    /**
     * _delegate - owner (deployer)
     * _endpoint: registry current endpoitn where  it lives
     * _endpoint id: registry current endpoint id  where it lives
     */
    constructor(address _delegate, address _endpoint, uint32 _endpointId) Ownable(_delegate) {
        endpoint = _endpoint;
        endpointId = _endpointId;
        delegate = _delegate;
    }

    //initialize each dependenc no need to use interface we create here we makign like this to save space on deployment
    function initializeDependencies() public {
        factory = new VaultFactory(delegate, endpoint);
        messenger = new VaultRegistryMessenger(delegate, endpoint);
    }

    //sets vault address for each dependency so it can communicate with us especially the messenger
    function setAddressDependencies(address vaultAddress) public {
        factory.setVault(vaultAddress);
        factory.setVault(vaultAddress);
    }
}
