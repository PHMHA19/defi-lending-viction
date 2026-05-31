// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./protocol/libraries/types/DataTypes.sol";
import "./protocol/libraries/configuration/ReserveConfiguration.sol";
import "./protocol/libraries/configuration/UserConfiguration.sol";

import "./oracle/AaveOracle.sol";

struct UserReserveData {
uint256 scaledATokenBalance;
uint256 scaledVariableDebt;
}

contract MiniAave is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;


    uint256 public constant PRECISION = 1e18;

    AaveOracle public oracle;

    mapping(address => DataTypes.ReserveData)
        public reserves;

    mapping(address => mapping(address => UserReserveData))
        internal userPositions;

    mapping(address => DataTypes.UserConfigurationMap)
        internal userConfigs;

    mapping(address => address)
        public aTokens;

    mapping(address => address)
        public debtTokens;

    address[] public reserveList;

    // =====================================================
    // EVENTS
    // =====================================================

    event ReserveAdded(
        address indexed asset,
        address aToken,
        address debtToken
    );

    event Supply(
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    event Withdraw(
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    event Borrow(
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    event Repay(
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    event Liquidation(
        address indexed liquidator,
        address indexed user,
        address collateralAsset,
        address debtAsset,
        uint256 repaidAmount,
        uint256 collateralTaken
    );

    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    constructor(address oracleAddress)
        Ownable(msg.sender)
    {
        oracle = AaveOracle(oracleAddress);
    }

    // =====================================================
    // ADMIN
    // =====================================================

    function addReserve(
        address asset,
        uint256 liquidityRate,
        uint256 borrowRate,
        uint256 ltv,
        uint256 liquidationThreshold,
        address strategyAddress
    ) external onlyOwner {

        require(
            !reserves[asset].configuration.getActive(),
            "RESERVE_EXISTS"
        );

        DataTypes.ReserveData
            storage reserve = reserves[asset];

        reserve.id = uint16(
            reserveList.length
        );

        reserve.liquidityIndex = PRECISION;

        reserve.currentLiquidityRate =
            liquidityRate;

        reserve.currentVariableBorrowRate =
            borrowRate;

        reserve.variableBorrowIndex = PRECISION;

        reserve.lastUpdateTimestamp =
            uint40(block.timestamp);

        reserve.interestRateStrategyAddress =
            strategyAddress;

        reserve.configuration.setActive(true);

        reserve.configuration.setBorrowingEnabled(true);

        reserve.configuration.setLtv(ltv);

        reserve.configuration
            .setLiquidationThreshold(
                liquidationThreshold
            );

        reserve.configuration
            .setLiquidationBonus(10500);

        reserveList.push(asset);

        AToken aToken =
            new AToken(
                IPool(address(this))
            );

        VariableDebtToken debtToken =
            new VariableDebtToken(
                IPool(address(this))
            );

        aTokens[asset] =
            address(aToken);

        debtTokens[asset] =
            address(debtToken);

        emit ReserveAdded(
            asset,
            address(aToken),
            address(debtToken)
        );
    }

    // =====================================================
    // SUPPLY
    // =====================================================

    function supply(
        address asset,
        uint256 amount
    ) external nonReentrant {

        require(amount > 0, "INVALID_AMOUNT");

        DataTypes.ReserveData
            storage reserve = reserves[asset];

        require(
            reserve.configuration.getActive(),
            "RESERVE_NOT_ACTIVE"
        );

        reserve.updateState();

        IERC20(asset).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        uint256 scaledAmount =
            amount * PRECISION /
            reserve.liquidityIndex;

        userPositions[msg.sender][asset]
            .scaledATokenBalance += scaledAmount;

        reserve.totalAToken += amount;

        userConfigs[msg.sender]
            .setUsingAsCollateral(
                reserve.id,
                true
            );

        emit Supply(
            msg.sender,
            asset,
            amount
        );
    }

    // =====================================================
    // WITHDRAW
    // =====================================================

    function withdraw(
        address asset,
        uint256 amount
    ) external nonReentrant {

        DataTypes.ReserveData
            storage reserve = reserves[asset];

        reserve.updateState();

        uint256 userBalance =
            getUserSupply(
                msg.sender,
                asset
            );

        require(
            userBalance >= amount,
            "INSUFFICIENT_BALANCE"
        );

        uint256 scaledAmount =
            amount * PRECISION /
            reserve.liquidityIndex;

        userPositions[msg.sender][asset]
            .scaledATokenBalance -= scaledAmount;

        reserve.totalAToken -= amount;

        IERC20(asset).safeTransfer(
            msg.sender,
            amount
        );

        uint256 hf = getHealthFactor(
            msg.sender
        );

        require(
            hf >= PRECISION,
            "HF_TOO_LOW"
        );

        emit Withdraw(
            msg.sender,
            asset,
            amount
        );
    }

    // =====================================================
    // BORROW
    // =====================================================

    function borrow(
        address asset,
        uint256 amount
    ) external nonReentrant {

        DataTypes.ReserveData
            storage reserve = reserves[asset];

        reserve.updateState();

        require(
            IERC20(asset).balanceOf(address(this))
                >= amount,
            "NOT_ENOUGH_LIQUIDITY"
        );

        GenericLogic
            .CalculateUserAccountDataVars
                memory vars;

        (
            vars.totalCollateralBase,
            vars.totalDebtBase,
            vars.avgLtv,
            vars.avgLiquidationThreshold,
            vars.healthFactor,

        ) = GenericLogic
                .calculateUserAccountData(
                    reserves,
                    reserveList,
                    userPositions,
                    userConfigs,
                    msg.sender,
                    address(oracle)
                );

        uint256 assetPrice =
            oracle.getAssetPrice(asset);

        uint256 borrowValue =
            amount * assetPrice /
            PRECISION;

        uint256 maxBorrow =
            vars.totalCollateralBase *
            vars.avgLtv /
            10000;

        require(
            vars.totalDebtBase + borrowValue
                <= maxBorrow,
            "NOT_ENOUGH_COLLATERAL"
        );

        uint256 scaledBorrow =
            amount * PRECISION /
            reserve.variableBorrowIndex;

        userPositions[msg.sender][asset]
            .scaledVariableDebt += scaledBorrow;

        reserve.totalVariableDebt += amount;

        userConfigs[msg.sender]
            .setBorrowing(
                reserve.id,
                true
            );

        IERC20(asset).safeTransfer(
            msg.sender,
            amount
        );

        emit Borrow(
            msg.sender,
            asset,
            amount
        );
    }

    // =====================================================
    // REPAY
    // =====================================================

    function repay(
        address asset,
        uint256 amount
    ) external nonReentrant {

        DataTypes.ReserveData
            storage reserve = reserves[asset];

        reserve.updateState();

        uint256 debt =
            getUserBorrow(
                msg.sender,
                asset
            );

        require(debt > 0, "NO_DEBT");

        if (amount > debt) {
            amount = debt;
        }

        IERC20(asset).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        uint256 scaledAmount =
            amount * PRECISION /
            reserve.variableBorrowIndex;

        userPositions[msg.sender][asset]
            .scaledVariableDebt -= scaledAmount;

        reserve.totalVariableDebt -= amount;

        emit Repay(
            msg.sender,
            asset,
            amount
        );
    }

    // =====================================================
    // LIQUIDATION
    // =====================================================

    function liquidate(
        address user,
        address collateralAsset,
        address debtAsset,
        uint256 debtToCover
    ) external nonReentrant {

        uint256 hf =
            getHealthFactor(user);

        require(
            hf < PRECISION,
            "HEALTHY_POSITION"
        );

        uint256 userDebt =
            getUserBorrow(
                user,
                debtAsset
            );

        require(
            userDebt >= debtToCover,
            "INVALID_DEBT"
        );

        IERC20(debtAsset)
            .safeTransferFrom(
                msg.sender,
                address(this),
                debtToCover
            );

        uint256 debtPrice =
            oracle.getAssetPrice(
                debtAsset
            );

        uint256 collateralPrice =
            oracle.getAssetPrice(
                collateralAsset
            );

        uint256 collateralAmount =
            (debtToCover * debtPrice * 10500)
            /
            (collateralPrice * 10000);

        DataTypes.ReserveData
            storage collateralReserve =
                reserves[collateralAsset];

        uint256 scaledCollateral =
            collateralAmount * PRECISION /
            collateralReserve.liquidityIndex;

        userPositions[user][collateralAsset]
            .scaledATokenBalance -=
                scaledCollateral;

        IERC20(collateralAsset)
            .safeTransfer(
                msg.sender,
                collateralAmount
            );

        emit Liquidation(
            msg.sender,
            user,
            collateralAsset,
            debtAsset,
            debtToCover,
            collateralAmount
        );
    }

    // =====================================================
    // VIEWS
    // =====================================================

    function getUserSupply(
        address user,
        address asset
    ) public view returns (uint256) {

        UserReserveData
            memory position =
                userPositions[user][asset];

        DataTypes.ReserveData
            memory reserve =
                reserves[asset];

        return
            position.scaledATokenBalance
            * reserve.liquidityIndex
            / PRECISION;
    }

    function getUserBorrow(
        address user,
        address asset
    ) public view returns (uint256) {

        UserReserveData
            memory position =
                userPositions[user][asset];

        DataTypes.ReserveData
            memory reserve =
                reserves[asset];

        return
            position.scaledVariableDebt
            * reserve.variableBorrowIndex
            / PRECISION;
    }

    function getHealthFactor(
        address user
    ) public view returns (uint256) {

        (
            ,
            ,
            ,
            ,
            ,
            uint256 healthFactor
        ) = getUserAccountData(user);

        return healthFactor;
    }

    function getUserAccountData(
        address user
    )
        public
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return GenericLogic
            .calculateUserAccountData(
                reserves,
                reserveList,
                userPositions,
                userConfigs,
                user,
                address(oracle)
            );
    }
}

*/