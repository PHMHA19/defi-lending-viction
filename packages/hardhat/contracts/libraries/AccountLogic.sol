// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AccountLogic {

    uint256 internal constant
        PRECISION = 1e18;

    function calculateHealthFactor(
        uint256 liquidationPower,
        uint256 debt
    )
        internal
        pure
        returns (uint256)
    {
        if (debt == 0) {
            return type(uint256).max;
        }

        return
            (
                liquidationPower *
                PRECISION
            ) / debt;
    }
}