// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DataTypes.sol";
import "./ReserveConfiguration.sol";
import "./GenericLogic.sol";

library ValidationLogic {

using ReserveConfiguration
    for ReserveConfiguration.Map;

uint256 internal constant
    HEALTH_FACTOR_LIQUIDATION_THRESHOLD =
        1e18;

/**
 * ---------------------------------------------------
 * VALIDATE SUPPLY
 * ---------------------------------------------------
 */

function validateSupply(
    DataTypes.ReserveData
        storage reserve,

    uint256 amount
) internal view {

    require(
        amount > 0,
        "INVALID_AMOUNT"
    );

    require(
        reserve
            .configuration
            .getActive(),
        "RESERVE_INACTIVE"
    );

    require(
        !reserve
            .configuration
            .getPaused(),
        "RESERVE_PAUSED"
    );
}

/**
 * ---------------------------------------------------
 * VALIDATE WITHDRAW
 * ---------------------------------------------------
 */

function validateWithdraw(
    uint256 userBalance,
    uint256 amount
) internal pure {

    require(
        amount > 0,
        "INVALID_AMOUNT"
    );

    require(
        userBalance >= amount,
        "INSUFFICIENT_BALANCE"
    );
}

/**
 * ---------------------------------------------------
 * VALIDATE BORROW
 * ---------------------------------------------------
 */

function validateBorrow(
    DataTypes.ReserveData
        storage reserve,

    GenericLogic
        .UserAccountData
            memory accountData,

    uint256 amount
) internal view {

    require(
        amount > 0,
        "INVALID_AMOUNT"
    );

    require(
        reserve
            .configuration
            .getActive(),
        "RESERVE_INACTIVE"
    );

    require(
        !reserve
            .configuration
            .getPaused(),
        "RESERVE_PAUSED"
    );

    require(
        reserve
            .configuration
            .getBorrowingEnabled(),
        "BORROW_DISABLED"
    );

    require(
        reserve
            .totalSupplied >= amount,
        "NOT_ENOUGH_LIQUIDITY"
    );

    require(
        accountData
            .availableBorrowsBase >=
        amount,
        "NOT_ENOUGH_COLLATERAL"
    );
}

/**
 * ---------------------------------------------------
 * VALIDATE REPAY
 * ---------------------------------------------------
 */

function validateRepay(
    uint256 userDebt,
    uint256 amount
) internal pure {

    require(
        amount > 0,
        "INVALID_AMOUNT"
    );

    require(
        userDebt >= amount,
        "INVALID_REPAY_AMOUNT"
    );
}

/**
 * ---------------------------------------------------
 * VALIDATE HEALTH FACTOR
 * ---------------------------------------------------
 */

function validateHealthFactor(
    uint256 healthFactor
) internal pure {

    require(
        healthFactor >=
        HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
        "HEALTH_FACTOR_TOO_LOW"
    );
}

/**
 * ---------------------------------------------------
 * VALIDATE LIQUIDATION
 * ---------------------------------------------------
 */

function validateLiquidationCall(
    uint256 healthFactor
) internal pure {

    require(
        healthFactor <
        HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
        "HEALTH_FACTOR_OK"
    );
}

}
