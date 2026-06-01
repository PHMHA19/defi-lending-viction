import { writeContract, readContract } from "@wagmi/core";
import { wagmiConfig } from "~~/services/web3/wagmiConfig";

import { poolAbi } from "./poolAbi";
import { TOKENS, getPoolAddress } from "./addresses";

export async function supplyUSDC(
  amount: bigint,
  userAddress: `0x${string}`,
) {
  const poolAddress = await getPoolAddress();

  return writeContract(wagmiConfig, {
    address: poolAddress,
    abi: poolAbi,
    functionName: "supply",
    args: [
      TOKENS.USDC,
      amount,
      userAddress,
      0,
    ],
  });
}

export async function getUserAccountData(
  userAddress: `0x${string}`,
) {
  const poolAddress = await getPoolAddress();

  return readContract(wagmiConfig, {
    address: poolAddress,
    abi: poolAbi,
    functionName: "getUserAccountData",
    args: [userAddress],
  });
}