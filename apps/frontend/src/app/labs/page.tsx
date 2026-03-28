import { Suspense } from "react";
import LabsClient from "./LabsClient";

export default function LabsPage() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center bg-gray-50">Loading…</div>}>
      <LabsClient />
    </Suspense>
  );
}
