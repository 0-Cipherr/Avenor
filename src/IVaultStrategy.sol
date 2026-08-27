// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVaultStrategy {
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposited(address indexed vault, uint256 assets);

    event Withdrawn(address indexed vault, uint256 assets);

    event Harvested(
        address indexed vault,
        uint256 totalAssets,
        int256 profitOrLoss
    );

    /*//////////////////////////////////////////////////////////////
                                METADATA
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Asset this strategy accepts.
     *
     * Example:
     * USDC strategy => USDC address.
     */
    function asset() external view returns (address);

    /**
     * @notice Vault that controls this strategy.
     */
    function vault() external view returns (address);

    /*//////////////////////////////////////////////////////////////
                              ACCOUNTING
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Current amount of underlying assets controlled
     *         by this strategy.
     *
     * Includes principal + profit - losses.
     */
    function totalAssets() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                           CAPITAL MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deploy assets into the underlying protocol.
     *
     * Example:
     * USDC -> Aave supply()
     */
    function deposit(
        uint256 assets,
        bytes calldata data
    ) external returns (uint256 assetsDeployed);

    /**
     * @notice Pull assets out of the underlying protocol
     *         and return them to the Vault.
     */
    function withdraw(
        uint256 assets,
        bytes calldata data
    ) external returns (uint256 assetsReturned);

    /**
     * @notice Exit the entire strategy.
     *
     * Useful when:
     * - removing strategy
     * - emergency exit
     * - migrating strategy
     */
    function withdrawAll(
        bytes calldata data
    ) external returns (uint256 assetsReturned);

    /*//////////////////////////////////////////////////////////////
                               HARVEST
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Updates / realizes strategy profit or loss.
     *
     * @return currentAssets Current strategy value.
     * @return profitOrLoss Positive = profit.
     *                      Negative = loss.
     */
    function harvest(
        bytes calldata data
    ) external returns (uint256 currentAssets, int256 profitOrLoss);
}
