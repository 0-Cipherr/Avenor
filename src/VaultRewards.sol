// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract VaultRewards {
    address ponsFactory = 0xA5aAb3F0c6EeadF30Ef1D3Eb997108E976351feB;
    constructor() {}

    function updatePonsFactory(address newFactory) public {
        ponsFactory = newFactory;
    }
}
