// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    ERC4626
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {
    ReadCodecV1,
    EVMCallRequestV1
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import {OAppRead} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {StrategyHelper} from "./StrategyHelper.sol";

contract Vault is Ownable, OApp, ERC4626 {
    address vaultAsset;
    address creator;
    uint256 totalAssets;
    uint256 idleAssets;
    uint256 totalSupply;
    uint256 creatorFee;
    uint256 protocolFee;
    IERC20 asset;
    address creatorFeeReciever;
    address protoclFeeReceiver;
    mapping(address => uint256) sharesOwned;
    mapping(address => uint256) assetsDeposited;

    constructor(
        address _vaultAsset,
        address _creator,
        address _endpoint,
        uint256 _creatorFee,
        uint256 _protocolFee,
        IERC20 _asset,
        address _creatorFeeReciever,
        address _protoclFeeReceiver
    ) Ownable(_creator) OApp(_endpoint, _creator) ERC4626(_asset) {
        vaultAsset = _vaultAsset;
        creator = _creator;
        creatorFee = _creatorFee;
        protocolFee = _protocolFee;
        asset = _asset;
        creatorFeeReciever = _creatorFeeReciever;
        protoclFeeReceiver = _protoclFeeReceiver;
    }

    mapping(address => VaultHelper.DepositorInfo) depositors;

    // bytes strategyInfo //bytes suppose dot be strategy info struct containing info and addresses

    VaultHelper.StrategyPosition strategyPosition;

    function getAsset() public view returns (address) {
        return vaultAsset;
    }

    function getCreator() public view returns (address) {
        return creator;
    }

    function getAuthorizer() public view returns (address) {}

    function getTotalAssets() public view returns (uint256) {
        return totalAssets;
    }

    function getIdleAssets() external view returns (uint256) {
        return idleAssets;
    } //assets not in a strategy

    function calculateBurn(
        uint256 _assets
    ) public view returns (uint256 shares) {
        shares = (_assets * totalSupply) / totalAssets;
    }

    function calculateReedem(
        uint256 _shares
    ) public view returns (uint256 _reedemable) {
        _reedemable = (_shares * totalAssets) / totalSupply;
    }

    function convertToShares(
        uint256 assets
    ) public view override returns (uint256 shares) {
        shares = (assets * totalSupply) / totalAssets;
        /**
         * 
         * @param shares Vault assets = 10,000 USDC
Share supply = 5,000 shares
         */
    }

    function convertToAssets(
        uint256 shares
    ) public view returns (uint256 assets) {
        assets = (shares * totalAssets) / totalSupply;
        /**
         *
         * @param assets 500 shares = 1,000 USDC
         */
    }

    function calculatePercentage(
        uint256 amount,
        uint256 basisPoints
    ) public pure returns (uint256) {
        // Multiply before you divide to prevent rounding down to zero
        return (amount * basisPoints) / 10000;
    }
    /*//////////////////////////////////////////////////////////////
                             PREVIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function previewDeposit(
        uint256 assets
    ) public view returns (uint256 shares) {
        shares = convertToShares(assets);
        /**
         *
         * @param assets previewDeposit() answers: "If I deposited this amount right now, approximately how many shares would I receive?"
         */
    }

    function previewWithdraw(
        uint256 assets
    ) public view returns (uint256 shares) {
        shares = calculateBurn(assets);
        //previewWithdraw() answers: "How many shares would need to be burned if I withdraw this amount of assets?"
    }

    function previewRedeem(
        uint256 _shares
    ) public view returns (uint256 assets) {
        assets = calculateReedem(_shares);
        //previewRedeem() answers the opposite question: "If I burn this many shares, how many assets will I receive?"
    }

    /*//////////////////////////////////////////////////////////////
                              USER ACTIONS
    //////////////////////////////////////////////////////////////*/

    function setDepositor(
        address _depositor,
        VaultHelper.DepositorInfo memory _info
    ) public {
        depositors[_depositor] = _info;
    }

    function deposit(
        uint256 assets,
        address receiver
    ) public payable returns (uint256 shares) {
        require(receiver == msg.sender, "caller is not the set reciever");
        require(msg.value == assets, "Missing ETH To Complete!");
        shares = convertToShares(assets);
        if (hasDeposited(receiver) != true) {
            setDepositor(
                receiver,
                VaultHelper.DepositorInfo(receiver, assets, shares, assets)
            );
        } else {
            setSharesOwned(shares, receiver, false);
            setVolume(receiver, assets);
        }

        emit Deposit(receiver, receiver, assets, shares);

        //deposit into vault
    }
    function hasDeposited(address _user) public view returns (bool) {
        return depositors[_user].assetVolume > 0;
    }
    function setAssetsDeposited(
        uint256 _amount,
        address _assetOwner,
        bool isDeducted
    ) public {
        isDeducted
            ? assetsDeposited[_assetOwner] -= _amount
            : assetsDeposited[_assetOwner] += _amount;
    }

    function setVolume(address _user, uint256 _newVolume) public {
        depositors[_user].assetVolume += _newVolume;
    }

    function setSharesOwned(
        uint256 _amount,
        address _shareOwner,
        bool isDeducted
    ) public {
        isDeducted
            ? sharesOwned[_shareOwner] -= _amount
            : sharesOwned[_shareOwner] += _amount;
    }

    function mintShares(uint256 _amount, address _minter) public {}

    function burnTokens(uint256 _amount, address _burner) public {}

    function withdraw(
        uint256 assets,
        address receiver,
        uint256 _amount
    ) public returns (uint256 shares) {
        require(receiver == msg.sender, "Not owner");
        setAssetsDeposited(_amount, receiver, true);
        uint256 totalFee = calculatePercentage() +
            calculatePercentage(amount, basisPoints);
        emit Withdraw(receiver, receiver, receiver, assets, shares);
        // withdraw out of vault to user
    }
    function withdrawCrossChain(
        uint32 _dstEid,
        address _reciever,
        uint256 _amount
    ) public {}

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public returns (uint256 assets) {
        //redeem() burns a specific amount of Vault shares and returns however many underlying assets those shares are worth.
    }

    /*//////////////////////////////////////////////////////////////
                           STRATEGY MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    function addStrategy(address _strategy) public {
        emit VaultHelper.StrategyAdded(_strategy);
    }

    function removeStrategy(address _strategy) public {
        emit VaultHelper.StrategyRemoved(_strategy);
    }

    function deployCapital(
        address _strategy,
        uint256 assets,
        bytes calldata data
    ) public returns (uint256 assetsDeployed) {
        emit VaultHelper.CapitalDeployed(_strategy, assets);
    }

    function withdrawCapital(
        address _strategy,
        uint256 assets,
        bytes calldata data
    ) public returns (uint256 assetsReturned) {
        emit VaultHelper.CapitalReturned(_strategy, assets);
    }

    function harvest(
        address _strategy,
        bytes calldata data
    ) public returns (uint256 currentAssets, int256 profitOrLoss) {}
    function flush(address reciever) public {
        payable(reciever).call{value: address(this).balance}("");
    }
    function payFee() {}

    /*//////////////////////////////////////////////////////////////
                                VIEWS
    //////////////////////////////////////////////////////////////*/

    function getStrategies() public view returns (address[] memory) {}

    function getStrategyPosition()
        public
        view
        returns (VaultHelper.StrategyPosition memory)
    {
        return strategyPosition;
    }
    function messageQuote(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        bool _payLzToken,
        address _refundAddress
    ) public view returns (MessagingHelper.ComposedMessage memory) {
        MessagingFee memory _fee = _quote(
            _dstEid,
            _message,
            _options,
            _payLzToken
        );
        return
            MessagingHelper.ComposedMessage(
                _dstEid,
                _fee,
                _message,
                _options,
                _payLzToken,
                _refundAddress
            );
    }
    function sendMessage(MessagingHelper.ComposedMessage memory _msg) public {
        _lzSend(
            _msg._dstEid,
            _msg._message,
            _msg._options,
            _msg._fee,
            _msg._refundAddress
        );
    }
    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {}
}
