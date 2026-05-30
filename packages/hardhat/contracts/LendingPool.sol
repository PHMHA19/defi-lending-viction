// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LendingPool {

    using SafeERC20 for IERC20;

    struct ReserveData {
        uint256 totalDeposits;
        uint256 totalBorrows;
        bool isActive;
    }

    struct UserPosition {
        uint256 collateralAmount;
        uint256 borrowedAmount;
    }

    IERC20 public collateralToken;
    IERC20 public borrowToken;

    uint256 public constant LTV = 75;
    uint256 public constant LIQUIDATION_THRESHOLD = 80;

    ReserveData public reserve;

    mapping(address => UserPosition) public userPositions;

    event Supply(
        address indexed user,
        uint256 amount
    );

    event Withdraw(
        address indexed user,
        uint256 amount
    );

    event Borrow(
        address indexed user,
        uint256 amount
    );

    event Repay(
        address indexed user,
        uint256 amount
    );

    constructor(
        address _collateralToken,
        address _borrowToken
    ) {
        collateralToken = IERC20(_collateralToken);
        borrowToken = IERC20(_borrowToken);

        reserve.isActive = true;
    }

  
    function supply(uint256 amount) external {

        require(
            reserve.isActive,
            "POOL_INACTIVE"
        );

        require(
            amount > 0,
            "INVALID_AMOUNT"
        );

        require(
            collateralToken.balanceOf(msg.sender) >= amount,
            "INSUFFICIENT_TOKEN_BALANCE"
        );

        require(
            collateralToken.allowance(
                msg.sender,
                address(this)
            ) >= amount,
            "INSUFFICIENT_ALLOWANCE"
        );

        collateralToken.safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        userPositions[msg.sender].collateralAmount += amount;

        reserve.totalDeposits += amount;

        emit Supply(
            msg.sender,
            amount
        );
    }

   
    function withdraw(uint256 amount) external {

        UserPosition storage user =
            userPositions[msg.sender];

        require(
            amount > 0,
            "INVALID_AMOUNT"
        );

        require(
            user.collateralAmount >= amount,
            "INSUFFICIENT_COLLATERAL"
        );

        uint256 remainingCollateral =
            user.collateralAmount - amount;

        require(
            _isHealthy(
                remainingCollateral,
                user.borrowedAmount
            ),
            "HEALTH_FACTOR_TOO_LOW"
        );

        user.collateralAmount -= amount;

        reserve.totalDeposits -= amount;

        collateralToken.safeTransfer(
            msg.sender,
            amount
        );

        emit Withdraw(
            msg.sender,
            amount
        );
    }

  
    function borrow(uint256 amount) external {

        require(
            reserve.isActive,
            "POOL_INACTIVE"
        );

        require(
            amount > 0,
            "INVALID_AMOUNT"
        );

        UserPosition storage user =
            userPositions[msg.sender];

        require(
            user.collateralAmount > 0,
            "NO_COLLATERAL"
        );

        uint256 maxBorrow =
            (user.collateralAmount * LTV) / 100;

        require(
            user.borrowedAmount + amount <= maxBorrow,
            "INSUFFICIENT_COLLATERAL"
        );

        require(
            borrowToken.balanceOf(address(this)) >= amount,
            "INSUFFICIENT_POOL_LIQUIDITY"
        );

        user.borrowedAmount += amount;

        reserve.totalBorrows += amount;

        borrowToken.safeTransfer(
            msg.sender,
            amount
        );

        emit Borrow(
            msg.sender,
            amount
        );
    }

   
    function repay(uint256 amount) external {

        UserPosition storage user =
            userPositions[msg.sender];

        require(
            amount > 0,
            "INVALID_AMOUNT"
        );

        require(
            user.borrowedAmount >= amount,
            "INVALID_REPAY_AMOUNT"
        );

        require(
            borrowToken.balanceOf(msg.sender) >= amount,
            "INSUFFICIENT_TOKEN_BALANCE"
        );

        require(
            borrowToken.allowance(
                msg.sender,
                address(this)
            ) >= amount,
            "INSUFFICIENT_ALLOWANCE"
        );

        borrowToken.safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        user.borrowedAmount -= amount;

        reserve.totalBorrows -= amount;

        emit Repay(
            msg.sender,
            amount
        );
    }

 
    function getHealthFactor(
        address userAddress
    ) public view returns (uint256) {

        UserPosition memory user =
            userPositions[userAddress];

        if (user.borrowedAmount == 0) {
            return type(uint256).max;
        }

        return (
            user.collateralAmount *
            LIQUIDATION_THRESHOLD *
            1e18
        ) / (
            user.borrowedAmount * 100
        );
    }

 
    function isLiquidatable(
        address userAddress
    ) public view returns (bool) {

        return
            getHealthFactor(userAddress)
            < 1e18;
    }

 
    function _isHealthy(
        uint256 collateral,
        uint256 debt
    ) internal pure returns (bool) {

        if (debt == 0) {
            return true;
        }

        uint256 healthFactor =
            (
                collateral *
                LIQUIDATION_THRESHOLD *
                1e18
            ) / (
                debt * 100
            );

        return healthFactor >= 1e18;
    }

   
    function getUserAccountData(
        address userAddress
    )
        external
        view
        returns (
            uint256 collateral,
            uint256 debt,
            uint256 healthFactor
        )
    {
        UserPosition memory user =
            userPositions[userAddress];

        collateral =
            user.collateralAmount;

        debt =
            user.borrowedAmount;

        healthFactor =
            getHealthFactor(userAddress);
    }
}
*/