// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ReserveLogic {

    uint256 internal constant
        PRECISION = 1e18;

    /**
     * ---------------------------------------------------
     * UTILIZATION RATE
     * ---------------------------------------------------
     */

    function utilizationRate(
        uint256 totalBorrowed,
        uint256 totalSupplied
    )
        internal
        pure
        returns (uint256)
    {
        if (totalSupplied == 0) {
            return 0;
        }

        return
            (
                totalBorrowed *
                PRECISION
            ) / totalSupplied;
    }

    /**
     * ---------------------------------------------------
     * DYNAMIC BORROW APY
     * ---------------------------------------------------
     */

    function calculateBorrowAPY(
        uint256 utilization
    )
        internal
        pure
        returns (uint256)
    {
        /**
         * 0-80% utilization
         * 2% -> 10%
         */

        if (
            utilization <=
            80e16
        ) {

            return
                200 +
                (
                    utilization * 800
                ) / 80e16;
        }

        /**
         * >80%
         * jump sharply
         */

        uint256 excess =
            utilization -
            80e16;

        return
            1000 +
            (
                excess * 4000
            ) / 20e16;
    }

    /**
     * ---------------------------------------------------
     * SUPPLY APY
     * ---------------------------------------------------
     */

    function calculateSupplyAPY(
        uint256 borrowAPY,
        uint256 utilization
    )
        internal
        pure
        returns (uint256)
    {
        return
            (
                borrowAPY *
                utilization
            ) / PRECISION;
    }
}