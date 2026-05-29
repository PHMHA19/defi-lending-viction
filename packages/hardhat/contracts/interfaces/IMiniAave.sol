// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMiniAave {

    function supply(
        address asset,
        uint256 amount
    ) external;

    function withdraw(
        address asset,
        uint256 amount
    ) external;

    function borrow(
        address asset,
        uint256 amount
    ) external;

    function repay(
        address asset,
        uint256 amount
    ) external;
}