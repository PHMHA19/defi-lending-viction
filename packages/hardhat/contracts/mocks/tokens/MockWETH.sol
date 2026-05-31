// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../dependencies/openzeppelin/contracts/ERC20.sol";

contract MockWETH is ERC20 {

constructor()
    ERC20(
        "Mock Wrapped Ether",
        "WETH"
    )
{
    _mint(
        msg.sender,
        1_000_000 ether
    );
}

function mint(
    address to,
    uint256 amount
) external {
    _mint(to, amount);
}
}
