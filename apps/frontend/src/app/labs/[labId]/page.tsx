"use client";

import { useParams, useRouter } from "next/navigation";
import { LabDetailsPage } from "../../../teslty/components/LabDetailsPage";
import { getLabById } from "../../../teslty/data/labs";

export default function LabDetailsRoute() {
  const router = useRouter();
  const params = useParams<{ labId: string }>();
  const labId = Number(params.labId);
  const lab = Number.isNaN(labId) ? undefined : getLabById(labId);

  return (
    <LabDetailsPage
      lab={lab}
      onBack={() => router.push("/labs")}
      onBookTest={(selectedLab, test) => {
        const testId = test?.id ?? "";
        router.push(`/booking?labId=${selectedLab.id}&testId=${testId}`);
      }}
    />
  );
}
