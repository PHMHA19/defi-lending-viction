// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library UserConfiguration {

struct Map {

    uint256 data;
}

/**
 * ---------------------------------------------------
 * COLLATERAL BIT
 * ---------------------------------------------------
 */

function setUsingAsCollateral(
    Map storage self,
    uint256 reserveIndex,
    bool usingAsCollateral
) internal {

    uint256 bit =
        1 << (reserveIndex * 2);

    if (usingAsCollateral) {

        self.data =
            self.data | bit;

    } else {

        self.data =
            self.data & (~bit);
    }
}

/**
 * ---------------------------------------------------
 * BORROWING BIT
 * ---------------------------------------------------
 */

function setBorrowing(
    Map storage self,
    uint256 reserveIndex,
    bool borrowing
) internal {

    uint256 bit =
        1 << (
            reserveIndex * 2 + 1
        );

    if (borrowing) {

        self.data =
            self.data | bit;

    } else {

        self.data =
            self.data & (~bit);
    }
}

/**
 * ---------------------------------------------------
 * IS USING AS COLLATERAL
 * ---------------------------------------------------
 */

function isUsingAsCollateral(
    Map storage self,
    uint256 reserveIndex
)
    internal
    view
    returns (bool)
{
    return
        (
            self.data >>
            (reserveIndex * 2)
        ) & 1 != 0;
}

/**
 * ---------------------------------------------------
 * IS BORROWING
 * ---------------------------------------------------
 */

function isBorrowing(
    Map storage self,
    uint256 reserveIndex
)
    internal
    view
    returns (bool)
{
    return
        (
            self.data >>
            (
                reserveIndex * 2 + 1
            )
        ) & 1 != 0;
}


}
