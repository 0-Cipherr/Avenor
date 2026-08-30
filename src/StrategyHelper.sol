// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
library StrategyHelper {
    event Harvest(
        address indexed strategy,
        uint256 totalAssets,
        int256 profitOrLoss
    );
}
