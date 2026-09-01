pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ERC4626
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract VaultAssets is ERC4626 {
    uint256 _totalSupply;
    uint256 _totalAssets; //total assets deposited in vault
    uint256 totalShares;
    uint256 protocolFee;
    uint256 creatorFee;
    uint256 precision = 10_000;
    mapping(address => uint256) shares;
    //ethereum is measured like this in solidity best eway to be qable to use decimal notaton: 10 ** 18
    constructor(
        string memory _name,
        string memory _ticker,
        IERC20 _asset
    ) ERC20(_name, _ticker) ERC4626(_asset) {}
    function calculateFees(
        uint256 _amount
    ) public view returns (uint256 _total) {
        uint256 _formattedAmount = _amount * 1e18;
        uint256 protocolFeeDeducted = ((_formattedAmount) * (protocolFee)) /
            1e18;
        uint256 creatorFeeDeducted = ((_formattedAmount) * (creatorFee)) / 1e18;
        _total = (_amount * 1e18) - protocolFeeDeducted - creatorFeeDeducted;
    }

    function convertToShares(
        uint256 assets
    ) public view override returns (uint256 _shares) {
        _shares = (_totalAssets * _totalSupply) / _totalAssets;
        /**
         *
         * @param shares Vault assets = 10,000 USDC
         * Share supply = 5,000 shares
         *
         *
         * function
         */
    }

    function convertToAssets(
        uint256 _shares
    ) public view override returns (uint256 assets) {
        assets = (_shares * _totalAssets) / _totalSupply;
        uint256 feesApplied = calculateFees(assets);
        assets = feesApplied;
        /**
         *
         * @param assets 500 shares = 1,000 USDC
         */
    }

    function getSharePrice() public view returns (uint256) {
        return (_totalAssets * 1e18) / totalShares;
    }
    function previewDeposit() public view returns (uint256) {}

    function previewDeposit(
        uint256 _assets
    ) public view override returns (uint256 _shares) {
        _shares = convertToShares(_assets);
        //no fees on deposit
        /**
         *
         * @param assets previewDeposit() answers: "If I deposited this amount right now, approximately how many shares would I receive?"
         */
    }
}
