import { Suspense } from "react";
import TestDetailClient from "./TestDetailClient";

export default function TestDetailPage() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center bg-gray-50">Loading…</div>}>
      <TestDetailClient />
    </Suspense>
  );
}
