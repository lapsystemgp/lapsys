"use client";

import { useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { LabDetailsPage } from "../../../teslty/components/LabDetailsPage";
import { fetchPublicLabDetail, type PublicLabDetailResponse } from "../../../lib/publicApi";

export default function LabDetailsRoute() {
  const router = useRouter();
  const params = useParams<{ labId: string }>();
  const labId = params.labId;
  const [data, setData] = useState<PublicLabDetailResponse | null>(null);
  const [resolvedLabId, setResolvedLabId] = useState<string>("");
  const isLoading = resolvedLabId !== labId;

  useEffect(() => {
    let isMounted = true;
    fetchPublicLabDetail(labId)
      .then((res) => {
        if (!isMounted) return;
        setData(res);
        setResolvedLabId(labId);
      })
      .catch(() => {
        if (!isMounted) return;
        setData(null);
        setResolvedLabId(labId);
      })

    return () => {
      isMounted = false;
    };
  }, [labId]);

  const placeholderTimeSlots = useMemo(() => {
    const slots = ["08:00", "09:30", "11:00", "13:00", "15:00", "16:30", "18:00"];
    const seed = labId.split("").reduce((acc, ch) => acc + ch.charCodeAt(0), 0);
    const count = 3 + (seed % 3);
    const start = seed % (slots.length - count);
    return slots.slice(start, start + count);
  }, [labId]);

  return (
    <LabDetailsPage
      lab={data?.lab}
      tests={data?.tests ?? []}
      isLoading={isLoading}
      timeSlots={placeholderTimeSlots}
      onBack={() => router.push("/labs")}
      onBookTest={(selectedLab, test) => {
        const testId = test?.id ?? "";
        router.push(`/booking?labId=${selectedLab.id}&testId=${testId}`);
      }}
    />
  );
}
