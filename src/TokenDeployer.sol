// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract TokenDeployer is ERC20 {
    constructor(string memory _ticker, string memory _symbol) ERC20(_ticker, _symbol) {}

    function mintTokens(address _account, uint256 _amount) public {
        _mint(_account, _amount);
    }

    function setSpendAllowance(address owner, address spender, uint256 value) public {
        _spendAllowance(owner, spender, value);
    }

    function getBalance(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }
}
