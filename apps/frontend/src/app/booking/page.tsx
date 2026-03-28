import { Suspense } from "react";
import BookingClient from "./BookingClient";

export default function BookingRoute() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center bg-gray-50">Loading…</div>}>
      <BookingClient />
    </Suspense>
  );
}
