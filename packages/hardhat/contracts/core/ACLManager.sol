// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ACLManager {

    bytes32 public constant
        POOL_ADMIN =
            keccak256(
                "POOL_ADMIN"
            );

    bytes32 public constant
        RISK_ADMIN =
            keccak256(
                "RISK_ADMIN"
            );

    bytes32 public constant
        EMERGENCY_ADMIN =
            keccak256(
                "EMERGENCY_ADMIN"
            );

    bytes32 public constant
        ASSET_LISTING_ADMIN =
            keccak256(
                "ASSET_LISTING_ADMIN"
            );

    mapping(
        bytes32 =>
            mapping(
                address =>
                    bool
            )
    )
        private roles;

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

    /**
     * ---------------------------------------------------
     * GRANT ROLE
     * ---------------------------------------------------
     */

    function grantRole(
        bytes32 role,
        address user
    ) external onlyOwner {

        roles[role][user] = true;
    }

    /**
     * ---------------------------------------------------
     * REVOKE ROLE
     * ---------------------------------------------------
     */

    function revokeRole(
        bytes32 role,
        address user
    ) external onlyOwner {

        roles[role][user] = false;
    }

    /**
     * ---------------------------------------------------
     * HAS ROLE
     * ---------------------------------------------------
     */

    function hasRole(
        bytes32 role,
        address user
    )
        external
        view
        returns (bool)
    {
        return roles[role][user];
    }
}