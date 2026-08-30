library VaultHelper {
    event Deposit(
        address indexed caller,
        address indexed receiver,
        uint256 assets,
        uint256 shares
    );

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event StrategyAdded(address indexed strategy);

    event StrategyRemoved(address indexed strategy);

    event CapitalDeployed(address indexed strategy, uint256 assets);

    event CapitalReturned(address indexed strategy, uint256 assets);

    struct DepositorInfo {
        address depositor;
        uint256 assets;
        uint256 shares;
        uint256 assetVolume;
    }
    struct StrategyPosition {
        bool enabled;
        uint256 debt;
        uint256 lastReportedAssets;
    }
}
