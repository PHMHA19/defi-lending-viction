import hre from "hardhat";
import fs from "fs";

const addresses = JSON.parse(
fs.readFileSync(
"./deployments.json",
"utf8"
)
);

const poolAddress =
addresses.pool;

const providerAddress =
addresses.provider;

const usdcAddress =
addresses.usdc;

const poolConfiguratorAddress =
addresses.configurator;

async function main() {

const { ethers } =
await hre.network.connect();

console.log("=================================");
console.log("INIT RESERVE");
console.log("=================================");


// =====================================================
// CONTRACTS
// =====================================================

const pool =
await ethers.getContractAt(
"Pool",
poolAddress
);

console.log(
"Pool:",
poolAddress
);

// =====================================================
// TOKENIZATION
// =====================================================

const AToken =
await ethers.getContractFactory(
"MockAToken"
);

const aToken =
await AToken.deploy(
poolAddress
);

await aToken.waitForDeployment();

console.log(
"AToken:",
aToken.target
);

// -----------------------------

const StableDebt =
await ethers.getContractFactory(
"MockStableDebtToken"
);

const stableDebt =
await StableDebt.deploy(
poolAddress
);

await stableDebt.waitForDeployment();

console.log(
"StableDebt:",
stableDebt.target
);

// -----------------------------

const VariableDebt =
await ethers.getContractFactory(
"MockVariableDebtToken"
);

const variableDebt =
await VariableDebt.deploy(
poolAddress
);

await variableDebt.waitForDeployment();

console.log(
"VariableDebt:",
variableDebt.target
);

// =====================================================
// INTEREST STRATEGY
// =====================================================

const Strategy =
await ethers.getContractFactory(
"DefaultReserveInterestRateStrategy"
);

const RAY =
BigInt("1000000000000000000000000000");

const strategy =
await Strategy.deploy(
providerAddress,

  RAY * 80n / 100n, // optimalUsageRatio

  0n, // baseVariableBorrowRate

  RAY * 4n / 100n, // variableRateSlope1

  RAY * 75n / 100n, // variableRateSlope2

  RAY * 2n / 100n, // stableRateSlope1

  RAY * 75n / 100n, // stableRateSlope2

  0n, // baseStableRateOffset

  0n, // stableRateExcessOffset

  RAY * 20n / 100n // optimalStableToTotalDebtRatio
);


await strategy.waitForDeployment();

console.log(
"Strategy:",
strategy.target
);

// =====================================================
// INIT RESERVE
// =====================================================

console.log("Initializing reserve...");

await pool.manualInitReserve(
usdcAddress,
aToken.target as string,
stableDebt.target as string,
variableDebt.target as string,
strategy.target as string
);


console.log("=================================");
console.log("RESERVE INITIALIZED");
console.log("=================================");
}

main().catch((error) => {
console.error(error);
process.exitCode = 1;
});


