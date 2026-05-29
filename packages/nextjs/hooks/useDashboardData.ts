"use client";

import { formatUnits, zeroAddress } from "viem";
import { useAccount } from "wagmi";

import { useScaffoldReadContract } from "~~/hooks/scaffold-eth";

type UserAccountData = readonly [
  bigint, // supplied
  bigint  // borrowed
];

export const useDashboardData = () => {
  const { address } = useAccount();

  const safeAddress = address || zeroAddress;

  const { data: accountData } = useScaffoldReadContract({
    contractName: "LendingPool",
    functionName: "getUserAccountData",
    args: [safeAddress],
  }) as {
    data: UserAccountData | undefined;
  };

  const { data: healthFactor } = useScaffoldReadContract({
    contractName: "LendingPool",
    functionName: "getHealthFactor",
    args: [safeAddress],
  }) as {
    data: bigint | undefined;
  };

  return {
    supplied: accountData
      ? Number(formatUnits(accountData[0], 6))
      : 0,

    borrowed: accountData
      ? Number(formatUnits(accountData[1], 6))
      : 0,

    healthFactor: healthFactor
      ? Number(formatUnits(healthFactor, 18))
      : 0,
  };
};
