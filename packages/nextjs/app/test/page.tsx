
"use client";

import { useState }
from "react";

import {
  useAccount,
} from "wagmi";

import {
  TOKENS,
} from "~~/services/aave/addresses";

import {
  approveAsset,
  supplyAsset,
  getUserAccountData,
} from "~~/services/aave/pool";

export default function TestPage() {
  const {
    address,
  } = useAccount();

  const [loading, setLoading] =
    useState(false);

  async function handleSupply() {
    if (!address) {
      return;
    }

    const userAddress =
      address as `0x${string}`;

    try {
      setLoading(true);

      /**
       * 100 USDC
       */
      const amount =
        100n * 10n ** 6n;

      /**
       * Approve
       */
      await approveAsset(
        TOKENS.USDC,
        amount,
      );

      console.log(
        "Approve success",
      );

      /**
       * Supply
       */
      await supplyAsset(
        TOKENS.USDC,
        amount,
        userAddress,
      );

      console.log(
        "Supply success",
      );

      /**
       * Read account data
       */
      const data =
        await getUserAccountData(
          userAddress,
        );

      console.log(
        "ACCOUNT DATA:",
        data,
      );
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="p-10">
      <h1 className="text-3xl mb-6">
        Aave Supply Test
      </h1>

      <button
        className="btn btn-primary"
        onClick={handleSupply}
        disabled={
          !address || loading
        }
      >
        {loading
          ? "Loading..."
          : "Supply 100 USDC"}
      </button>
    </div>
  );
}

