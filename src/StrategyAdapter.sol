// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {VaultHelper} from "../src/VaultHelper.sol";
import {IStrategy} from "./IStrategy.sol";

contract StrategyAdapter {
    address authorized;

    mapping(uint256 => IStrategy) strategies;
    mapping(uint256 => uint256[]) depositedVaults;
    uint256 currentStrategyId;
    modifier onlyAuhtorized(address attemptedUser) {
        require(attemptedUser == authorized, "Not authrized to perform ");
        _;
    }

    constructor(address _authorized) {
        authorized = _authorized;
    }

    function addStrategy(IStrategy strategy) public onlyAuhtorized(msg.sender) {
        strategies[currentStrategyId] = strategy;
        increaseId();
    }

    function increaseId() public onlyAuhtorized(msg.sender) {
        ++currentStrategyId;
    }
    // function removeStrategy(uint256 strategyId) public {}

    function isVaultRegistered(uint256 strategyId, uint256 vaultId) public view returns (bool isRegistered) {
        uint256[] memory vaultsDeposited = depositedVaults[strategyId];

        for (uint256 i = 0; i < vaultsDeposited.length; i++) {
            uint256 currentId = vaultsDeposited[i];
            if (currentId == vaultId) {
                isRegistered = true;
            }
        }
    }
    function removeDepositedVault(uint256 vaultId, uint256 strategyId) public {}

    function setDepositedVaults(uint256 vaultId, uint256 strategyId) public view {
        isVaultRegistered(strategyId, vaultId);
    }

    function verifyStrategyId(uint256 strategyId) public view returns (bool) {
        if (address(strategies[strategyId]) == address(0)) {
            return true;
        }

        return false;
    }

    function deposit(uint256 vaultId, uint256 strategyId, uint256 assets, bytes memory params)
        public
        onlyAuhtorized(msg.sender)
    {
        setDepositedVaults(vaultId, strategyId);
        strategies[strategyId].deposit(assets, params);
    }

    function withdraw(uint256 strategyId, uint256 assets, bytes memory params) public onlyAuhtorized(msg.sender) {
        strategies[strategyId].withdraw(assets, params);
    }

    function getStrategyTotalAssets(uint256 strategyId)
        public
        view
        onlyAuhtorized(msg.sender)
        returns (uint256 _totalAssets)
    {
        _totalAssets = strategies[strategyId].totalAssets();
    }

    function getStategyAsset(uint256 strategyId)
        public
        view
        onlyAuhtorized(msg.sender)
        returns (address strategyAsset)
    {
        strategyAsset = strategies[strategyId].asset();
    }

    function getStrategyVaults(uint256 strategyId)
        public
        view
        onlyAuhtorized(msg.sender)
        returns (uint256[] memory _vaults)
    {
        _vaults = depositedVaults[strategyId];
    }

    function withdrawAll(uint256 strategyId, bytes memory params) public onlyAuhtorized(msg.sender) {
        strategies[strategyId].withdrawAll(params);
    }

    function harvest(uint256 strategyId, bytes memory params) public onlyAuhtorized(msg.sender) {
        strategies[strategyId].harvest(params);
    }
}
