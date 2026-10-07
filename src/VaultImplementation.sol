// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {VaultManager} from "./VaultManager.sol";

contract VaultImplementation is VaultManager {
    constructor(address _endpoint) VaultManager(_endpoint) {}
}
