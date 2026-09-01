// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVault {
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, address indexed receiver, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    event StrategyAdded(address indexed strategy);

    event StrategyRemoved(address indexed strategy);

    event CapitalDeployed(address indexed strategy, uint256 assets);

    event CapitalReturned(address indexed strategy, uint256 assets);

    event Harvest(address indexed strategy, uint256 totalAssets, int256 profitOrLoss);

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    struct StrategyPosition {
        bool enabled;
        uint256 debt;
        uint256 lastReportedAssets;
    }

    /*//////////////////////////////////////////////////////////////
                             VAULT METADATA
    //////////////////////////////////////////////////////////////*/

    function asset() external view returns (address);

    function creator() external view returns (address);

    function authorizer() external view returns (address);

    /*//////////////////////////////////////////////////////////////
                              ACCOUNTING
    //////////////////////////////////////////////////////////////*/

    function totalAssets() external view returns (uint256);

    function idleAssets() external view returns (uint256);

    function convertToShares(uint256 assets) external view returns (uint256 shares);

    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /*//////////////////////////////////////////////////////////////
                             PREVIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /*//////////////////////////////////////////////////////////////
                              USER ACTIONS
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    /*//////////////////////////////////////////////////////////////
                           STRATEGY MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    function addStrategy(address strategy) external;

    function removeStrategy(address strategy) external;

    function deployCapital(address strategy, uint256 assets, bytes calldata data)
        external
        returns (uint256 assetsDeployed);

    function withdrawCapital(address strategy, uint256 assets, bytes calldata data)
        external
        returns (uint256 assetsReturned);

    function harvest(address strategy, bytes calldata data)
        external
        returns (uint256 currentAssets, int256 profitOrLoss);

    /*//////////////////////////////////////////////////////////////
                                VIEWS
    //////////////////////////////////////////////////////////////*/

    function getStrategies() external view returns (address[] memory);

    function getStrategyPosition(address strategy) external view returns (StrategyPosition memory);
}
