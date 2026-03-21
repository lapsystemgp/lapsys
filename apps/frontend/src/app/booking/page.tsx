"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { BookingPage } from "../../teslty/components/BookingPage";
import { getLabById, getTestById } from "../../teslty/data/labs";

export default function BookingRoute() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const labIdParam = searchParams.get("labId");
  const testIdParam = searchParams.get("testId");
  const labId = labIdParam ? Number(labIdParam) : Number.NaN;
  const testId = testIdParam ? Number(testIdParam) : Number.NaN;

  const lab = Number.isNaN(labId) ? undefined : getLabById(labId);
  const test = Number.isNaN(testId) ? undefined : getTestById(testId);

  return (
    <BookingPage
      lab={lab}
      test={test}
      onBack={() => {
        if (lab?.id) {
          router.push(`/labs/${lab.id}`);
          return;
        }
        router.push("/labs");
      }}
      onComplete={() => router.push("/patient/dashboard")}
    />
  );
}
