// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

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

    struct FeesInfo {
        uint256 _creatorFee;
        uint256 _protocolFee;
    }
    feeReceiversInfo feeRecievers;
    FeesInfo fees;
    uint256 precision = 10_000;
    mapping(address => uint256) shares;
    mapping(address => uint256) assetsDeposited;

    //ethereum is measured like this in solidity best eway to be qable to use decimal notaton: 10 ** 18
    constructor(
        string memory _name,
        string memory _ticker,
        IERC20 _asset,
        FeesInfo memory feeInfo,
        feeReceiversInfo memory _recievers
    ) ERC20(_name, _ticker) ERC4626(_asset) {
        feeRecievers = _recievers;
        fees = feeInfo;
    }

    function getFeeRecievers() public view returns (feeReceiversInfo memory) {
        return feeRecievers;
    }

    function getFees() public view returns (FeesInfo memory) {
        return fees;
    }

    function getTotalAssets() public view returns (uint256) {
        return _totalAssets;
    }

    function getIdleAssets() external view returns (uint256) {
        return _idleAssets;
    } //assets not in a strategy

    function mintShares(uint256 _amount, address _minter) public {
        shares[_minter] = _amount;
        _mint(_minter, _amount);
    }

    function burnTokens(uint256 _amount, address _burner) public {
        _totalSupply -= _amount;
        shares[_burner] -= _amount;
        _burn(_burner, _amount);
    }

    uint256 BPS = 10000;

    //ex for fees set: 5% 500,
    //6.5% , 650
    // /to calculate must multiple amount by 1e18s
    function calculateFees(uint256 _amount)
        public
        view
        returns (uint256 _total, uint256 protocolFeeDeducted, uint256 creatorFeeDeducted)
    {
        // 1. Calculate fees directly using BPS (No extra 1e18 scaling needed)
        protocolFeeDeducted = (_amount * fees._protocolFee) / BPS;
        creatorFeeDeducted = (_amount * fees._creatorFee) / BPS;

        // 2. Subtract the fees from the original amount
        _total = _amount - protocolFeeDeducted - creatorFeeDeducted;
    }

    function convertToShares(uint256 assets) public view override returns (uint256 _shares) {
        if (_totalAssets == 0 || _totalSupply == 0) {
            return assets;
        }

        _shares = (assets * _totalSupply) / _totalAssets;
    }

    function convertToAssets(uint256 _shares) public view override returns (uint256 _assets) {
        if (_totalSupply == 0) {
            return _shares;
        }

        _assets = (_shares * _totalAssets) / _totalSupply;
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

    function previewWithdraw(uint256 _shares) public view override returns (uint256 _assets) {
        _assets = convertToAssets(_shares);
        (uint256 _total,,) = calculateFees(_assets);

        _assets = _total;
        //previewWithdraw() answers: "How many shares would need to be burned if I withdraw this amount of assets?"
    }

    function previewRedeem(uint256 _shares) public view override returns (uint256 _assets) {
        uint256 assetsToRecieve = convertToAssets(_shares);
        (uint256 _total,,) = calculateFees(assetsToRecieve);
        _assets = _total;
        //previewRedeem() answers the opposite question: "If I burn this many shares, how many assets will I receive?"
    }

    function flush(address reciever, uint256 _amount) public returns (bool) {
        (bool success,) = payable(reciever).call{value: address(this).balance}("");
        require(success, "Transfer failed");
        return success;
    }
}
