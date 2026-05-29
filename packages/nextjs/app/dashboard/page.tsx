"use client";

import { OverviewCards } from "~~/components/dashboard/OverviewCards";
import { SupplyTable } from "~~/components/dashboard/SupplyTable";
import { BorrowTable } from "~~/components/dashboard/BorrowTable";
import { useDashboardData } from "~~/hooks/useDashboardData";
import { FaucetCard } from "~~/components/dashboard/FaucetCard";
export default function DashboardPage() {

  const {
    supplied,
    borrowed,
    healthFactor,
  } = useDashboardData();

  return (
    <div className="p-10 max-w-7xl mx-auto">

      <div className="mb-10">
        <h1 className="text-5xl font-bold">
          Dashboard DeFi Lending
        </h1>

        <p className="opacity-70 mt-2">
          Quản lý tài sản và khoản vay của bạn
        </p>
      </div>

      <OverviewCards
        supplied={supplied}
        borrowed={borrowed}
        healthFactor={healthFactor}
      />
      <FaucetCard />

      <SupplyTable />

      <BorrowTable />
    </div>
  );
}