pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract VaultAssets is ERC4626 {
    uint256 totalSupply;
    uint256 totalAssets; //total assets deposited in vault
    uint256 totalShares;
    constructor(string memory _name, string memory _ticker, IERC20 _asset) ERC20(_name, _ticker) ERC4626(_asset) {}

    function convertToShares(uint256 assets) public view override returns (uint256 shares) {
        shares = (totalAssets * totalSupply) / totalAssets;
        /**
         *
         * @param shares Vault assets = 10,000 USDC
         * Share supply = 5,000 shares
         *
         *
         * function
         */
    }

    function getSharPrice() public view returns (uint256) {
        return (totalAssets * 1e18) / totalShares;
    }
    function previewDeposit() public view returns (uint256) {}
    function deposit() public payable {}

    function previewDeposit(uint256 assets) public view override returns (uint256 shares) {
        shares = convertToShares(assets);
        //no fees on deposit
        /**
         *
         * @param assets previewDeposit() answers: "If I deposited this amount right now, approximately how many shares would I receive?"
         */
    }
}
