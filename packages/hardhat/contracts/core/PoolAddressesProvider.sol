// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ACLManager.sol";

contract PoolAddressesProvider {

/**
 * ---------------------------------------------------
 * OWNER
 * ---------------------------------------------------
 */

address public owner;

/**
 * ---------------------------------------------------
 * CORE ADDRESSES
 * ---------------------------------------------------
 */

address private pool;

address private poolConfigurator;

address private priceOracle;

address private aclManager;

/**
 * ---------------------------------------------------
 * OWNER MODIFIER
 * ---------------------------------------------------
 */

modifier onlyOwner() {

    require(
        msg.sender == owner,
        "ONLY_OWNER"
    );

    _;
}

/**
 * ---------------------------------------------------
 * CONSTRUCTOR
 * ---------------------------------------------------
 */

constructor() {

    owner = msg.sender;
}

/**
 * ---------------------------------------------------
 * INTERNAL ACL GETTER
 * ---------------------------------------------------
 */

function _getACLManager()
    internal
    view
    returns (ACLManager)
{
    return
        ACLManager(
            aclManager
        );
}

/**
 * ---------------------------------------------------
 * POOL ADMIN MODIFIER
 * ---------------------------------------------------
 */

modifier onlyPoolAdmin() {

    require(
        _getACLManager()
            .hasRole(
                keccak256(
                    "POOL_ADMIN"
                ),
                msg.sender
            ),
        "NOT_POOL_ADMIN"
    );

    _;
}

/**
 * ---------------------------------------------------
 * SET ACL MANAGER
 * ---------------------------------------------------
 */

function setACLManager(
    address newAcl
) external onlyOwner {

    aclManager = newAcl;
}

/**
 * ---------------------------------------------------
 * SET POOL
 * ---------------------------------------------------
 */

function setPoolImpl(
    address newPool
) external onlyPoolAdmin {

    pool = newPool;
}

/**
 * ---------------------------------------------------
 * SET CONFIGURATOR
 * ---------------------------------------------------
 */

function setPoolConfiguratorImpl(
    address newConfigurator
) external onlyPoolAdmin {

    poolConfigurator =
        newConfigurator;
}

/**
 * ---------------------------------------------------
 * SET ORACLE
 * ---------------------------------------------------
 */

function setPriceOracle(
    address newOracle
) external onlyPoolAdmin {

    priceOracle =
        newOracle;
}

/**
 * ---------------------------------------------------
 * GET POOL
 * ---------------------------------------------------
 */

function getPool()
    external
    view
    returns (address)
{
    return pool;
}

/**
 * ---------------------------------------------------
 * GET CONFIGURATOR
 * ---------------------------------------------------
 */

function getPoolConfigurator()
    external
    view
    returns (address)
{
    return poolConfigurator;
}

/**
 * ---------------------------------------------------
 * GET ORACLE
 * ---------------------------------------------------
 */

function getPriceOracle()
    external
    view
    returns (address)
{
    return priceOracle;
}

/**
 * ---------------------------------------------------
 * GET ACL MANAGER
 * ---------------------------------------------------
 */

function getACLManager()
    external
    view
    returns (address)
{
    return aclManager;
}

}
