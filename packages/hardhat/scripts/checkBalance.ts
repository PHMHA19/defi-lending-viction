
import { ethers } from "ethers";

async function main() {
  const provider =
    new ethers.JsonRpcProvider(
      "http://127.0.0.1:8545",
    );

  const usdc =
    "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";

  const wallet =
    "0xE55d6FbFD2DA1562187BBc5B874a070a490F410B";

  const contract =
    new ethers.Contract(
      usdc,
      [
        "function balanceOf(address) view returns (uint256)",
      ],
      provider,
    );

  const balance =
    await contract.balanceOf(
      wallet,
    );

  console.log(
      balance.toString(),
  );
}

main();
