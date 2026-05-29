// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ValidationLogic {

    function validateAmount(
        uint256 amount
    ) internal pure {

        require(
            amount > 0,
            "INVALID_AMOUNT"
        );
    }

    function validateLiquidity(
        uint256 available,
        uint256 amount
    ) internal pure {

        require(
            available >= amount,
            "INSUFFICIENT_LIQUIDITY"
        );
    }

    function validateCollateral(
        uint256 borrowPower,
        uint256 debt,
        uint256 amount
    ) internal pure {

        require(
            debt + amount
                <= borrowPower,
            "INSUFFICIENT_COLLATERAL"
        );
    }
}