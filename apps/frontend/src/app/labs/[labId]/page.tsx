"use client";

import { useEffect, useState } from "react";
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

  return (
    <LabDetailsPage
      lab={data?.lab}
      tests={data?.tests ?? []}
      reviewItems={data?.reviewItems ?? []}
      isLoading={isLoading}
      onBack={() => router.push("/labs")}
      onBookTest={(selectedLab, test) => {
        const testId = test?.id ?? "";
        router.push(`/booking?labId=${selectedLab.id}&testId=${testId}`);
      }}
    />
  );
}
