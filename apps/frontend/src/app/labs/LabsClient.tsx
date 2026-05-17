"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { LabComparison } from "../../teslty/components/LabComparison";

export default function LabsClient() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const query = searchParams.get("q") ?? "";
  const rawSort = searchParams.get("sort") ?? "";
  const initialSort: 'price' | 'rating' | 'distance' =
    rawSort === 'rating' || rawSort === 'distance' ? rawSort : 'price';

  return (
    <LabComparison
      searchQuery={query}
      initialSort={initialSort}
      onLabSelect={(lab) => router.push(`/labs/${lab.id}`)}
      onBack={() => router.push("/")}
    />
  );
}

