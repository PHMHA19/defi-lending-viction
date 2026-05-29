// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ReserveConfiguration.sol";

library DataTypes {
/**
 * ---------------------------------------------------
 * RESERVE DATA
 * ---------------------------------------------------
 */

struct ReserveData {

    uint256 totalSupplied;

    uint256 totalBorrowed;

    bool isActive;

    uint256 currentLiquidityRate;

    uint256 currentVariableBorrowRate;

    ReserveConfiguration.Map
        configuration;

    address
        interestRateStrategyAddress;

    uint256 liquidityIndex;

    uint256 borrowIndex;

    uint40 lastUpdateTimestamp;
}

/**
 * ---------------------------------------------------
 * USER RESERVE DATA
 * ---------------------------------------------------
 */

struct UserReserveData {

    uint256 scaledSupply;

    uint256 scaledBorrow;
}
}
