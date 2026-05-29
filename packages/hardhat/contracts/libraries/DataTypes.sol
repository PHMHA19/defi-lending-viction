// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ReserveConfiguration.sol";
import "./UserConfiguration.sol";

library DataTypes {

/**
 * ---------------------------------------------------
 * RESERVE DATA
 * ---------------------------------------------------
 */

struct ReserveData {

    /**
     * reserve id
     */

    uint16 id;

    /**
     * total supplied liquidity
     */

    uint256 totalSupplied;

    /**
     * total borrowed liquidity
     */

    uint256 totalBorrowed;

    /**
     * reserve active flag
     */

    bool isActive;

    /**
     * liquidity rate
     */

    uint256 currentLiquidityRate;

    /**
     * variable borrow rate
     */

    uint256 currentVariableBorrowRate;

    /**
     * reserve configuration map
     */

    ReserveConfiguration.Map
        configuration;

    /**
     * interest rate strategy
     */

    address
        interestRateStrategyAddress;

    /**
     * liquidity index
     */

    uint256 liquidityIndex;

    /**
     * variable borrow index
     */

    uint256 borrowIndex;

    /**
     * last update timestamp
     */

    uint40 lastUpdateTimestamp;
}

/**
 * ---------------------------------------------------
 * RESERVE CACHE
 * ---------------------------------------------------
 */

struct ReserveCache {

    /**
     * reserve indexes
     */

    uint256 currLiquidityIndex;

    uint256 currBorrowIndex;

    /**
     * reserve rates
     */

    uint256 currLiquidityRate;

    uint256 currVariableBorrowRate;

    /**
     * totals
     */

    uint256 totalSupplied;

    uint256 totalBorrowed;

    /**
     * token addresses
     */

    address aTokenAddress;

    address variableDebtTokenAddress;

    /**
     * timestamp
     */

    uint40 reserveLastUpdateTimestamp;
}

/**
 * ---------------------------------------------------
 * USER RESERVE DATA
 * ---------------------------------------------------
 */

struct UserReserveData {

    /**
     * scaled supplied balance
     */

    uint256 scaledSupply;

    /**
     * scaled borrowed balance
     */

    uint256 scaledBorrow;
}

/**
 * ---------------------------------------------------
 * USER CONFIGURATION MAP
 * ---------------------------------------------------
 */

struct UserConfigurationMap {

    uint256 data;
}

}
