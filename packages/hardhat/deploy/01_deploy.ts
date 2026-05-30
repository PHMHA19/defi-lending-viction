import hre from "hardhat";

async function main() {

const { ethers } =
await hre.network.connect();

console.log("=================================");
console.log("DEPLOY MINI AAVE");
console.log("=================================");

// =====================================================
// MOCK TOKENS
// =====================================================

const MockUSDC =
await ethers.getContractFactory(
"MockUSDC"
);

const usdc =
await MockUSDC.deploy();

await usdc.waitForDeployment();

console.log(
"USDC:",
await usdc.getAddress()
);

// -----------------------------

const MockWETH =
await ethers.getContractFactory(
"MockWETH"
);

const weth =
await MockWETH.deploy();

await weth.waitForDeployment();

console.log(
"WETH:",
await weth.getAddress()
);

// =====================================================
// PROVIDER
// =====================================================

const Provider =
await ethers.getContractFactory(
"PoolAddressesProvider"
);

const provider =
await Provider.deploy(
"MiniAaveMarket"
);

await provider.waitForDeployment();

console.log(
"Provider:",
await provider.getAddress()
);

// =====================================================
// ACL
// =====================================================

const ACL =
await ethers.getContractFactory(
"ACLManager"
);

const acl =
await ACL.deploy(
await provider.getAddress()
);

await acl.waitForDeployment();

console.log(
"ACL:",
await acl.getAddress()
);

// =====================================================
// ORACLE
// =====================================================

const Oracle =
await ethers.getContractFactory(
"AaveOracle"
);

const oracle =
await Oracle.deploy();

await oracle.waitForDeployment();

console.log(
"Oracle:",
await oracle.getAddress()
);

// =====================================================
// POOL
// =====================================================

const Pool =
await ethers.getContractFactory(
"Pool"
);

const pool =
await Pool.deploy(
await provider.getAddress()
);

await pool.waitForDeployment();

console.log(
"Pool:",
await pool.getAddress()
);

// =====================================================
// CONFIGURATOR
// =====================================================

const PoolConfigurator =
await ethers.getContractFactory(
"PoolConfigurator"
);

const configurator =
await PoolConfigurator.deploy();

await configurator.waitForDeployment();

console.log(
"Configurator:",
await configurator.getAddress()
);

// =====================================================
// REGISTER
// =====================================================

console.log("Registering...");

await provider.setPool(
await pool.getAddress()
);

await provider.setPoolConfigurator(
await configurator.getAddress()
);

console.log("=================================");
console.log("DEPLOY SUCCESS");
console.log("=================================");
}
main().catch((error) => {
console.error(error);
process.exitCode = 1;
});
