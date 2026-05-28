"use client";

import { useState } from "react";
import { formatUnits, parseUnits } from "viem";
import {
  useScaffoldReadContract,
  useScaffoldWriteContract,
} from "~~/hooks/scaffold-eth";

export default function Dashboard() {
  const [amount, setAmount] = useState("");

  const { writeContractAsync: mintUSDC } = useScaffoldWriteContract({
    contractName: "MockUSDC",
  });

  const { data: totalSupply } = useScaffoldReadContract({
    contractName: "MockUSDC",
    functionName: "totalSupply",
  });

  return (
    <div className="p-10">
      <h1 className="text-4xl font-bold mb-8">
        Dashboard DeFi Lending
      </h1>

      <div className="bg-base-200 p-6 rounded-2xl w-full max-w-xl">
        <p className="text-lg mb-2">
          Tổng cung:
        </p>

        <p className="text-2xl font-bold mb-6">
          {totalSupply
            ? Number(formatUnits(totalSupply, 6)).toLocaleString()
            : "0"} mUSDC
        </p>

        <input
          type="number"
          placeholder="Nhập số USDC"
          className="input input-bordered w-full mb-4"
          value={amount}
          onChange={e => setAmount(e.target.value)}
        />

        <button
          className="btn btn-primary"
          onClick={async () => {
            await mintUSDC({
              functionName: "mint",
              args: [
                "0xE55d6FbFD2DA1562187BBc5B874a070a490F410B",
                parseUnits(amount, 6),
              ],
            });
          }}
        >
          Mint USDC
        </button>
      </div>
    </div>
  );
}