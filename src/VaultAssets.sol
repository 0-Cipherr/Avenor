pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract VaultAssets is ERC4626 {
    uint256 _totalSupply;
    uint256 _totalAssets; //total assets deposited in vault
    uint256 totalShares;
    uint256 protocolFee;
    uint256 creatorFee;
    uint256 _idleAssets;

    struct feeReceiversInfo {
        address protocolFee;
        address creatorFee;
    }
    feeReceiversInfo feeRecievers;
    uint256 precision = 10_000;
    mapping(address => uint256) shares;
    mapping(address => uint256) assetsDeposited;

    //ethereum is measured like this in solidity best eway to be qable to use decimal notaton: 10 ** 18
    constructor(string memory _name, string memory _ticker, IERC20 _asset, uint256 _creatorFee, uint256 _protocolFee)
        ERC20(_name, _ticker)
        ERC4626(_asset)
    {
        creatorFee = _creatorFee;
        protocolFee = _protocolFee;
    }

    function getTotalAssets() public view returns (uint256) {
        return _totalAssets;
    }

    function getIdleAssets() external view returns (uint256) {
        return _idleAssets;
    } //assets not in a strategy

    function mintShares(uint256 _amount, address _minter) public {
        _mint(_minter, _amount);
    }

    function burnTokens(uint256 _amount, address _burner) public {
        _burn(_burner, _amount);
    }

    function calculateFees(uint256 _amount) public view returns (uint256 _total) {
        uint256 _formattedAmount = _amount * 1e18;
        uint256 protocolFeeDeducted = ((_formattedAmount) * (protocolFee)) / 1e18;
        uint256 creatorFeeDeducted = ((_formattedAmount) * (creatorFee)) / 1e18;
        _total = (_amount * 1e18) - protocolFeeDeducted - creatorFeeDeducted;
    }

    function convertToShares(uint256 assets) public view override returns (uint256 _shares) {
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

    function convertToAssets(uint256 _shares) public view override returns (uint256 assets) {
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

    function previewDeposit(uint256 _assets) public view override returns (uint256 _shares) {
        _shares = convertToShares(_assets);
        //no fees on deposit
        /**
         *
         * @param assets previewDeposit() answers: "If I deposited this amount right now, approximately how many shares would I receive?"
         */
    }

    function calculateBurn(uint256 _assets) public view returns (uint256 _shares) {
        _shares = (_assets * _totalSupply) / _totalAssets;
    }

    function calculateReedem(uint256 _shares) public view returns (uint256 _reedemable) {
        _reedemable = (_shares * _totalAssets) / _totalSupply;
    }

    function previewWithdraw(uint256 _assets) public view override returns (uint256 _shares) {
        _shares = calculateBurn(_assets);
        //previewWithdraw() answers: "How many shares would need to be burned if I withdraw this amount of assets?"
    }

    function previewRedeem(uint256 _shares) public view override returns (uint256 _assets) {
        uint256 assetsToRecieve = convertToAssets(_shares);
        _assets = calculateFees(assetsToRecieve);
        //previewRedeem() answers the opposite question: "If I burn this many shares, how many assets will I receive?"
    }

    function flush(address reciever, uint256 _amount) public {
        payable(reciever).call{value: address(this).balance}("");
    }
}
