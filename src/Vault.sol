// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {
    OAppOptionsType3
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
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
contract Vault is Ownable, OApp {
    address vaultAsset;
    address creator;
    uint256 totalAssets;
    uint256 idleAssets;
    uint256 totalSupply;
    uint256 creatorFee;
    uint256 protocolFee;
    address asset;

    constructor(
        address _vaultAsset,
        address _creator,
        address _endpoint,
        uint256 _creatorFee,
        uint256 _protocolFee,
        address _asset
    ) Ownable(_creator) OApp(_endpoint, _creator) {
        vaultAsset = _vaultAsset;
        creator = _creator;
        creatorFee = _creatorFee;
        protocolFee = _protocolFee;
        asset = _asset;
    }

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

    event Harvest(
        address indexed strategy,
        uint256 totalAssets,
        int256 profitOrLoss
    );

    struct DepositorInfo {
        address depositor;
        uint256 assets;
        uint256 shares;
        uint256 assetVolume;
    }

    mapping(address => DepositorInfo) depositors;
    /*//////////////////////////////////////////////////////////////
                                Messaging
    //////////////////////////////////////////////////////////////*/

    struct ComposedMessage {
        uint32 _dstEid;
        MessagingFee _fee;
        bytes _message;
        bytes _options;
        bool payInLzToken;
        address _refundAddress;
    }

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    struct StrategyPosition {
        bool enabled;
        uint256 debt;
        uint256 lastReportedAssets;
    }
    // bytes strategyInfo //bytes suppose dot be strategy info struct containing info and addresses

    StrategyPosition strategyPosition;

    /*//////////////////////////////////////////////////////////////
                             VAULT METADATA
    //////////////////////////////////////////////////////////////*/

    function getAsset() public view returns (address) {
        return vaultAsset;
    }

    function getCreator() public view returns (address) {
        return creator;
    }

    function getAuthorizer() public view returns (address) {}

    /*//////////////////////////////////////////////////////////////
                              ACCOUNTING
    //////////////////////////////////////////////////////////////*/

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
    ) public view returns (uint256 shares) {
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
    mapping(address => uint256) sharesOwned;
    mapping(address => uint256) assetsDeposited;

    function setDepositor(
        address _depositor,
        DepositorInfo memory _info
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
                DepositorInfo(receiver, assets, shares, assets)
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
        emit StrategyAdded(_strategy);
    }

    function removeStrategy(address _strategy) public {
        emit StrategyRemoved(_strategy);
    }

    function deployCapital(
        address _strategy,
        uint256 assets,
        bytes calldata data
    ) public returns (uint256 assetsDeployed) {
        emit CapitalDeployed(_strategy, assets);
    }

    function withdrawCapital(
        address _strategy,
        uint256 assets,
        bytes calldata data
    ) public returns (uint256 assetsReturned) {
        emit CapitalReturned(_strategy, assets);
    }

    function harvest(
        address _strategy,
        bytes calldata data
    ) public returns (uint256 currentAssets, int256 profitOrLoss) {
        emit Harvest(_strategy, totalAssets, profitOrLoss);
    }

    /*//////////////////////////////////////////////////////////////
                                VIEWS
    //////////////////////////////////////////////////////////////*/

    function getStrategies() public view returns (address[] memory) {}

    function getStrategyPosition()
        public
        view
        returns (StrategyPosition memory)
    {
        return strategyPosition;
    }
    function messageQuote(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        bool _payLzToken,
        address _refundAddress
    ) public view returns (ComposedMessage memory) {
        MessagingFee memory _fee = _quote(
            _dstEid,
            _message,
            _options,
            _payLzToken
        );
        return
            ComposedMessage(
                _dstEid,
                _fee,
                _message,
                _options,
                _payLzToken,
                _refundAddress
            );
    }
    function sendMessage(ComposedMessage memory _msg) public {
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
