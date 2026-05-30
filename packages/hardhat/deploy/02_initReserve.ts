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
"PASTE_CONFIGURATOR_ADDRESS";

const usdcAddress =
"PASTE_USDC_ADDRESS";

// =====================================================
// CONTRACTS
// =====================================================

const configurator =
await ethers.getContractAt(
"PoolConfigurator",
poolConfiguratorAddress
);

// =====================================================
// TOKENIZATION
// =====================================================

const AToken =
await ethers.getContractFactory(
"AToken"
);

const aToken =
await AToken.deploy();

await aToken.waitForDeployment();

console.log(
"AToken:",
await aToken.getAddress()
);

// -----------------------------

const StableDebt =
await ethers.getContractFactory(
"StableDebtToken"
);

const stableDebt =
await StableDebt.deploy();

await stableDebt.waitForDeployment();

console.log(
"StableDebt:",
await stableDebt.getAddress()
);

// -----------------------------

const VariableDebt =
await ethers.getContractFactory(
"VariableDebtToken"
);

const variableDebt =
await VariableDebt.deploy();

await variableDebt.waitForDeployment();

console.log(
"VariableDebt:",
await variableDebt.getAddress()
);

// =====================================================
// INTEREST STRATEGY
// =====================================================

const Strategy =
await ethers.getContractFactory(
"DefaultReserveInterestRateStrategy"
);

const strategy =
await Strategy.deploy();

await strategy.waitForDeployment();

console.log(
"Strategy:",
await strategy.getAddress()
);

// =====================================================
// INIT RESERVE
// =====================================================

console.log("Initializing reserve...");

await configurator.initReserves([
{
aTokenImpl:
await aToken.getAddress(),

```
  stableDebtTokenImpl:
    await stableDebt.getAddress(),

  variableDebtTokenImpl:
    await variableDebt.getAddress(),

  underlyingAssetDecimals: 6,

  interestRateStrategyAddress:
    await strategy.getAddress(),

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

  params: "0x"
}
```

]);

console.log("=================================");
console.log("RESERVE INITIALIZED");
console.log("=================================");
}

main().catch((error) => {
console.error(error);
process.exitCode = 1;
});
