
"use client";

import { useEffect } from "react";

import { getReservesList } from "~~/services/aave/reserve";

export default function TestPage() {
  useEffect(() => {
    async function test() {
      try {
        const reserves =
          await getReservesList();

        console.log("RESERVES:", reserves);
      } catch (err) {
        console.error(err);
      }
    }

    test();
  }, []);

  return (
    <div className="p-10">
      <h1>Aave Reserve Discovery</h1>
      <p>Check console...</p>
    </div>
  );
}

