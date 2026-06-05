"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { AlertCircle, ArrowLeft } from "lucide-react";
import { LabDetailsPage } from "../../../teslty/components/LabDetailsPage";
import { fetchPublicLabDetail, type PublicLabDetailResponse } from "../../../lib/publicApi";
import { ApiError } from "../../../lib/api";

export default function LabDetailsRoute() {
  const router = useRouter();
  const params = useParams<{ labId: string }>();
  const labId = params.labId;
  const [data, setData] = useState<PublicLabDetailResponse | null>(null);
  const [resolvedLabId, setResolvedLabId] = useState<string>("");
  const [fetchError, setFetchError] = useState<"not_found" | "error" | null>(null);
  const [retryKey, setRetryKey] = useState(0);
  const isLoading = resolvedLabId !== labId && !fetchError;

  useEffect(() => {
    let isMounted = true;
    setFetchError(null);
    fetchPublicLabDetail(labId)
      .then((res) => {
        if (!isMounted) return;
        setData(res);
        setResolvedLabId(labId);
      })
      .catch((err) => {
        if (!isMounted) return;
        setData(null);
        setResolvedLabId(labId);
        setFetchError(err instanceof ApiError && err.status === 404 ? "not_found" : "error");
      });

    return () => {
      isMounted = false;
    };
  }, [labId, retryKey]);

  if (fetchError) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white rounded-2xl shadow-sm p-12 text-center max-w-md">
          <AlertCircle className={`w-12 h-12 mx-auto mb-4 ${fetchError === "not_found" ? "text-gray-400" : "text-red-400"}`} />
          <h2 className="text-xl font-medium text-gray-900 mb-2">
            {fetchError === "not_found" ? "Lab not found" : "Something went wrong"}
          </h2>
          <p className="text-gray-600 mb-6">
            {fetchError === "not_found"
              ? "This lab doesn't exist or is no longer available."
              : "We couldn't load this lab right now. Check your connection and try again."}
          </p>
          <div className="flex gap-3 justify-center">
            {fetchError === "error" && (
              <button
                onClick={() => setRetryKey((k) => k + 1)}
                className="px-5 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-semibold"
              >
                Try Again
              </button>
            )}
            <button
              onClick={() => router.push("/labs")}
              className="flex items-center gap-2 px-5 py-2 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 transition-colors font-semibold"
            >
              <ArrowLeft className="w-4 h-4" />
              Back to Labs
            </button>
          </div>
        </div>
      </div>
    );
  }

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
