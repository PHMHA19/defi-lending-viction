
export const poolDataProviderAbi = [
  {
    type: "function",

    name: "getReserveData",

    stateMutability: "view",

    inputs: [
      {
        name: "asset",
        type: "address",
      },
    ],

    outputs: [
      {
        type: "uint256",
      },
      {
        type: "uint256",
      },
      {
        type: "uint256",
      },
      {
        type: "uint256",
      },
      {
        type: "uint256",
      },
      {
        type: "uint256",
      },
      {
        type: "uint256",
      },
      {
        type: "uint40",
      },
    ],
  },

  {
    type: "function",

    name:
      "getReserveConfigurationData",

    stateMutability: "view",

    inputs: [
      {
        name: "asset",
        type: "address",
      },
    ],

    outputs: [
      {
        name: "decimals",
        type: "uint256",
      },

      {
        name: "ltv",
        type: "uint256",
      },

      {
        name:
          "liquidationThreshold",
        type: "uint256",
      },

      {
        name:
          "liquidationBonus",
        type: "uint256",
      },

      {
        name:
          "reserveFactor",
        type: "uint256",
      },

      {
        name:
          "usageAsCollateralEnabled",
        type: "bool",
      },

      {
        name:
          "borrowingEnabled",
        type: "bool",
      },

      {
        name:
          "stableBorrowRateEnabled",
        type: "bool",
      },

      {
        name:
          "isActive",
        type: "bool",
      },

      {
        name:
          "isFrozen",
        type: "bool",
      },
    ],
  },
] as const;

