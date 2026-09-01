// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import {IStrategyRouter} from "./IStrategyRouter.sol";
import {VaultHelper} from "./VaultHelper.sol";

contract VaultStrategies {
    IStrategyRouter strategyRouter;
    uint256 totalStrategyAssets;
    VaultHelper.StrategyPosition position;
    constructor() {}
    function getStrategies() public view returns (address[] memory) {}

    function getStrategyPosition() public view returns (VaultHelper.StrategyPosition memory) {
        return position;
    }

    function setPosition(VaultHelper.StrategyPosition memory _positionInfo) public {
        position = _positionInfo;
    }

    function addStrategy(address _strategy) public {
        emit VaultHelper.StrategyAdded(_strategy);
    }

    function removeStrategy(address _strategy) public {
        emit VaultHelper.StrategyRemoved(_strategy);
    }

    function deployCapital(address _strategy, uint256 assets, bytes calldata data)
        public
        returns (uint256 assetsDeployed)
    {
        emit VaultHelper.CapitalDeployed(_strategy, assets);
    }

    function withdrawCapital(address _strategy, uint256 assets, bytes calldata data)
        public
        returns (uint256 assetsReturned)
    {
        emit VaultHelper.CapitalReturned(_strategy, assets);
    }

    function harvest(address _strategy, bytes calldata data)
        public
        returns (uint256 currentAssets, int256 profitOrLoss)
    {}

    function flush(address reciever) public {
        payable(reciever).call{value: address(this).balance}("");
    }
}
