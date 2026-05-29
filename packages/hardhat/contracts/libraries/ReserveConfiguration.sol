// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ReserveConfiguration {

struct Map {

    uint256 data;
}

/**
 * ---------------------------------------------------
 * BIT MASKS
 * ---------------------------------------------------
 */

uint256 internal constant
    LTV_MASK =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000;

uint256 internal constant
    LIQUIDATION_THRESHOLD_MASK =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF;

/**
 * ---------------------------------------------------
 * START POSITIONS
 * ---------------------------------------------------
 */

uint256 internal constant
    LIQUIDATION_THRESHOLD_START_BIT_POSITION =
        16;

/**
 * ---------------------------------------------------
 * SET LTV
 * ---------------------------------------------------
 */

function setLtv(
    Map storage self,
    uint256 ltv
) internal {

    self.data =
        (
            self.data &
            LTV_MASK
        ) | ltv;
}

/**
 * ---------------------------------------------------
 * GET LTV
 * ---------------------------------------------------
 */

function getLtv(
    Map storage self
)
    internal
    view
    returns (uint256)
{
    return
        self.data &
        ~LTV_MASK;
}

/**
 * ---------------------------------------------------
 * SET LIQUIDATION THRESHOLD
 * ---------------------------------------------------
 */

function setLiquidationThreshold(
    Map storage self,
    uint256 threshold
) internal {

    self.data =
        (
            self.data &
            LIQUIDATION_THRESHOLD_MASK
        ) |
        (
            threshold <<
            LIQUIDATION_THRESHOLD_START_BIT_POSITION
        );
}

/**
 * ---------------------------------------------------
 * GET LIQUIDATION THRESHOLD
 * ---------------------------------------------------
 */

function getLiquidationThreshold(
    Map storage self
)
    internal
    view
    returns (uint256)
{
    return
        (
            self.data &
            ~LIQUIDATION_THRESHOLD_MASK
        ) >>
        LIQUIDATION_THRESHOLD_START_BIT_POSITION;
}
}
