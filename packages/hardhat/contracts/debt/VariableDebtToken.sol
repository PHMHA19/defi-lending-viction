// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VariableDebtToken is ERC20 {

    address public immutable pool;

    modifier onlyPool() {
        require(
            msg.sender == pool,
            "ONLY_POOL"
        );
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address pool_
    )
        ERC20(name_, symbol_)
    {
        pool = pool_;
    }

    function mint(
        address user,
        uint256 amount
    ) external onlyPool {

        _mint(user, amount);
    }

    function burn(
        address user,
        uint256 amount
    ) external onlyPool {

        _burn(user, amount);
    }
}