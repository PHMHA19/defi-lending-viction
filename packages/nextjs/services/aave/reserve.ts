
import {
  readContract,
} from "@wagmi/core";

import {
  wagmiConfig,
} from "~~/services/web3/wagmiConfig";

import {
  AAVE_POOL_DATA_PROVIDER,
  TOKENS,
} from "./addresses";

import {
  poolDataProviderAbi,
} from "./poolDataProviderAbi";

const RESERVES = [
  {
    symbol: "USDC",

    address:
      TOKENS.USDC as `0x${string}`,

    decimals: 6,
  },

  {
    symbol: "DAI",

    address:
      TOKENS.DAI as `0x${string}`,

    decimals: 18,
  },

  {
    symbol: "WETH",

    address:
      TOKENS.WETH as `0x${string}`,

    decimals: 18,
  },
] as const;

export async function getReserveData(
  asset: `0x${string}`,
) {
  return readContract(
    wagmiConfig,
    {
      address:
        AAVE_POOL_DATA_PROVIDER,

      abi:
        poolDataProviderAbi,

      functionName:
        "getReserveData",

      args: [asset],
    },
  );
}

export async function getAllReserveData() {
  return Promise.all(
    RESERVES.map(
      async reserve => {
        const data =
          await getReserveData(
            reserve.address,
          );

        return {
          symbol:
            reserve.symbol,

          asset:
            reserve.address,

          liquidityRate:
            Number(
              data[4],
            ) /
            1e25,

          variableBorrowRate:
            Number(
              data[5],
            ) /
            1e25,

          liquidity:
            Number(
              data[0],
            ) /
            10 **
              reserve.decimals,
        };
      },
    ),
  );
}

