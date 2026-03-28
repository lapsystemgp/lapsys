"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { BookingPage } from "../../teslty/components/BookingPage";
import { fetchPublicLabDetail, fetchPublicTest, type PublicLabCard, type PublicTestResponse } from "../../lib/publicApi";

export default function BookingClient() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const labIdParam = searchParams.get("labId");
  const testIdParam = searchParams.get("testId");
  const labId = labIdParam ?? "";
  const testId = testIdParam ?? "";
  const [lab, setLab] = useState<PublicLabCard | null>(null);
  const [test, setTest] = useState<PublicTestResponse | null>(null);
  const [resolvedKey, setResolvedKey] = useState<string>("");
  const requestKey = `${labId}:${testId}`;
  const isLoading = labId.length > 0 && resolvedKey !== requestKey;

  const timeSlots = useMemo(() => {
    const stableId = labId || "placeholder";
    const slots = ["08:00", "09:30", "11:00", "13:00", "15:00", "16:30", "18:00"];
    const seed = stableId.split("").reduce((acc, ch) => acc + ch.charCodeAt(0), 0);
    const count = 3 + (seed % 3);
    const start = seed % (slots.length - count);
    return slots.slice(start, start + count);
  }, [labId]);

  useEffect(() => {
    let isMounted = true;
    if (!labId) return;

    Promise.allSettled([fetchPublicLabDetail(labId), testId ? fetchPublicTest(testId) : Promise.resolve(null)])
      .then((results) => {
        if (!isMounted) return;
        const labRes = results[0];
        const testRes = results[1];

        if (labRes?.status === "fulfilled") setLab(labRes.value.lab);
        else setLab(null);

        if (testRes?.status === "fulfilled") setTest(testRes.value);
        else setTest(null);

        setResolvedKey(requestKey);
      })
      .finally(() => {
        if (!isMounted) return;
        setResolvedKey(requestKey);
      });

    return () => {
      isMounted = false;
    };
  }, [labId, requestKey, testId]);

  return (
    <BookingPage
      lab={lab ? { ...lab, timeSlots } : null}
      test={test}
      isLoading={isLoading}
      onBack={() => {
        if (labId) {
          router.push(`/labs/${labId}`);
          return;
        }
        router.push("/labs");
      }}
      onComplete={() => router.push("/patient/dashboard")}
    />
  );
}

