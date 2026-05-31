import hre from "hardhat";
import fs from "fs";
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

const [deployer] =
  await ethers.getSigners();

const provider =
  await Provider.deploy(
    "MiniAaveMarket",
    deployer.address
  );
await provider.waitForDeployment();


await provider.setACLAdmin(
deployer.address
);

console.log(
"ACL Admin Set:",
deployer.address
);


console.log(
"Provider:",
provider.target as string
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
provider.target as string
);

await acl.waitForDeployment();

console.log(
"ACL:",
acl.target as string
);

// =====================================================
// ORACLE
// =====================================================

const Oracle =
await ethers.getContractFactory(
"AaveOracle"
);

const oracle =
await Oracle.deploy(
provider.target as string,
[],
[],
ethers.ZeroAddress,
ethers.ZeroAddress,
1
);

await oracle.waitForDeployment();

console.log(
"Oracle:",
oracle.target
);

// =====================================================
// LIBRARIES
// =====================================================

const BorrowLogicLib =
await ethers.getContractFactory(
"BorrowLogic"
);

const borrowLogic =
await BorrowLogicLib.deploy();

await borrowLogic.waitForDeployment();

// -----------------------------

const EModeLogicLib =
await ethers.getContractFactory(
"EModeLogic"
);

const eModeLogic =
await EModeLogicLib.deploy();

await eModeLogic.waitForDeployment();

// -----------------------------

const FlashLoanLogicLib =
await ethers.getContractFactory(
"FlashLoanLogic",
{
libraries: {
BorrowLogic:
borrowLogic.target as string,
}
}
);

const flashLoanLogic =
await FlashLoanLogicLib.deploy();

await flashLoanLogic.waitForDeployment();


// -----------------------------

const LiquidationLogicLib =
await ethers.getContractFactory(
"LiquidationLogic"
);

const liquidationLogic =
await LiquidationLogicLib.deploy();

await liquidationLogic.waitForDeployment();

// -----------------------------

const PoolLogicLib =
await ethers.getContractFactory(
"PoolLogic"
);

const poolLogic =
await PoolLogicLib.deploy();

await poolLogic.waitForDeployment();

// -----------------------------

const SupplyLogicLib =
await ethers.getContractFactory(
"SupplyLogic"
);

const supplyLogic =
await SupplyLogicLib.deploy();

await supplyLogic.waitForDeployment();

// =====================================================
// POOL
// =====================================================

const Pool =
await ethers.getContractFactory(
"Pool",
{
libraries: {
BorrowLogic:
borrowLogic.target as string,


    EModeLogic:
      eModeLogic.target as string,

    FlashLoanLogic:
      flashLoanLogic.target as string,

    LiquidationLogic:
      liquidationLogic.target as string,

    PoolLogic:
      poolLogic.target as string,

    SupplyLogic:
      supplyLogic.target as string,
  }
}


);


const pool =
await Pool.deploy(
provider.target as string
);

await pool.waitForDeployment();

console.log(
"Pool:",
pool.target as string
);

// =====================================================
// CONFIGURATOR
// =====================================================
const ConfiguratorLogicLib =
await ethers.getContractFactory(
"ConfiguratorLogic"
);

const configuratorLogic =
await ConfiguratorLogicLib.deploy();

await configuratorLogic.waitForDeployment();


const PoolConfigurator =
await ethers.getContractFactory(
"PoolConfigurator",
{
libraries: {
ConfiguratorLogic:
configuratorLogic.target as string,
}
}
);


const configurator =
await PoolConfigurator.deploy();

await configurator.waitForDeployment();

console.log(
"Configurator:",
configurator.target as string
);

// =====================================================
// REGISTER
// =====================================================

console.log("Registering...");

await provider.setPool(
pool.target as string
);

await provider.setPoolConfigurator(
configurator.target as string
);

console.log("=================================");
console.log("DEPLOY SUCCESS");
console.log("=================================");

const addresses = {
usdc: await usdc.getAddress(),
weth: await weth.getAddress(),
provider: await provider.target as string,
acl: await acl.getAddress(),
oracle: await oracle.getAddress(),
pool: await pool.getAddress(),
configurator: await configurator.getAddress()
};

fs.writeFileSync(
"./deployments.json",
JSON.stringify(addresses, null, 2)
);

console.log("Addresses saved!");

}

main().catch((error) => {
console.error(error);
process.exitCode = 1;
}
);

