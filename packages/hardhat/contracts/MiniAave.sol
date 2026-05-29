// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./AToken.sol";
import "./debt/VariableDebtToken.sol";

import "./libraries/InterestLogic.sol";
import "./libraries/ValidationLogic.sol";
import "./libraries/AccountLogic.sol";
import "./libraries/DataTypes.sol";
import "./libraries/ReserveConfiguration.sol";

import "./oracle/AaveOracle.sol";

import "./core/PoolAddressesProvider.sol";

import "./interest/DefaultReserveInterestRateStrategy.sol";

contract MiniAave {

using SafeERC20 for IERC20;

using InterestLogic
    for DataTypes.ReserveData;

using ReserveConfiguration
    for ReserveConfiguration.Map;

uint256 public constant PRECISION =
    1e18;

/**
 * ---------------------------------------------------
 * ADDRESSES PROVIDER
 * ---------------------------------------------------
 */

PoolAddressesProvider
    public addressesProvider;

/**
 * ---------------------------------------------------
 * RESERVES
 * ---------------------------------------------------
 */

mapping(
    address =>
        DataTypes.ReserveData
)
    public reserves;

/**
 * ---------------------------------------------------
 * USER POSITIONS
 * ---------------------------------------------------
 */

mapping(
    address =>
        mapping(
            address =>
                DataTypes
                    .UserReserveData
        )
)
    private userPositions;

/**
 * ---------------------------------------------------
 * RESERVE LIST
 * ---------------------------------------------------
 */

address[] public reserveList;

/**
 * ---------------------------------------------------
 * A TOKENS
 * ---------------------------------------------------
 */

mapping(address => address)
    public aTokens;

/**
 * ---------------------------------------------------
 * DEBT TOKENS
 * ---------------------------------------------------
 */

mapping(address => address)
    public debtTokens;

/**
 * ---------------------------------------------------
 * EVENTS
 * ---------------------------------------------------
 */

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

event ReserveDataUpdated(
    address indexed asset,
    uint256 liquidityRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 borrowIndex
);

/**
 * ---------------------------------------------------
 * ONLY CONFIGURATOR
 * ---------------------------------------------------
 */

modifier onlyConfigurator() {

    require(
        msg.sender ==
        addressesProvider
            .getPoolConfigurator(),
        "ONLY_CONFIGURATOR"
    );

    _;
}

/**
 * ---------------------------------------------------
 * CONSTRUCTOR
 * ---------------------------------------------------
 */

constructor(
    address provider
) {

    addressesProvider =
        PoolAddressesProvider(
            provider
        );
}

/**
 * ---------------------------------------------------
 * INTERNAL ORACLE
 * ---------------------------------------------------
 */

function _getOracle()
    internal
    view
    returns (AaveOracle)
{
    return
        AaveOracle(
            addressesProvider
                .getPriceOracle()
        );
}

/**
 * ---------------------------------------------------
 * ADD RESERVE
 * ---------------------------------------------------
 */

function addReserve(
    address asset,
    uint256 liquidityRate,
    uint256 variableBorrowRate,
    uint256 ltv,
    uint256 liquidationThreshold,
    address interestRateStrategy
)
    external
    onlyConfigurator
{

    require(
        !reserves[asset]
            .isActive,
        "RESERVE_EXISTS"
    );

    reserves[asset] =
        DataTypes.ReserveData({

        totalSupplied: 0,

        totalBorrowed: 0,

        isActive: true,

        currentLiquidityRate:
            liquidityRate,

        currentVariableBorrowRate:
            variableBorrowRate,

        configuration:
            ReserveConfiguration.Map({
                data: 0
            }),

        interestRateStrategyAddress:
            interestRateStrategy,

        liquidityIndex:
            PRECISION,

        borrowIndex:
            PRECISION,

        lastUpdateTimestamp:
            uint40(
                block.timestamp
            )
    });

    reserves[asset]
        .configuration
        .setLtv(ltv);

    reserves[asset]
        .configuration
        .setLiquidationThreshold(
            liquidationThreshold
        );

    reserveList.push(asset);

    /**
     * ---------------------------------------------------
     * CREATE A TOKEN
     * ---------------------------------------------------
     */

    AToken aToken =
        new AToken(
            "Aave Interest Token",
            "aTOKEN",
            address(this)
        );

    aTokens[asset] =
        address(aToken);

    /**
     * ---------------------------------------------------
     * CREATE DEBT TOKEN
     * ---------------------------------------------------
     */

    VariableDebtToken
        debtToken =
            new VariableDebtToken(
                "Variable Debt Token",
                "vdTOKEN",
                address(this)
            );

    debtTokens[asset] =
        address(debtToken);
}

/**
 * ---------------------------------------------------
 * UPDATE RESERVE INTEREST RATES
 * ---------------------------------------------------
 */

function updateReserveInterestRates(
    address asset
) internal {

    DataTypes.ReserveData
        storage reserve =
            reserves[asset];

    /**
     * ---------------------------------------------------
     * LOAD STRATEGY
     * ---------------------------------------------------
     */

    DefaultReserveInterestRateStrategy
        strategy =
            DefaultReserveInterestRateStrategy(
                reserve
                    .interestRateStrategyAddress
            );

    /**
     * ---------------------------------------------------
     * UTILIZATION
     * ---------------------------------------------------
     */

    uint256 utilization =
        strategy
            .calculateUtilizationRate(
                reserve
                    .totalBorrowed,

                reserve
                    .totalSupplied
            );

    /**
     * ---------------------------------------------------
     * VARIABLE BORROW RATE
     * ---------------------------------------------------
     */

    reserve
        .currentVariableBorrowRate =
        strategy
            .calculateBorrowRate(
                utilization
            );

    /**
     * ---------------------------------------------------
     * LIQUIDITY RATE
     * ---------------------------------------------------
     */

    reserve
        .currentLiquidityRate =
        strategy
            .calculateLiquidityRate(
                reserve
                    .currentVariableBorrowRate,

                utilization
            );

    emit ReserveDataUpdated(
        asset,

        reserve
            .currentLiquidityRate,

        reserve
            .currentVariableBorrowRate,

        reserve
            .liquidityIndex,

        reserve
            .borrowIndex
    );
}

/**
 * ---------------------------------------------------
 * SUPPLY
 * ---------------------------------------------------
 */

function supply(
    address asset,
    uint256 amount
) external {

    DataTypes.ReserveData
        storage reserve =
            reserves[asset];

    reserve.updateState();

    require(
        reserve.isActive,
        "RESERVE_INACTIVE"
    );

    ValidationLogic
        .validateAmount(amount);

    IERC20(asset)
        .safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

    uint256 scaledAmount =
        (
            amount *
            PRECISION
        ) /
        reserve
            .liquidityIndex;

    userPositions[
        msg.sender
    ][asset]
        .scaledSupply +=
            scaledAmount;

    reserve.totalSupplied +=
        amount;

    AToken(
        aTokens[asset]
    ).mint(
        msg.sender,
        amount
    );

    updateReserveInterestRates(
        asset
    );

    emit Supply(
        msg.sender,
        asset,
        amount
    );
}

/**
 * ---------------------------------------------------
 * WITHDRAW
 * ---------------------------------------------------
 */

function withdraw(
    address asset,
    uint256 amount
) external {

    DataTypes.ReserveData
        storage reserve =
            reserves[asset];

    reserve.updateState();

    DataTypes.UserReserveData
        storage user =
            userPositions[
                msg.sender
            ][asset];

    uint256 actualSupply =
        getUserSupply(
            msg.sender,
            asset
        );

    require(
        actualSupply >= amount,
        "INSUFFICIENT_BALANCE"
    );

    uint256 scaledAmount =
        (
            amount *
            PRECISION
        ) /
        reserve
            .liquidityIndex;

    user.scaledSupply -=
        scaledAmount;

    reserve.totalSupplied -=
        amount;

    AToken(
        aTokens[asset]
    ).burn(
        msg.sender,
        amount
    );

    IERC20(asset)
        .safeTransfer(
            msg.sender,
            amount
        );

    updateReserveInterestRates(
        asset
    );

    emit Withdraw(
        msg.sender,
        asset,
        amount
    );
}

/**
 * ---------------------------------------------------
 * BORROW
 * ---------------------------------------------------
 */

function borrow(
    address asset,
    uint256 amount
) external {

    DataTypes.ReserveData
        storage reserve =
            reserves[asset];

    reserve.updateState();

    require(
        reserve.isActive,
        "RESERVE_INACTIVE"
    );

    ValidationLogic
        .validateLiquidity(
            reserve
                .totalSupplied,
            amount
        );

    uint256 totalDebt =
        getTotalDebt(
            msg.sender
        );

    uint256 borrowPower =
        getBorrowPower(
            msg.sender
        );

    ValidationLogic
        .validateCollateral(
            borrowPower,
            totalDebt,
            amount
        );

    uint256 scaledBorrow =
        (
            amount *
            PRECISION
        ) /
        reserve
            .borrowIndex;

    userPositions[
        msg.sender
    ][asset]
        .scaledBorrow +=
            scaledBorrow;

    reserve.totalBorrowed +=
        amount;

    VariableDebtToken(
        debtTokens[asset]
    ).mint(
        msg.sender,
        amount
    );

    IERC20(asset)
        .safeTransfer(
            msg.sender,
            amount
        );

    updateReserveInterestRates(
        asset
    );

    emit Borrow(
        msg.sender,
        asset,
        amount
    );
}

/**
 * ---------------------------------------------------
 * REPAY
 * ---------------------------------------------------
 */

function repay(
    address asset,
    uint256 amount
) external {

    DataTypes.ReserveData
        storage reserve =
            reserves[asset];

    reserve.updateState();

    uint256 actualDebt =
        getUserBorrow(
            msg.sender,
            asset
        );

    require(
        actualDebt >= amount,
        "INVALID_REPAY"
    );

    IERC20(asset)
        .safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

    uint256 scaledAmount =
        (
            amount *
            PRECISION
        ) /
        reserve
            .borrowIndex;

    userPositions[
        msg.sender
    ][asset]
        .scaledBorrow -=
            scaledAmount;

    reserve.totalBorrowed -=
        amount;

    VariableDebtToken(
        debtTokens[asset]
    ).burn(
        msg.sender,
        amount
    );

    updateReserveInterestRates(
        asset
    );

    emit Repay(
        msg.sender,
        asset,
        amount
    );
}

/**
 * ---------------------------------------------------
 * USER SUPPLY
 * ---------------------------------------------------
 */

function getUserSupply(
    address user,
    address asset
)
    public
    view
    returns (uint256)
{
    DataTypes.UserReserveData
        memory position =
            userPositions[
                user
            ][asset];

    DataTypes.ReserveData
        memory reserve =
            reserves[asset];

    return
        (
            position
                .scaledSupply *
            reserve
                .liquidityIndex
        ) / PRECISION;
}

/**
 * ---------------------------------------------------
 * USER BORROW
 * ---------------------------------------------------
 */

function getUserBorrow(
    address user,
    address asset
)
    public
    view
    returns (uint256)
{
    DataTypes.UserReserveData
        memory position =
            userPositions[
                user
            ][asset];

    DataTypes.ReserveData
        memory reserve =
            reserves[asset];

    return
        (
            position
                .scaledBorrow *
            reserve
                .borrowIndex
        ) / PRECISION;
}

/**
 * ---------------------------------------------------
 * TOTAL COLLATERAL
 * ---------------------------------------------------
 */

function getTotalCollateral(
    address user
)
    public
    view
    returns (uint256)
{
    uint256 total = 0;

    for (
        uint256 i = 0;
        i < reserveList.length;
        i++
    ) {

        address asset =
            reserveList[i];

        uint256 amount =
            getUserSupply(
                user,
                asset
            );

        uint256 price =
            _getOracle()
                .getAssetPrice(
                    asset
                );

        total +=
            (
                amount *
                price
            ) / PRECISION;
    }

    return total;
}

/**
 * ---------------------------------------------------
 * TOTAL DEBT
 * ---------------------------------------------------
 */

function getTotalDebt(
    address user
)
    public
    view
    returns (uint256)
{
    uint256 total = 0;

    for (
        uint256 i = 0;
        i < reserveList.length;
        i++
    ) {

        address asset =
            reserveList[i];

        uint256 amount =
            getUserBorrow(
                user,
                asset
            );

        uint256 price =
            _getOracle()
                .getAssetPrice(
                    asset
                );

        total +=
            (
                amount *
                price
            ) / PRECISION;
    }

    return total;
}

/**
 * ---------------------------------------------------
 * BORROW POWER
 * ---------------------------------------------------
 */

function getBorrowPower(
    address user
)
    public
    view
    returns (uint256)
{
    uint256 power = 0;

    for (
        uint256 i = 0;
        i < reserveList.length;
        i++
    ) {

        address asset =
            reserveList[i];

        DataTypes.ReserveData
            storage reserve =
                reserves[asset];

        uint256 supplied =
            getUserSupply(
                user,
                asset
            );

        uint256 price =
            _getOracle()
                .getAssetPrice(
                    asset
                );

        uint256 suppliedUsd =
            (
                supplied *
                price
            ) / PRECISION;

        power +=
            (
                suppliedUsd *
                reserve
                    .configuration
                    .getLtv()
            ) / 10000;
    }

    return power;
}

/**
 * ---------------------------------------------------
 * HEALTH FACTOR
 * ---------------------------------------------------
 */

function getHealthFactor(
    address user
)
    public
    view
    returns (uint256)
{
    uint256 debt =
        getTotalDebt(user);

    uint256 liquidationPower =
        0;

    for (
        uint256 i = 0;
        i < reserveList.length;
        i++
    ) {

        address asset =
            reserveList[i];

        DataTypes.ReserveData
            storage reserve =
                reserves[asset];

        uint256 supplied =
            getUserSupply(
                user,
                asset
            );

        uint256 price =
            _getOracle()
                .getAssetPrice(
                    asset
                );

        uint256 suppliedUsd =
            (
                supplied *
                price
            ) / PRECISION;

        liquidationPower +=
            (
                suppliedUsd *
                reserve
                    .configuration
                    .getLiquidationThreshold()
            ) / 10000;
    }

    return
        AccountLogic
            .calculateHealthFactor(
                liquidationPower,
                debt
            );
}

/**
 * ---------------------------------------------------
 * ACCOUNT DATA
 * ---------------------------------------------------
 */

function getUserAccountData(
    address user
)
    external
    view
    returns (
        uint256 totalCollateral,
        uint256 totalDebt,
        uint256 availableBorrow,
        uint256 healthFactor
    )
{
    uint256 collateral =
        getTotalCollateral(
            user
        );

    uint256 debt =
        getTotalDebt(
            user
        );

    uint256 borrowPower =
        getBorrowPower(
            user
        );

    uint256 hf =
        getHealthFactor(
            user
        );

    return (
        collateral,
        debt,

        borrowPower > debt
            ? borrowPower - debt
            : 0,

        hf
    );
}

}
