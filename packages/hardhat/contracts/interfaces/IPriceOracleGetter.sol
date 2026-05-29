// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceOracleGetter {

/**
 * @notice Returns asset price in BASE_CURRENCY
 */

function getAssetPrice(
    address asset
)
    external
    view
    returns (uint256);

/**
 * @notice Returns base currency
 */

function BASE_CURRENCY()
    external
    view
    returns (address);

/**
 * @notice Returns base currency unit
 */

function BASE_CURRENCY_UNIT()
    external
    view
    returns (uint256);

}
