// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PoolConfigurator {

    address public owner;

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "ONLY_OWNER"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}