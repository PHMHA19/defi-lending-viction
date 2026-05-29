// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./AToken.sol";
import "./debt/VariableDebtToken.sol";

import "./libraries/InterestLogic.sol";
import "./libraries/ValidationLogic.sol";
import "./libraries/AccountLogic.sol";
import "./libraries/ReserveLogic.sol";

contract MiniAave {

using SafeERC20 for IERC20;

using InterestLogic
    for InterestLogic.ReserveData;

using ReserveLogic for uint256;

uint256 public constant PRECISION =
    1e18;

struct UserReserveData {

    uint256 scaledSupply;
    uint256 scaledBorrow;
}

// asset => reserve
mapping(
    address =>
        InterestLogic.ReserveData
)
    public reserves;

// user => asset => position
mapping(
    address =>
        mapping(
            address =>
                UserReserveData
        )
)
    private userPositions;

// list reserves
address[] public reserveList;

// asset => aToken
mapping(address => address)
    public aTokens;

// asset => debt token
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

/**
 * ---------------------------------------------------
 * ADD RESERVE
 * ---------------------------------------------------
 */

function addReserve(
    address asset,
    uint256 supplyAPY,
    uint256 borrowAPY,
    uint256 ltv,
    uint256 liquidationThreshold
) external {

    require(
        !reserves[asset].isActive,
        "RESERVE_EXISTS"
    );

    reserves[asset] =
        InterestLogic.ReserveData({

        totalSupplied: 0,
        totalBorrowed: 0,

        isActive: true,

        supplyAPY: supplyAPY,
        borrowAPY: borrowAPY,

        ltv: ltv,
        liquidationThreshold:
            liquidationThreshold,

        liquidityIndex:
            PRECISION,

        borrowIndex:
            PRECISION,

        lastUpdateTimestamp:
            block.timestamp
    });

    reserveList.push(asset);

    // deploy aToken
    AToken aToken =
        new AToken(
            "Aave Interest Token",
            "aTOKEN",
            address(this)
        );

    aTokens[asset] =
        address(aToken);

    // deploy debt token
    VariableDebtToken debtToken =
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
 * UPDATE INTEREST RATES
 * ---------------------------------------------------
 */

function updateInterestRates(
    address asset
) internal {

    InterestLogic.ReserveData
        storage reserve =
            reserves[asset];

    uint256 utilization =
        ReserveLogic
            .utilizationRate(
                reserve.totalBorrowed,
                reserve.totalSupplied
            );

    reserve.borrowAPY =
        ReserveLogic
            .calculateBorrowAPY(
                utilization
            );

    reserve.supplyAPY =
        ReserveLogic
            .calculateSupplyAPY(
                reserve.borrowAPY,
                utilization
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

    InterestLogic.ReserveData
        storage reserve =
            reserves[asset];

    reserve.updateIndexes();

    require(
        reserve.isActive,
        "RESERVE_INACTIVE"
    );

    ValidationLogic
        .validateAmount(amount);

    IERC20(asset).safeTransferFrom(
        msg.sender,
        address(this),
        amount
    );

    uint256 scaledAmount =
        (
            amount *
            PRECISION
        ) / reserve.liquidityIndex;

    userPositions[msg.sender][asset]
        .scaledSupply +=
            scaledAmount;

    reserve.totalSupplied += amount;

    // mint aToken
    AToken(
        aTokens[asset]
    ).mint(
        msg.sender,
        amount
    );

    updateInterestRates(asset);

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

    InterestLogic.ReserveData
        storage reserve =
            reserves[asset];

    reserve.updateIndexes();

    UserReserveData
        storage user =
            userPositions[msg.sender][asset];

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
        ) / reserve.liquidityIndex;

    user.scaledSupply -=
        scaledAmount;

    reserve.totalSupplied -= amount;

    // burn aToken
    AToken(
        aTokens[asset]
    ).burn(
        msg.sender,
        amount
    );

    IERC20(asset).safeTransfer(
        msg.sender,
        amount
    );

    updateInterestRates(asset);

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

    InterestLogic.ReserveData
        storage reserve =
            reserves[asset];

    reserve.updateIndexes();

    require(
        reserve.isActive,
        "RESERVE_INACTIVE"
    );

    ValidationLogic
        .validateLiquidity(
            reserve.totalSupplied,
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
        ) / reserve.borrowIndex;

    userPositions[msg.sender][asset]
        .scaledBorrow +=
            scaledBorrow;

    reserve.totalBorrowed += amount;

    // mint debt token
    VariableDebtToken(
        debtTokens[asset]
    ).mint(
        msg.sender,
        amount
    );

    IERC20(asset).safeTransfer(
        msg.sender,
        amount
    );

    updateInterestRates(asset);

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

    InterestLogic.ReserveData
        storage reserve =
            reserves[asset];

    reserve.updateIndexes();

    uint256 actualDebt =
        getUserBorrow(
            msg.sender,
            asset
        );

    require(
        actualDebt >= amount,
        "INVALID_REPAY"
    );

    IERC20(asset).safeTransferFrom(
        msg.sender,
        address(this),
        amount
    );

    uint256 scaledAmount =
        (
            amount *
            PRECISION
        ) / reserve.borrowIndex;

    userPositions[msg.sender][asset]
        .scaledBorrow -=
            scaledAmount;

    reserve.totalBorrowed -= amount;

    // burn debt token
    VariableDebtToken(
        debtTokens[asset]
    ).burn(
        msg.sender,
        amount
    );

    updateInterestRates(asset);

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
    UserReserveData memory position =
        userPositions[user][asset];

    InterestLogic.ReserveData
        memory reserve =
            reserves[asset];

    return
        (
            position.scaledSupply *
            reserve.liquidityIndex
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
    UserReserveData memory position =
        userPositions[user][asset];

    InterestLogic.ReserveData
        memory reserve =
            reserves[asset];

    return
        (
            position.scaledBorrow *
            reserve.borrowIndex
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
        total +=
            getUserSupply(
                user,
                reserveList[i]
            );
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
        total +=
            getUserBorrow(
                user,
                reserveList[i]
            );
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

        InterestLogic.ReserveData
            memory reserve =
                reserves[asset];

        uint256 supplied =
            getUserSupply(
                user,
                asset
            );

        power +=
            (
                supplied *
                reserve.ltv
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

    uint256 liquidationPower = 0;

    for (
        uint256 i = 0;
        i < reserveList.length;
        i++
    ) {

        address asset =
            reserveList[i];

        InterestLogic.ReserveData
            memory reserve =
                reserves[asset];

        uint256 supplied =
            getUserSupply(
                user,
                asset
            );

        liquidationPower +=
            (
                supplied *
                reserve
                    .liquidationThreshold
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
        getTotalCollateral(user);

    uint256 debt =
        getTotalDebt(user);

    uint256 borrowPower =
        getBorrowPower(user);

    uint256 hf =
        getHealthFactor(user);

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
