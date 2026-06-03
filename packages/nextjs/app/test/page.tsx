
"use client";

import {
  useEffect,
  useState,
} from "react";

import {
  useAccount,
} from "wagmi";


import {
  approveAsset,
  borrowAsset,
  repayAsset,
  withdrawAsset,
  getAssetAllowance,
  getUserAccountData,
  supplyAsset,
} from "~~/services/aave/pool";

import {
  getAllReserveData,
} from "~~/services/aave/reserve";

import type {
  ReserveData,
  UserAccountData,
} from "~~/types/aave";


import {
  getWalletBalances,
} from "~~/services/aave/token";

import type {
  WalletBalance,
} from "~~/types/aave";


import {
  formatAPY,
  formatHealthFactor,
  formatLTV,
  formatTokenAmount,
  formatUSD,
} from "~~/utils/aaveFormat";


import {
  getUserPositions,
} from "~~/services/aave/reserve";

import type {
  UserReserveData,
} from "~~/types/aave";


export default function TestPage() {
  const {
    address,
  } = useAccount();

  const [loading, setLoading] =
    useState(false);

  const [
    accountData,
    setAccountData,
  ] =
    useState<UserAccountData | null>(
      null,
    );

  const [
    reserves,
    setReserves,
  ] = useState<
    ReserveData[]
  >([]);

 
  const [
    userPositions,

    setUserPositions,
  ] = useState<
    UserReserveData[]
  >([]);


const [
  walletBalances,

  setWalletBalances,
] = useState<
  WalletBalance[]
>([]);


const [
  selectedAsset,

  setSelectedAsset,
] = useState<
  `0x${string}` |
  ""
>("");

const [
  supplyAmount,

  setSupplyAmount,
] = useState("");


const [
  borrowAmount,

  setBorrowAmount,
] = useState("");

const [
  borrowAssetAddress,

  setBorrowAssetAddress,
] = useState<
  `0x${string}` |
  ""
>("");


const [
  withdrawAmount,

  setWithdrawAmount,
] = useState("");

const [
  withdrawAssetAddress,

  setWithdrawAssetAddress,
] = useState<
  `0x${string}` |
  ""
>("");

const [
  repayAmount,

  setRepayAmount,
] = useState("");

const [
  repayAssetAddress,

  setRepayAssetAddress,
] = useState<
  `0x${string}` |
  ""
>("");



  useEffect(() => {
    loadReserves();
  }, []);

  async function loadReserves() {
    try {
      const data =
        await getAllReserveData();

      console.log(
        "RESERVES:",
        data,
      );

      setReserves(data);

      if (address) {
        const positions =
          await getUserPositions(
            address as `0x${string}`,
          );
        setUserPositions(
          positions,
        );
      
        const balances =
          await getWalletBalances(
            address as `0x${string}`,
          );

        setWalletBalances(
          balances,
        );
      }

    } catch (err) {
      console.error(err);
    }
  }

  async function loadAccountData() {
    if (!address) {
      return;
    }

    try {
      const data =
        await getUserAccountData(
          address as `0x${string}`,
        );

      console.log(
        "ACCOUNT DATA:",
        data,
      );

      const formattedData: UserAccountData =
        {
          totalCollateral:
            formatUSD(
              data[0],
            ),

          totalDebt:
            formatUSD(
              data[1],
            ),

          availableBorrows:
            formatUSD(
              data[2],
            ),

          ltv:
            formatLTV(
              data[4],
            ),

          healthFactor:
            formatHealthFactor(
              data[5],
            ),
        };

      setAccountData(
        formattedData,
      );
    } catch (err) {
      console.error(err);
    }
  }

  async function handleSupply() {
    if (!address) {
      return;
    }

    const userAddress =
      address as `0x${string}`;

    try {
      setLoading(true);

      /**
       * 100 USDC
       */
      
      if (
        !selectedAsset ||
        !supplyAmount
      ) {
        return;
      }

      const selectedBalance =
        walletBalances.find(
          balance =>
            balance.asset ===
            selectedAsset,
        );

      if (
        !selectedBalance
      ) {
        return;
      }

      const parsedAmount =
        Number(
          supplyAmount,
        );
      if ( Number.isNaN( parsedAmount, ) || parsedAmount <= 0 ) { alert( "Invalid amount", ); return; }
      
      
      const amount =
        BigInt(
          Math.floor(
            parsedAmount *
            10 **
              selectedBalance.decimals,
          ),
        );
      if ( amount > selectedBalance.balance ) { alert( "Insufficient balance", ); return; }
      
      const allowance = 
        await getAssetAllowance( 
          selectedAsset, 
          userAddress, 
        ); 
      if ( allowance < amount 
      ) {

      /**
       * Approve
       */
      await approveAsset(
        selectedAsset
,
        amount,
      );

      console.log(
        "Approve success",
      );}

      /**
       * Supply
       */
      await supplyAsset(
        selectedAsset,
        amount,
        userAddress,
      );

      console.log(
        "Supply success",
      );

      /**
       * Reload account data
       */
      await loadAccountData();

      await loadReserves();

    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }
  const handleBorrow =
    async () => {

    if (
      !borrowAssetAddress ||
      !borrowAmount ||
      !address
    ) {
      return;
    }

    const selectedReserve =
      reserves.find(
        reserve =>
          reserve.asset ===
          borrowAssetAddress,
      );

    if (
      !selectedReserve
    ) {
      return;
    }

    const parsedAmount =
      Number(
        borrowAmount,
      );

    if (
      Number.isNaN(
        parsedAmount,
      ) ||
      parsedAmount <= 0
    ) {
      alert(
        "Invalid borrow amount",
      );

      return;
    }

    const amount =
      BigInt(
        Math.floor(
          parsedAmount *
          10 **
            selectedReserve.decimals,
        ),
      );
    
    if (
      !accountData
    ) {
      return;
    }

    const availableBorrows =
      Number(
        accountData
          .availableBorrows,
      );

    if (
      parsedAmount >
      availableBorrows
    ) {
      alert(
        "Borrow amount exceeds limit",
      );

      return;
    }
   

    try {
      await borrowAsset(
        borrowAssetAddress,

        amount,

        address as `0x${string}`,
      );

      alert(
        "Borrow success",
      );

      await loadAccountData();

      await loadReserves();

    } catch (
      error
    ) {
      console.error(
        error,
      );

      alert(
        "Borrow failed",
      );
    }
  };


  const handleWithdraw =
    async () => {

    if (
      !withdrawAssetAddress ||
      !withdrawAmount ||
      !address
    ) {
      return;
    }

    const position =
      userPositions.find(
        position =>
          position.asset ===
          withdrawAssetAddress,
      );

    if (
      !position
    ) {
      return;
    }

    const parsedAmount =
      Number(
        withdrawAmount,
      );

    if (
      Number.isNaN(
        parsedAmount,
      ) ||
      parsedAmount <= 0
    ) {
      alert(
        "Invalid withdraw amount",
      );

      return;
    }

    const amount =
      BigInt(
        Math.floor(
          parsedAmount *
          10 **
            position.decimals,
        ),
      );

    if (
      amount >
      position.supplied
    ) {
      alert(
        "Withdraw amount exceeds supplied balance",
      );

      return;
    }

    try {
      await withdrawAsset(
        withdrawAssetAddress,

        amount,

        address as `0x${string}`,
      );

      alert(
        "Withdraw success",
      );

      await loadAccountData();

      await loadReserves();

    } catch (
      error
    ) {
      console.error(
        error,
      );

      alert(
        "Withdraw failed",
      );
    }
  };

  
  const handleRepay =
    async () => {

    if (
      !repayAssetAddress ||
      !repayAmount ||
      !address
    ) {
      return;
    }

    const position =
      userPositions.find(
        position =>
          position.asset ===
          repayAssetAddress,
      );

    if (
      !position
    ) {
      return;
    }

    const walletBalance =
      walletBalances.find(
        balance =>
          balance.asset ===
          repayAssetAddress,
      );

    if (
      !walletBalance
    ) {
      return;
    }

    const parsedAmount =
      Number(
        repayAmount,
      );

    if (
      Number.isNaN(
        parsedAmount,
      ) ||
      parsedAmount <= 0
    ) {
      alert(
        "Invalid repay amount",
      );

      return;
    }

    const amount =
      BigInt(
        Math.floor(
          parsedAmount *
          10 **
            position.decimals,
        ),
      );

    if (
      amount >
      position.variableDebt
    ) {
      alert(
        "Repay amount exceeds debt",
      );

      return;
    }

    if (
      amount >
      walletBalance.balance
    ) {
      alert(
        "Insufficient wallet balance",
      );

      return;
    }

    try {

      const allowance =
        await getAssetAllowance(
          repayAssetAddress,

          address as `0x${string}`,
        );

      if (
        allowance < amount
      ) {

        await approveAsset(
          repayAssetAddress,

          amount,
        );
      }

      await repayAsset(
        repayAssetAddress,

        amount,

        address as `0x${string}`,
      );

      alert(
        "Repay success",
      );

      await loadAccountData();

      await loadReserves();

    } catch (
      error
    ) {
      console.error(
        error,
      );

      alert(
        "Repay failed",
      );
    }
  };




  return (
    <div className="p-10 space-y-6">
      <h1 className="text-4xl font-bold">
        Aave Dashboard
      </h1>

      <div className="flex gap-4">
        <button
          className="btn btn-primary"
          onClick={
            handleSupply
          }
          disabled={
            !address ||
            loading
          }
        >
          {loading
            ? "Loading..."
            : "Supply"}
        </button>

        <button
          className="btn btn-secondary"
          onClick={
            loadAccountData
          }
        >
          Refresh Position
        </button>
      </div>

     
      <select
        className="select select-bordered"

        value={
          selectedAsset
        }

        onChange={e =>
          setSelectedAsset(
            e.target
              .value as `0x${string}`,
          )
        }
      >
        <option value="">
          Select Asset
        </option>

        {walletBalances.map(
          balance => (
            <option
              key={
                balance.asset
              }

              value={
                balance.asset
              }
            >
              {
                balance.symbol
              }
            </option>
          ),
        )}
      </select>

      <input
        type="text"

        placeholder="Amount"
        


        className="input input-bordered"

        value={
          supplyAmount
        }

        onChange={e =>
          setSupplyAmount(
            e.target.value,
          )
        }
      />
      <select
          className="select select-bordered"

          value={
            borrowAssetAddress
          }

          onChange={e =>
            setBorrowAssetAddress(
              e.target
                .value as `0x${string}`,
            )
          }
        >
          <option value="">
            Select Borrow Asset
          </option>

          {reserves.map(
            reserve => (
              <option
                key={
                  reserve.asset
                }

                value={
                  reserve.asset
                }
              >
                {
                  reserve.symbol
                }
              </option>
            ),
          )}
        </select>

        <input
          type="text"

          placeholder="Borrow Amount"

          className="input input-bordered"

          value={
            borrowAmount
          }

          onChange={e =>
            setBorrowAmount(
              e.target.value,
            )
          }
        />

        <button
          className="btn btn-accent"

          onClick={
            handleBorrow
          }

          disabled={!address}
        >
          Borrow
        </button>
        <select
          className="select select-bordered"

          value={
            withdrawAssetAddress
          }

          onChange={e =>
            setWithdrawAssetAddress(
              e.target
                .value as `0x${string}`,
            )
          }
        >
          <option value="">
            Select Withdraw Asset
          </option>

          {userPositions.map(
            position => (
              <option
                key={
                  position.asset
                }

                value={
                  position.asset
                }
              >
                {
                  position.symbol
                }
              </option>
            ),
          )}
        </select>

        <input
          type="text"

          placeholder="Withdraw Amount"

          className="input input-bordered"

          value={
            withdrawAmount
          }

          onChange={e =>
            setWithdrawAmount(
              e.target.value,
            )
          }
        />

        <button
          className="btn btn-warning"

          onClick={
            handleWithdraw
          }

          disabled={!address}
        >
          Withdraw
        </button>

      
        <select
          className="select select-bordered"

          value={
            repayAssetAddress
          }

          onChange={e =>
            setRepayAssetAddress(
              e.target
                .value as `0x${string}`,
            )
          }
        >
          <option value="">
            Select Repay Asset
          </option>

          {userPositions
            .filter(
              position =>
                position.variableDebt >
                0n,
            )
            .map(
              position => (
                <option
                  key={
                    position.asset
                  }

                  value={
                    position.asset
                  }
                >
                  {
                    position.symbol
                  }
                </option>
              ),
            )}
        </select>

        <input
          type="text"

          placeholder="Repay Amount"

          className="input input-bordered"

          value={
            repayAmount
          }

          onChange={e =>
            setRepayAmount(
              e.target.value,
            )
          }
        />

        <button
          className="btn btn-success"

          onClick={
            handleRepay
          }

          disabled={!address}
        >
          Repay
        </button>






      {accountData && (
        <div className="space-y-4 border p-6 rounded-xl">
          <div>
            <strong>
              Total Collateral:
            </strong>{" "}
            $
            {
              accountData.totalCollateral
            }
          </div>

          <div>
            <strong>
              Total Debt:
            </strong>{" "}
            $
            {
              accountData.totalDebt
            }
          </div>

          <div>
            <strong>
              Available Borrows:
            </strong>{" "}
            $
            {
              accountData.availableBorrows
            }
          </div>

          <div>
            <strong>
              LTV:
            </strong>{" "}
            {
              accountData.ltv
            }
            %
          </div>

          <div>
            <strong>
              Health Factor:
            </strong>{" "}
            {
              accountData.healthFactor
            }
          </div>
        </div>
      )}
    
      <div className="border p-6 rounded-xl">
        <h2 className="text-2xl font-bold mb-4">
          Wallet Balances
        </h2>

        <div className="space-y-4">

          {walletBalances.length === 0 ? (
            <div className="opacity-70">
              No wallet balances
            </div>
          ) : (
            walletBalances.map(
              balance => (
                <div
                  key={
                    balance.asset
                  }
                  className="border p-4 rounded-lg"
                >
                  <div>
                    <strong>
                      Asset:
                    </strong>{" "}
                    {
                      balance.symbol
                    }
                  </div>

                  <div>
                    <strong>
                      Balance:
                    </strong>{" "}
                    {formatTokenAmount(
                      balance.balance,
                      balance.decimals,
                    )}
                  </div>
                </div>
              ),
            )
          )}

        </div>
      </div>


      <div className="border p-6 rounded-xl">
        <h2 className="text-2xl font-bold mb-4">
          Aave Markets
        </h2>

        <div className="space-y-4">
          {reserves.map(
            reserve => (
              <div
                key={
                  reserve.asset
                }
                className="border p-4 rounded-lg"
              >
                <div>
                  <strong>
                    Asset:
                  </strong>{" "}
                  {
                    reserve.symbol
                  }
                </div>

                <div>
                  <strong>
                    Supply APY:
                  </strong>{" "}
                  {formatAPY(
                    reserve.liquidityRate,
                  )}
                  %
                </div>

                <div>
                  <strong>
                    Borrow APY:
                  </strong>{" "}
                  {formatAPY(
                    reserve.variableBorrowRate,
                  )}
                  %
                </div>

                <div>
                  <strong>
                    Liquidity:
                  </strong>{" "}
                  {formatTokenAmount(
                    reserve.liquidity,
                    reserve.decimals,
                  )}
                </div>
              </div>
            ),
          )}
        </div>
      </div>
      
      <div className="border p-6 rounded-xl">
      <h2 className="text-2xl font-bold mb-4">
        Your Positions
      </h2>

      <div className="space-y-4">

        {userPositions.length === 0 ? (
          <div className="opacity-70">
            No active positions
          </div>
        ) : (
          userPositions.map(
            position => (
              <div
                key={
                  position.asset
                }
                className="border p-4 rounded-lg"
              >
                <div>
                  <strong>
                    Asset:
                  </strong>{" "}
                  {
                    position.symbol
                  }
                </div>

                <div>
                  <strong>
                    Supplied:
                  </strong>{" "}
                  {formatTokenAmount(
                    position.supplied,
                    position.decimals,
                  )}
                </div>

                <div>
                  <strong>
                    Variable Debt:
                  </strong>{" "}
                  {formatTokenAmount(
                    position.variableDebt,
                    position.decimals,
                  )}
                </div>

                <div>
                  <strong>
                    Collateral:
                  </strong>{" "}
                  {position
                    .usageAsCollateralEnabled
                    ? "Enabled"
                    : "Disabled"}
                </div>
              </div>
            ),
          )
        )}

      </div>
      </div>
    </div>
  );
}

