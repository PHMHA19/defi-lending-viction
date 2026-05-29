// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    uint256 supplyAPY;

    uint256 borrowAPY;

    uint256 ltv;

    uint256 liquidationThreshold;

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
