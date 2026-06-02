
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

  const normalizedReserveData:
    RawReserveData = {
    unbacked:
      reserveData[0],

    accruedToTreasuryScaled:
      reserveData[1],

    totalAToken:
      reserveData[2],

    totalStableDebt:
      reserveData[3],

    totalVariableDebt:
      reserveData[4],

    liquidityRate:
      reserveData[5],

    variableBorrowRate:
      reserveData[6],

    stableBorrowRate:
      reserveData[7],

    averageStableBorrowRate:
      reserveData[8],

    liquidityIndex:
      reserveData[9],

    variableBorrowIndex:
      reserveData[10],

    lastUpdateTimestamp:
      reserveData[11],
  };

  const normalizedConfigData:
    ReserveConfigurationData = {
    decimals:
      configData[0],

    ltv:
      configData[1],

    liquidationThreshold:
      configData[2],

    liquidationBonus:
      configData[3],

    reserveFactor:
      configData[4],

    usageAsCollateralEnabled:
      configData[5],

    borrowingEnabled:
      configData[6],

    stableBorrowRateEnabled:
      configData[7],

    isActive:
      configData[8],

    isFrozen:
      configData[9],
  };

  return {
    symbol:
      reserve.symbol,

    asset:
      reserve.address,

    decimals:
      reserve.decimals,

    liquidityRate:
      normalizedReserveData
        .liquidityRate,

    variableBorrowRate:
      normalizedReserveData
        .variableBorrowRate,

    liquidity:
      normalizedReserveData
        .totalAToken,

    ltv:
      normalizedConfigData
        .ltv,

    liquidationThreshold:
      normalizedConfigData
        .liquidationThreshold,

    reserveFactor:
      normalizedConfigData
        .reserveFactor,

    usageAsCollateralEnabled:
      normalizedConfigData
        .usageAsCollateralEnabled,

    borrowingEnabled:
      normalizedConfigData
        .borrowingEnabled,

    isActive:
      normalizedConfigData
        .isActive,

    isFrozen:
      normalizedConfigData
        .isFrozen,
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

