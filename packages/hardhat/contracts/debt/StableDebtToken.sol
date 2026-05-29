// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StableDebtToken is ERC20 {

/**
 * ---------------------------------------------------
 * PRECISION
 * ---------------------------------------------------
 */

uint256 internal constant
    PRECISION = 1e18;

/**
 * ---------------------------------------------------
 * POOL
 * ---------------------------------------------------
 */

address public immutable pool;

/**
 * ---------------------------------------------------
 * USER STABLE RATE
 * ---------------------------------------------------
 */

mapping(address => uint256)
    public userStableRate;

/**
 * ---------------------------------------------------
 * USER LAST UPDATE
 * ---------------------------------------------------
 */

mapping(address => uint40)
    public userLastUpdateTimestamp;

/**
 * ---------------------------------------------------
 * AVERAGE STABLE RATE
 * ---------------------------------------------------
 */

uint256 public averageStableRate;

/**
 * ---------------------------------------------------
 * TOTAL STABLE DEBT
 * ---------------------------------------------------
 */

uint256 public totalStableDebt;

/**
 * ---------------------------------------------------
 * TOTAL SUPPLY TIMESTAMP
 * ---------------------------------------------------
 */

uint40 public totalSupplyTimestamp;

/**
 * ---------------------------------------------------
 * EVENTS
 * ---------------------------------------------------
 */

event Mint(
    address indexed user,
    uint256 amount,
    uint256 rate
);

event Burn(
    address indexed user,
    uint256 amount
);

/**
 * ---------------------------------------------------
 * ONLY POOL
 * ---------------------------------------------------
 */

modifier onlyPool() {

    require(
        msg.sender == pool,
        "ONLY_POOL"
    );

    _;
}

/**
 * ---------------------------------------------------
 * CONSTRUCTOR
 * ---------------------------------------------------
 */

constructor(
    string memory name_,
    string memory symbol_,
    address pool_
)
    ERC20(name_, symbol_)
{
    pool = pool_;

    totalSupplyTimestamp =
        uint40(
            block.timestamp
        );
}

/**
 * ---------------------------------------------------
 * MINT
 * ---------------------------------------------------
 */

function mint(
    address user,
    uint256 amount,
    uint256 stableRate
)
    external
    onlyPool
    returns (bool)
{
    require(
        amount > 0,
        "INVALID_AMOUNT"
    );

    uint256 previousBalance =
        balanceOf(user);

    /**
     * ---------------------------------------------------
     * UPDATE TOTAL STABLE DEBT
     * ---------------------------------------------------
     */

    totalStableDebt += amount;

    /**
     * ---------------------------------------------------
     * UPDATE USER RATE
     * ---------------------------------------------------
     */

    if (previousBalance == 0) {

        userStableRate[user] =
            stableRate;

    } else {

        uint256 weightedRate =
            (
                (
                    previousBalance *
                    userStableRate[user]
                ) +
                (
                    amount *
                    stableRate
                )
            ) /
            (
                previousBalance +
                amount
            );

        userStableRate[user] =
            weightedRate;
    }

    /**
     * ---------------------------------------------------
     * UPDATE AVERAGE STABLE RATE
     * ---------------------------------------------------
     */

    if (totalStableDebt == 0) {

        averageStableRate =
            stableRate;

    } else {

        averageStableRate =
            (
                (
                    averageStableRate *
                    (
                        totalStableDebt -
                        amount
                    )
                ) +
                (
                    stableRate *
                    amount
                )
            ) /
            totalStableDebt;
    }

    /**
     * ---------------------------------------------------
     * TIMESTAMPS
     * ---------------------------------------------------
     */

    userLastUpdateTimestamp[user] =
        uint40(
            block.timestamp
        );

    totalSupplyTimestamp =
        uint40(
            block.timestamp
        );

    /**
     * ---------------------------------------------------
     * MINT TOKENS
     * ---------------------------------------------------
     */

    _mint(user, amount);

    emit Mint(
        user,
        amount,
        stableRate
    );

    return previousBalance == 0;
}

/**
 * ---------------------------------------------------
 * BURN
 * ---------------------------------------------------
 */

function burn(
    address user,
    uint256 amount
) external onlyPool {

    require(
        amount > 0,
        "INVALID_AMOUNT"
    );

    require(
        balanceOf(user) >= amount,
        "INSUFFICIENT_BALANCE"
    );

    /**
     * ---------------------------------------------------
     * UPDATE TOTAL DEBT
     * ---------------------------------------------------
     */

    totalStableDebt -= amount;

    /**
     * ---------------------------------------------------
     * BURN TOKENS
     * ---------------------------------------------------
     */

    _burn(user, amount);

    /**
     * ---------------------------------------------------
     * RESET RATE IF EMPTY
     * ---------------------------------------------------
     */

    if (
        balanceOf(user) == 0
    ) {

        userStableRate[user] =
            0;
    }

    /**
     * ---------------------------------------------------
     * TIMESTAMPS
     * ---------------------------------------------------
     */

    userLastUpdateTimestamp[user] =
        uint40(
            block.timestamp
        );

    totalSupplyTimestamp =
        uint40(
            block.timestamp
        );

    emit Burn(
        user,
        amount
    );
}

/**
 * ---------------------------------------------------
 * GET USER STABLE RATE
 * ---------------------------------------------------
 */

function getUserStableRate(
    address user
)
    external
    view
    returns (uint256)
{
    return
        userStableRate[user];
}

/**
 * ---------------------------------------------------
 * GET AVERAGE STABLE RATE
 * ---------------------------------------------------
 */

function getAverageStableRate()
    external
    view
    returns (uint256)
{
    return
        averageStableRate;
}

/**
 * ---------------------------------------------------
 * GET TOTAL STABLE DEBT
 * ---------------------------------------------------
 */

function getTotalStableDebt()
    external
    view
    returns (uint256)
{
    return
        totalStableDebt;
}

/**
 * ---------------------------------------------------
 * GET TOTAL SUPPLY TIMESTAMP
 * ---------------------------------------------------
 */

function getTotalSupplyTimestamp()
    external
    view
    returns (uint40)
{
    return
        totalSupplyTimestamp;
}

}
