
"use client";

import {
  useState,
  useEffect,
} from "react";

import {
  useAccount,
} from "wagmi";

import {
  TOKENS,
} from "~~/services/aave/addresses";

import {
  approveAsset,
  supplyAsset,
  getUserAccountData,
} from "~~/services/aave/pool";

import {
  getAllReserveData,
} from "~~/services/aave/reserve";

export default function TestPage() {
  const {
    address,
  } = useAccount();

  const [loading, setLoading] =
    useState(false);

  const [
    accountData,
    setAccountData,
  ] = useState<any>(null);

  const [
    reserves,
    setReserves,
  ] = useState<any[]>([]);

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

      const formattedData = {
        totalCollateral:
          Number(data[0]) / 1e8,

        totalDebt:
          Number(data[1]) / 1e8,

        availableBorrows:
          Number(data[2]) / 1e8,

        ltv:
          Number(data[4]) / 100,

        healthFactor:
          data[1] === 0n
            ? "∞"
            : (
                Number(
                  data[5] /
                  10n ** 16n,
                ) / 100
              ).toFixed(2),
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
      const amount =
        100n * 10n ** 6n;

      /**
       * Approve
       */
      await approveAsset(
        TOKENS.USDC,
        amount,
      );

      console.log(
        "Approve success",
      );

      /**
       * Supply
       */
      await supplyAsset(
        TOKENS.USDC,
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
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="p-10 space-y-6">
      <h1 className="text-4xl font-bold">
        Aave Dashboard
      </h1>

      <div className="flex gap-4">
        <button
          className="btn btn-primary"
          onClick={handleSupply}
          disabled={
            !address || loading
          }
        >
          {loading
            ? "Loading..."
            : "Supply 100 USDC"}
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

      {accountData && (
        <div className="space-y-4 border p-6 rounded-xl">
          <div>
            <strong>
              Total Collateral:
            </strong>{" "}
            {
              accountData.totalCollateral
            }
          </div>

          <div>
            <strong>
              Total Debt:
            </strong>{" "}
            {
              accountData.totalDebt
            }
          </div>

          <div>
            <strong>
              Available Borrows:
            </strong>{" "}
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
          Aave Markets
        </h2>

        <div className="space-y-4">
          {reserves.map(
            reserve => (
              <div
                key={reserve.asset}
                className="border p-4 rounded-lg"
              >
                <div>
                  <strong>
                    Asset:
                  </strong>{" "}
                  {reserve.asset}
                </div>

                <div>
                  <strong>
                    Supply APY:
                  </strong>{" "}
                  {reserve.liquidityRate.toFixed(
                    2,
                  )}
                  %
                </div>

                <div>
                  <strong>
                    Borrow APY:
                  </strong>{" "}
                  {reserve.variableBorrowRate.toFixed(
                    2,
                  )}
                  %
                </div>
              </div>
            ),
          )}
        </div>
      </div>
    </div>
  );
}

