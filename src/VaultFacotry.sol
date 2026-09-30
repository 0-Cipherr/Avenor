// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract VaultFactory is Ownable {
    constructor(address _delegate) Ownable(_delegate) {}
}
// initializeVault()
// configureVault()
// validateDeployParams()
