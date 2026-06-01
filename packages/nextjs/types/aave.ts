

export type ReserveData = {
  symbol: string;

  asset: `0x${string}`;

  decimals: number;

  liquidityRate: bigint;

  variableBorrowRate: bigint;

  liquidity: bigint;

  ltv: bigint;

  liquidationThreshold: bigint;

  reserveFactor: bigint;

  usageAsCollateralEnabled: boolean;

  borrowingEnabled: boolean;

  isActive: boolean;

  isFrozen: boolean;
};


export type UserAccountData = {
  totalCollateral: string;

  totalDebt: string;

  availableBorrows: string;

  ltv: string;

  healthFactor: string;
};

