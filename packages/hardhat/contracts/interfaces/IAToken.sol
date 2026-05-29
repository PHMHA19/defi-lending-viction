// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAToken {

    function mint(
        address user,
        uint256 amount
    ) external;

    function burn(
        address user,
        uint256 amount
    ) external;
}