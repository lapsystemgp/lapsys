"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { LabComparison } from "../../teslty/components/LabComparison";

export default function LabsPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const query = searchParams.get("q") ?? "";

  return (
    <LabComparison
      searchQuery={query}
      onLabSelect={(lab) => router.push(`/labs/${lab.id}`)}
      onBack={() => router.push("/")}
    />
  );
}
