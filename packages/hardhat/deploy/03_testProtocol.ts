import hre from "hardhat";
import fs from "fs";

const addresses = JSON.parse(
  fs.readFileSync(
    "./deployments.json",
    "utf8"
  )
);

const poolAddress = addresses.pool;
const usdcAddress = addresses.usdc;

async function main() {

  const { ethers } =
    await hre.network.connect();

  const [user] =
    await ethers.getSigners();

  console.log("=================================");
  console.log("TEST MINI AAVE");
  console.log("=================================");

  // =====================================================
  // CONTRACTS
  // =====================================================

  const pool =
    await ethers.getContractAt(
      "Pool",
      poolAddress
    );

  const usdc =
    await ethers.getContractAt(
    "MockUSDC",
    usdcAddress
    ) as any;

  // =====================================================
  // MINT USDC
  // =====================================================

  const mintAmount =
    ethers.parseUnits("10000", 6);

  await usdc.mint(
    user.address,
    mintAmount
  );

  console.log(
    "USDC Minted"
  );

  // =====================================================
  // APPROVE
  // =====================================================

  await usdc.approve(
    poolAddress,
    mintAmount
  );

  console.log(
    "USDC Approved"
  );

  // =====================================================
  // SUPPLY
  // =====================================================

  const supplyAmount =
    ethers.parseUnits("1000", 6);

  await pool.supply(
    usdcAddress,
    supplyAmount,
    user.address,
    0
  );

  console.log(
    "USDC Supplied"
  );

//   // =====================================================
//   // USER DATA
//   // =====================================================

//   const userData =
//     await pool.getUserAccountData(
//       user.address
//     );

//   console.log(
//     "Collateral Base:",
//     userData.totalCollateralBase.toString()
//   );

//   console.log(
//     "Debt Base:",
//     userData.totalDebtBase.toString()
//   );

//   console.log(
//     "Available Borrows:",
//     userData.availableBorrowsBase.toString()
//   );

//   console.log(
//     "Health Factor:",
//     userData.healthFactor.toString()
//   );

  // =====================================================
  // BORROW
  // =====================================================

  const borrowAmount =
    ethers.parseUnits("100", 6);

//   await pool.borrow(
//     usdcAddress,
//     borrowAmount,
//     2,
//     0,
//     user.address
//   );

//   console.log(
//     "USDC Borrowed"
//   );

  // =====================================================
  // REPAY
  // =====================================================

//   await usdc.approve(
//     poolAddress,
//     borrowAmount
//   );

//   await pool.repay(
//     usdcAddress,
//     borrowAmount,
//     2,
//     user.address
//   );

//   console.log(
//     "USDC Repaid"
//   );

  // =====================================================
  // WITHDRAW
  // =====================================================

//   await pool.withdraw(
//     usdcAddress,
//     supplyAmount,
//     user.address
//   );

//   console.log(
//     "USDC Withdrawn"
//   );

  console.log("=================================");
  console.log("TEST SUCCESS");
  console.log("=================================");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}
);
