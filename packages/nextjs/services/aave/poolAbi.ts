export const poolAbi = [
  {
    type: "function",
    name: "supply",
    stateMutability: "nonpayable",
    inputs: [
      {
        name: "asset",
        type: "address",
      },
      {
        name: "amount",
        type: "uint256",
      },
      {
        name: "onBehalfOf",
        type: "address",
      },
      {
        name: "referralCode",
        type: "uint16",
      },
    ],
    outputs: [],
  },
  {
    type: "function",
    name: "getUserAccountData",
    stateMutability: "view",
    inputs: [
      {
        name: "user",
        type: "address",
      },
    ],
    outputs: [
      {
        name: "totalCollateralBase",
        type: "uint256",
      },
      {
        name: "totalDebtBase",
        type: "uint256",
      },
      {
        name: "availableBorrowsBase",
        type: "uint256",
      },
      {
        name: "currentLiquidationThreshold",
        type: "uint256",
      },
      {
        name: "ltv",
        type: "uint256",
      },
      {
        name: "healthFactor",
        type: "uint256",
      },
    ],
  },
  

  {
    type: "function",
    name: "getReservesList",
    stateMutability: "view",
    inputs: [],
    outputs: [
      {
        type: "address[]",
      },
    ],
  }
] as const;