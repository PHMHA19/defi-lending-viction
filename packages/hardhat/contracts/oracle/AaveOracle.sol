// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IPriceOracleGetter.sol";
import "../interfaces/IAggregatorV3.sol";

contract AaveOracle is
IPriceOracleGetter
{
address public owner;

address public immutable
    override BASE_CURRENCY;

uint256 public immutable
    override BASE_CURRENCY_UNIT;

mapping(address => address)
    public assetsSources;

modifier onlyOwner() {

    require(
        msg.sender == owner,
        "ONLY_OWNER"
    );

    _;
}

constructor(
    address baseCurrency,
    uint256 baseCurrencyUnit
) {

    owner = msg.sender;

    BASE_CURRENCY =
        baseCurrency;

    BASE_CURRENCY_UNIT =
        baseCurrencyUnit;
}

/**
 * ---------------------------------------------------
 * SET SOURCE
 * ---------------------------------------------------
 */

function setAssetSources(
    address[] calldata assets,
    address[] calldata sources
) external onlyOwner {

    require(
        assets.length ==
            sources.length,
        "INVALID_LENGTH"
    );

    for (
        uint256 i = 0;
        i < assets.length;
        i++
    ) {

        assetsSources[
            assets[i]
        ] = sources[i];
    }
}

/**
 * ---------------------------------------------------
 * GET PRICE
 * ---------------------------------------------------
 */

function getAssetPrice(
    address asset
)
    public
    view
    override
    returns (uint256)
{
    address source =
        assetsSources[asset];

    require(
        source != address(0),
        "NO_SOURCE"
    );

    (
        ,
        int256 answer,
        ,
        uint256 updatedAt,

    ) =
        IAggregatorV3(source)
            .latestRoundData();

    require(
        answer > 0,
        "INVALID_PRICE"
    );

    require(
        updatedAt > 0,
        "STALE_PRICE"
    );

    return uint256(answer);
}
}
