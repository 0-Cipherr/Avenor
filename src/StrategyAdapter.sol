// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {VaultHelper} from "../src/VaultHelper.sol";
import {IStrategyRouter} from "./IStrategyRouter.sol";

contract StrategyAdapter {
    address authorized;

    mapping(uint256 => IStrategyRouter) strategies;

    modifier onlyAuhtorized(address attemptedUser) {
        require(attemptedUser == authorized, "Not authrized to perform ");
        _;
    }

    constructor(address _authorized) {
        authorized = _authorized;
    }

    function addStrategy(uint256 strategyId) public {}

    function removeStrategy() public {}

    function depositIntoStrategy() public {}

    function withdrawFromStrategy() public {}
}
