// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IStrategy} from "./IStrategy.sol";

interface IStrategyAdapter {
    function addStrategy(IStrategy strategy) external;

    function increaseId() external;

    function isVaultRegistered(uint256 strategyId, uint256 vaultId) external view returns (bool);

    function setDepositedVault(uint256 vaultId, uint256 strategyId) external;

    function removeDepositedVault(uint256 vaultId, uint256 strategyId) external;

    function deposit(uint256 vaultId, uint256 strategyId, uint256 assets, bytes calldata params) external;

    function withdraw(uint256 strategyId, uint256 assets, bytes calldata params) external;

    function getStrategyTotalAssets(uint256 strategyId) external view returns (uint256);

    function getStategyAsset(uint256 strategyId) external view returns (address);

    function getStrategyVaults(uint256 strategyId) external view returns (uint256[] memory);

    function withdrawAll(uint256 strategyId, bytes calldata params) external;

    function harvest(uint256 strategyId, bytes calldata params) external;
}
