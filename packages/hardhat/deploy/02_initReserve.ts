import hre from "hardhat";

async function main() {

const { ethers } =
await hre.network.connect();

console.log("=================================");
console.log("INIT RESERVE");
console.log("=================================");

// =====================================================
// ADDRESSES
// =====================================================

const poolConfiguratorAddress =
"0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575";

const usdcAddress =
"0x95401dc811bb5740090279Ba06cfA8fcF6113778";

const providerAddress =
"0x70e0bA845a1A0F2DA3359C97E0285013525FFC49";

// =====================================================
// CONTRACTS
// =====================================================

const configurator =
await ethers.getContractAt(
"PoolConfigurator",
poolConfiguratorAddress
);

const provider =
await ethers.getContractAt(
"PoolAddressesProvider",
providerAddress
);

const poolAddress =
await provider.getPool();

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

await configurator.initReserves([
{
aTokenImpl:
aToken.target as string,


  stableDebtTokenImpl:
    stableDebt.target as string,

  variableDebtTokenImpl:
    variableDebt.target as string,

  underlyingAssetDecimals:
    6,

  interestRateStrategyAddress:
    strategy.target as string,

  underlyingAsset:
    usdcAddress,

  treasury:
    ethers.ZeroAddress,

  incentivesController:
    ethers.ZeroAddress,

  aTokenName:
    "Mini Aave USDC",

  aTokenSymbol:
    "maUSDC",

  variableDebtTokenName:
    "Variable Debt USDC",

  variableDebtTokenSymbol:
    "vdUSDC",

  stableDebtTokenName:
    "Stable Debt USDC",

  stableDebtTokenSymbol:
    "sdUSDC",

  params:
    "0x"
}


]);

console.log("=================================");
console.log("RESERVE INITIALIZED");
console.log("=================================");
}

main().catch((error) => {
console.error(error);
process.exitCode = 1;
});
