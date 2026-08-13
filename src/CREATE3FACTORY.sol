// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3} from "solmate/utils/CREATE3.sol";

import {ICREATE3FACTORY} from "./ICREATE3FACTORY.sol";

/**
 * "COmpleted first test dpeloyment of Create3Factory we plan on launching a
 *  factory on all chains for our product. THepurpose of this factory
 *  isto allow or  determiistic addresses all across evm it makes thigns
 * simpler as we only have the same address for all vaults on all chains
 * in comparison to a regular dpeloyment all addresses are different as we
 *  add more chains on evm the list will grow insanely large and will cost more
 *  to execute transactions in vaults"
 */

/// @title Factory for deploying contracts to deterministic addresses via CREATE3
/// @author zefram.eth
/// @notice Enables deploying contracts using CREATE3. Each deployer (msg.sender) has
/// its own namespace for deployed addresses.
contract CREATE3FACTORY is ICREATE3FACTORY {
    function deploy(
        bytes32 salt,
        bytes memory creationCode
    ) external payable override returns (address deployed) {
        // hash salt with the deployer address to give each deployer its own namespace
        return CREATE3.deploy(salt, creationCode, msg.value);
    }

    function getDeployed(
        address deployer,
        bytes32 salt
    ) external view override returns (address deployed) {
        // hash salt with the deployer address to give each deployer its own namespace
        return CREATE3.getDeployed(salt);
    }
}
