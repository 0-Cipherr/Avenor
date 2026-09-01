// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    ERC4626
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ReadCodecV1,
    EVMCallRequestV1
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/ReadCodecV1.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {
    OApp,
    Origin,
    MessagingFee
} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {VaultHelper} from "./VaultHelper.sol";
import {MessagingHelper} from "./MessagingHelper.sol";
import {StrategyHelper} from "./StrategyHelper.sol";
import {VaultAssets} from "../src/VaultAssets.sol";
import {VaultStrategies} from "./VaultStrategies.sol";

contract VaultManager is Ownable, OApp, VaultAssets, VaultStrategies {
    address creator;
    uint256 vaultTotalAssets;
    uint256 idleAssets;
    uint256 totalSupply;

    IERC20 vaultAsset;
    address creatorFeeReciever;
    address protoclFeeReceiver;

    constructor(
        string memory vaultName,
        string memory vaultTicker,
        IERC20 _vaultAsset,
        address _creator,
        address _endpoint,
        uint256 _creatorFee,
        uint256 _protocolFee,
        address _creatorFeeReciever,
        address _protoclFeeReceiver,
        IERC20 _asset
    )
        Ownable(_creator)
        OApp(_endpoint, _creator)
        VaultAssets(vaultName, vaultTicker, _asset, _creatorFee, _protocolFee)
        VaultStrategies()
    {
        vaultAsset = _vaultAsset;
        creator = _creator;
        creatorFee = _creatorFee;
        protocolFee = _protocolFee;

        creatorFeeReciever = _creatorFeeReciever;
        protoclFeeReceiver = _protoclFeeReceiver;
    }

    mapping(address => VaultHelper.DepositorInfo) depositors;

    // bytes strategyInfo //bytes suppose dot be strategy info struct containing info and addresses

    function getAsset() public view returns (IERC20) {
        return vaultAsset;
    }

    function getCreator() public view returns (address) {
        return creator;
    }

    function getAuthorizer() public view returns (address) {}

    function setDepositor(
        address _depositor,
        VaultHelper.DepositorInfo memory _info
    ) public {
        depositors[_depositor] = _info;
    }

    function crossChainDeposit(
        uint32 _dstEid,
        uint256 assets,
        address receiver
    ) public {}

    function deposit(
        uint256 assets,
        address receiver
    ) public override returns (uint256 _shares) {
        require(receiver == msg.sender, "caller is not the set reciever");
        require(msg.value == assets, "Missing ETH To Complete!");
        _shares = convertToShares(assets);
        mintShares(_shares, receiver);
        if (hasDeposited(receiver) != true) {
            setDepositor(
                receiver,
                VaultHelper.DepositorInfo(receiver, assets, _shares, assets)
            );
        } else {
            setSharesOwned(_shares, receiver, false);
            setVolume(receiver, assets);
        }

        emit Deposit(receiver, receiver, assets, _shares);

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
            ? shares[_shareOwner] -= _amount
            : shares[_shareOwner] += _amount;
    }

    function withdraw(
        uint256 _shares,
        address receiver,
        uint256 _amount,
        bool sendFunds
    ) public {
        require(receiver == msg.sender, "Not owner");
        uint256 _total = previewWithdraw(_shares);

        setAssetsDeposited(_amount - _total, receiver, true);
        emit Withdraw(receiver, receiver, receiver, _total, _shares);
        // withdraw out of vault to user
    }

    function withdrawCrossChainQuote(
        address _user,
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options
    ) public returns (MessagingHelper.ComposedMessage memory _quote) {
        (MessagingHelper.ComposedMessage memory fee) = messageQuote(
            _dstEid,
            _message,
            _options,
            false,
            _user
        );
        _quote = fee;
    }
    function withdrawCrossChain(
        uint32 _dstEid,
        address _reciever,
        uint256 _amount
    ) public {}

    //must verify asset is bridged before using or executing
    function payUser(address _user, uint256 _amount) public returns (bool) {
        (bool success, ) = payable(_user).call{value: _amount}("");
        require(success != false, "User was not paid");
        return success;
    }

    /*//////////////////////////////////////////////////////////////
                           STRATEGY MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                VIEWS
    //////////////////////////////////////////////////////////////*/

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
        Origin calldata,
        /*_origin*/
        bytes32,
        /*_guid*/
        bytes calldata _message,
        address,
        /*_executor*/
        bytes calldata /*_extraData*/
    ) internal override {}
}
