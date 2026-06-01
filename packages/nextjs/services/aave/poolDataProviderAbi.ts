
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
] as const;

