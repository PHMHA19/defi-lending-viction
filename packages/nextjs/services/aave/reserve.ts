
import {
  readContract,
} from "@wagmi/core";

import {
  wagmiConfig,
} from "~~/services/web3/wagmiConfig";

import {
  AAVE_POOL_DATA_PROVIDER,
} from "./addresses";

import {
  poolDataProviderAbi,
} from "./poolDataProviderAbi";



import type {
  ReserveData,
  RawReserveData,
  ReserveConfigurationData,
} from "~~/types/aave";




import {
  getReservesList,
} from "./pool";

import {
  getTokenMetadata,
} from "./token";




export async function getReserveData(
  asset: `0x${string}`,
) {
  return await readContract(
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





export async function getReserveConfigurationData(
  asset: `0x${string}`,
) {
  return await readContract(
    wagmiConfig,
    {
      address:
        AAVE_POOL_DATA_PROVIDER,

      abi:
        poolDataProviderAbi,

      functionName:
        "getReserveConfigurationData",

      args: [asset],
    },
  );
}






function mapReserveData(
  reserve: {
    symbol: string;

    address: `0x${string}`;

    decimals: number;
  },

  reserveData: any,

  configData: any,
): ReserveData {

return {
  symbol:
    reserve.symbol,

  asset:
    reserve.address,

  decimals:
    reserve.decimals,

  liquidityRate:
    reserveData.liquidityRate,

  variableBorrowRate:
    reserveData.variableBorrowRate,

  liquidity:
    reserveData.totalAToken,

  ltv:
    configData.ltv,

  liquidationThreshold:
    configData.liquidationThreshold,

  reserveFactor:
    configData.reserveFactor,

  usageAsCollateralEnabled:
    configData.usageAsCollateralEnabled,

  borrowingEnabled:
    configData.borrowingEnabled,

  isActive:
    configData.isActive,

  isFrozen:
    configData.isFrozen,
};
}




export async function getAllReserveData() {
  /**
   * Load all reserve addresses
   * directly from Aave Pool
   */
  const reserveAddresses =
    await getReservesList();

  /**
   * Limit reserves for localhost performance
   */
  const limitedReserves =
    reserveAddresses.slice(
      0,
      8,
    );
  


  return Promise.all(
    limitedReserves.map(
      async asset => {
        /**
         * Load token metadata
         */
        const metadata =
          await getTokenMetadata(
            asset,
          );

        /**
         * Load reserve data
         */
        const data =
          await getReserveData(
            asset,
          );
        
        const configData =
          await getReserveConfigurationData(
            asset,
          );


        
      return mapReserveData(
        {
          symbol:
            metadata.symbol,

          address:
            asset,

          decimals:
            metadata.decimals,
        },

        data,

        configData,
      );

      },
    ),
  );
}





