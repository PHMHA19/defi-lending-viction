// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library InterestLogic {

    uint256 internal constant
        PRECISION = 1e18;

    uint256 internal constant
        YEAR = 365 days;

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

        uint256 lastUpdateTimestamp;
    }

    /**
     * ---------------------------------------------------
     * UPDATE INDEXES
     * ---------------------------------------------------
     */

    function updateIndexes(
        ReserveData storage reserve
    ) internal {

        uint256 timeElapsed =
            block.timestamp -
            reserve.lastUpdateTimestamp;

        if (timeElapsed == 0) {
            return;
        }

        uint256 supplyInterest =
            (
                reserve.supplyAPY *
                timeElapsed *
                PRECISION
            ) / (10000 * YEAR);

        uint256 borrowInterest =
            (
                reserve.borrowAPY *
                timeElapsed *
                PRECISION
            ) / (10000 * YEAR);

        reserve.liquidityIndex +=
            (
                reserve.liquidityIndex *
                supplyInterest
            ) / PRECISION;

        reserve.borrowIndex +=
            (
                reserve.borrowIndex *
                borrowInterest
            ) / PRECISION;

        reserve.lastUpdateTimestamp =
            block.timestamp;
    }
}