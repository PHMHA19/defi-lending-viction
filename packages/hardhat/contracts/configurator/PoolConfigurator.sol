// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../MiniAave.sol";

import "../core/PoolAddressesProvider.sol";
import "../core/ACLManager.sol";

contract PoolConfigurator {

PoolAddressesProvider
    public addressesProvider;

constructor(
    address provider
) {

    addressesProvider =
        PoolAddressesProvider(
            provider
        );
}

/**
 * ---------------------------------------------------
 * INTERNAL ACL
 * ---------------------------------------------------
 */

function _getACLManager()
    internal
    view
    returns (ACLManager)
{
    return
        ACLManager(
            addressesProvider
                .getACLManager()
        );
}

/**
 * ---------------------------------------------------
 * ONLY ASSET LISTING ADMIN
 * ---------------------------------------------------
 */

modifier onlyAssetListingAdmin() {

    require(
        _getACLManager()
            .hasRole(
                keccak256(
                    "ASSET_LISTING_ADMIN"
                ),
                msg.sender
            ),
        "NOT_ASSET_LISTING_ADMIN"
    );

    _;
}

/**
 * ---------------------------------------------------
 * INTERNAL POOL
 * ---------------------------------------------------
 */

function _getPool()
    internal
    view
    returns (MiniAave)
{
    return
        MiniAave(
            addressesProvider
                .getPool()
        );
}

/**
 * ---------------------------------------------------
 * INIT RESERVE
 * ---------------------------------------------------
 */

function initReserve(
    address asset,
    uint256 liquidityRate,
    uint256 variableBorrowRate,
    uint256 ltv,
    uint256 liquidationThreshold,
    address interestRateStrategy
)
    external
    onlyAssetListingAdmin
{
    _getPool().addReserve(
        asset,

        liquidityRate,

        variableBorrowRate,

        ltv,

        liquidationThreshold,

        interestRateStrategy
    );
}

}
