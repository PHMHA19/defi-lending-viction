import {
  readContract,
} from "@wagmi/core";

import {
  wagmiConfig,
} from "~~/services/web3/wagmiConfig";

import {
  erc20Abi,
} from "./erc20Abi";

export type TokenMetadata =
  {
    address: `0x${string}`;

    symbol: string;

    name: string;

    decimals: number;
  };

export async function getTokenMetadata(
  tokenAddress: `0x${string}`,
): Promise<TokenMetadata> {
  const [
    symbol,
    name,
    decimals,
  ] = await Promise.all([
    readContract(
      wagmiConfig,
      {
        address:
          tokenAddress,

        abi:
          erc20Abi,

        functionName:
          "symbol",
      },
    ),

    readContract(
      wagmiConfig,
      {
        address:
          tokenAddress,

        abi:
          erc20Abi,

        functionName:
          "name",
      },
    ),

    readContract(
      wagmiConfig,
      {
        address:
          tokenAddress,

        abi:
          erc20Abi,

        functionName:
          "decimals",
      },
    ),
  ]);

  return {
    address:
      tokenAddress,

    symbol,

    name,

    decimals:
      Number(decimals),
  };
}

