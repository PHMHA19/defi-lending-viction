import { deployScript } from "../rocketh/deploy.js";
import * as artifacts from "../generated/artifacts/index.js";

export default deployScript(
  async env => {
    const { deployer } = env.namedAccounts;

    console.log("🚀 Deploying contracts with:", deployer);

    /**
     * ---------------------------------------------------
     * Deploy MockETH
     * ---------------------------------------------------
     */
    const mockETH = await env.deploy("MockETH", {
      account: deployer,
      artifact: artifacts.MockETH,
      args: [
        "Mock Ethereum",
        "mETH",
        BigInt(1000000) * BigInt(10 ** 18),
      ],
    });

    console.log("✅ MockETH deployed:", mockETH.address);

    /**
     * ---------------------------------------------------
     * Deploy MockUSDC
     * ---------------------------------------------------
     */
    const mockUSDC = await env.deploy("MockUSDC", {
      account: deployer,
      artifact: artifacts.MockUSDC,
      args: [
        "Mock USD Coin",
        "mUSDC",
        BigInt(1000000) * BigInt(10 ** 18),
      ],
    });

    console.log("✅ MockUSDC deployed:", mockUSDC.address);

    /**
     * ---------------------------------------------------
     * Deploy LendingPool
     * ---------------------------------------------------
     */
    const lendingPool = await env.deploy("LendingPool", {
      account: deployer,
      artifact: artifacts.LendingPool,
      args: [
        mockETH.address,
        mockUSDC.address,
      ],
    });

    console.log("✅ LendingPool deployed:", lendingPool.address);
  },
  {
    tags: ["LendingPool"],
  },
);