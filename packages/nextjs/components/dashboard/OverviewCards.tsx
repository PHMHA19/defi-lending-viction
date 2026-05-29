"use client";

type Props = {
  supplied: number;
  borrowed: number;
  healthFactor: number;
};

export const OverviewCards = ({
  supplied,
  borrowed,
  healthFactor,
}: Props) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">

      {/* Tổng tài sản nạp */}
      <div className="bg-base-200 rounded-2xl p-6 shadow">

        <p className="text-sm opacity-70">
          Tổng tài sản nạp
        </p>

        <h2 className="text-3xl font-bold mt-2">
          ${supplied.toLocaleString()}
        </h2>

      </div>

      {/* Tổng tài sản vay */}
      <div className="bg-base-200 rounded-2xl p-6 shadow">

        <p className="text-sm opacity-70">
          Tổng tài sản vay
        </p>

        <h2 className="text-3xl font-bold mt-2">
          ${borrowed.toLocaleString()}
        </h2>

      </div>

      {/* Health Factor */}
      <div className="bg-base-200 rounded-2xl p-6 shadow">

        <p className="text-sm opacity-70">
          Health Factor
        </p>

        <h2
          className={`text-3xl font-bold mt-2 ${
            healthFactor > 2
              ? "text-green-500"
              : healthFactor > 1
              ? "text-yellow-500"
              : "text-red-500"
          }`}
        >
          {
            healthFactor > 1000000
              ? "∞"
              : healthFactor.toFixed(2)
          }
        </h2>

      </div>

    </div>
  );
};
