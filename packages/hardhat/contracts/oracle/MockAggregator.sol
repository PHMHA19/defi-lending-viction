// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockAggregator {

int256 private _answer;

uint8 public immutable decimals;

uint80 private _roundId;

uint256 private _updatedAt;

constructor(
    int256 initialAnswer,
    uint8 decimals_
) {
    _answer = initialAnswer;

    decimals = decimals_;

    _roundId = 1;

    _updatedAt =
        block.timestamp;
}

function setAnswer(
    int256 newAnswer
) external {

    _answer = newAnswer;

    _roundId++;

    _updatedAt =
        block.timestamp;
}

function latestRoundData()
    external
    view
    returns (
        uint80,
        int256,
        uint256,
        uint256,
        uint80
    )
{
    return (
        _roundId,
        _answer,
        _updatedAt,
        _updatedAt,
        _roundId
    );
}

}
