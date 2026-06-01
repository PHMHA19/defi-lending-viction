
import {
  AaveV3Ethereum,
} from "@bgd-labs/aave-address-book";

import {
  getAddress,
} from "viem";

export const AAVE_POOL =
  getAddress(
    AaveV3Ethereum.POOL,
  );

export const AAVE_ORACLE =
  getAddress(
    AaveV3Ethereum.ORACLE,
  );

export const AAVE_POOL_DATA_PROVIDER =
  getAddress(
    AaveV3Ethereum.AAVE_PROTOCOL_DATA_PROVIDER,
  );

export const AAVE_UI_POOL_DATA_PROVIDER =
  getAddress(
    AaveV3Ethereum.UI_POOL_DATA_PROVIDER,
  );

export const AAVE_WETH_GATEWAY =
  getAddress(
    AaveV3Ethereum.WETH_GATEWAY,
  );

export const TOKENS = {
  USDC:
    getAddress(
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
    ),

  WETH:
    getAddress(
      "0xC02aaA39b223FE8D0A0E5C4F27eAD9083C756Cc2",
    ),

  DAI:
    getAddress(
      "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    ),

  USDT:
    getAddress(
      "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    ),
} as const;

