// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./tokenization/AToken.sol";

import "./tokenization/VariableDebtToken.sol";

import "./libraries/InterestLogic.sol";
import "./libraries/ValidationLogic.sol";
import "./libraries/DataTypes.sol";
import "./libraries/ReserveConfiguration.sol";
import "./libraries/UserConfiguration.sol";
import "./libraries/GenericLogic.sol";

import "./oracle/AaveOracle.sol";

import "./core/PoolAddressesProvider.sol";

import "./interest/DefaultReserveInterestRateStrategy.sol";

contract MiniAave {

using SafeERC20 for IERC20;

using InterestLogic
    for DataTypes.ReserveData;

using ReserveConfiguration
    for ReserveConfiguration.Map;

using UserConfiguration
    for DataTypes.UserConfigurationMap;

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
 * USER CONFIG
 * ---------------------------------------------------
 */

mapping(
    address =>
        DataTypes.UserConfigurationMap
)
    internal userConfig;

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
 * INTERNAL PRICE
 * ---------------------------------------------------
 */

function _getAssetPrice(
    address asset
)
    internal
    view
    returns (uint256)
{
    return
        _getOracle()
            .getAssetPrice(
                asset
            );
}

/**
 * ---------------------------------------------------
 * INTERNAL ACCOUNT DATA
 * ---------------------------------------------------
 */

function _getUserAccountData(
    address user
)
    internal
    view
    returns (
        GenericLogic
            .UserAccountData
                memory
    )
{
    return
        GenericLogic
            .calculateUserAccountData(

                reserves,

                reserveList,

                userPositions,

                userConfig,

                user,

                _getAssetPrice
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

        id:
            uint16(
                reserveList.length
            ),

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

    reserves[asset]
        .configuration
        .setLiquidationBonus(
            10500
        );

    reserves[asset]
        .configuration
        .setActive(true);

    reserves[asset]
        .configuration
        .setBorrowingEnabled(
            true
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

    DefaultReserveInterestRateStrategy
        strategy =
            DefaultReserveInterestRateStrategy(
                reserve
                    .interestRateStrategyAddress
            );

    uint256 utilization =
        strategy
            .calculateUtilizationRate(
                reserve
                    .totalBorrowed,

                reserve
                    .totalSupplied
            );

    reserve
        .currentVariableBorrowRate =
        strategy
            .calculateBorrowRate(
                utilization
            );

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

    ValidationLogic
        .validateSupply(
            reserve,
            amount
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
            .liquidityIndex;

    userPositions[
        msg.sender
    ][asset]
        .scaledSupply +=
            scaledAmount;

    userConfig[msg.sender]
        .setUsingAsCollateral(
            reserve.id,
            true
        );

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

    uint256 actualSupply =
        getUserSupply(
            msg.sender,
            asset
        );

    ValidationLogic
        .validateWithdraw(
            actualSupply,
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
        .scaledSupply -=
            scaledAmount;

    if (
        userPositions[
            msg.sender
        ][asset]
            .scaledSupply == 0
    ) {

        userConfig[msg.sender]
            .setUsingAsCollateral(
                reserve.id,
                false
            );
    }

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

    /**
     * ---------------------------------------------------
     * HEALTH FACTOR CHECK
     * ---------------------------------------------------
     */

    uint256 healthFactor =
        _getUserAccountData(
            msg.sender
        ).healthFactor;

    ValidationLogic
        .validateHealthFactor(
            healthFactor
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

    GenericLogic
        .UserAccountData
            memory accountData =
                _getUserAccountData(
                    msg.sender
                );

    ValidationLogic
        .validateBorrow(
            reserve,
            accountData,
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

    userConfig[msg.sender]
        .setBorrowing(
            reserve.id,
            true
        );

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

    ValidationLogic
        .validateRepay(
            actualDebt,
            amount
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

    if (
        userPositions[
            msg.sender
        ][asset]
            .scaledBorrow == 0
    ) {

        userConfig[msg.sender]
            .setBorrowing(
                reserve.id,
                false
            );
    }

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
    return
        _getUserAccountData(
            user
        ).healthFactor;
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
        uint256 totalCollateralBase,
        uint256 totalDebtBase,
        uint256 availableBorrowsBase,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    )
{
    GenericLogic
        .UserAccountData
            memory data =
                _getUserAccountData(
                    user
                );

    return (
        data.totalCollateralBase,

        data.totalDebtBase,

        data.availableBorrowsBase,

        data.currentLiquidationThreshold,

        data.ltv,

        data.healthFactor
    );
}

}
