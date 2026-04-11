"use client";

import { useCallback, useEffect, useState } from "react";
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { ApiError } from "../../lib/api";
import {
  fetchPatientHealthProfile,
  type HealthProfileRange,
  type PatientHealthProfileResponse,
} from "../../lib/patientApi";

const RANGE_OPTIONS: { value: HealthProfileRange; label: string }[] = [
  { value: "3m", label: "Last 3 months" },
  { value: "6m", label: "Last 6 months" },
  { value: "12m", label: "Last 12 months" },
  { value: "all", label: "All time" },
];

function formatAxisDate(iso: string) {
  return new Date(iso).toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

type Props = {
  onUnauthorized: () => void;
};

export function HealthTrendsPanel({ onUnauthorized }: Props) {
  const [range, setRange] = useState<HealthProfileRange>("12m");
  const [data, setData] = useState<PatientHealthProfileResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(
    async (nextRange: HealthProfileRange) => {
      setLoading(true);
      setError(null);
      try {
        const response = await fetchPatientHealthProfile(nextRange);
        setData(response);
      } catch (err) {
        if (err instanceof ApiError && err.status === 401) {
          onUnauthorized();
          return;
        }
        setError("Unable to load health trends.");
      } finally {
        setLoading(false);
      }
    },
    [onUnauthorized],
  );

  useEffect(() => {
    void load(range);
  }, [load, range]);

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
        <h2 className="text-lg text-gray-900 mb-1">Medical history & trends</h2>
        <p className="text-sm text-gray-600 mb-4">
          One profile across labs. Charts use normalized numeric values when structured data is available; official
          documents remain the uploaded PDFs.
        </p>
        <div className="flex flex-wrap gap-2">
          {RANGE_OPTIONS.map((option) => (
            <button
              key={option.value}
              type="button"
              onClick={() => {
                setRange(option.value);
              }}
              className={`px-3 py-1.5 rounded-lg text-sm ${
                range === option.value ? "bg-blue-600 text-white" : "bg-gray-100 text-gray-800 hover:bg-gray-200"
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      {error && <p className="text-red-600">{error}</p>}
      {loading && <p className="text-gray-600">Loading trends...</p>}

      {!loading && data && data.hasStructuredData && data.series.length === 0 && (
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-6 text-amber-950 text-sm">
          Structured values are on file for this period, but none are chartable yet (for example unmapped test names or
          non-comparable units). Check the Results tab for PDFs and details.
        </div>
      )}

      {!loading && data && !data.hasStructuredData && (
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-6 text-amber-950">
          <p className="font-medium mb-2">Structured lab values are not available yet</p>
          <p className="text-sm text-amber-900 mb-3">
            You can still open PDF results from the Results tab. When your lab publishes structured analytes, trends will
            appear here automatically.
          </p>
          {data.pdfOnlyBookings.length > 0 && (
            <div className="text-sm">
              <p className="text-amber-900 mb-2">Results available as PDF only:</p>
              <ul className="list-disc pl-5 space-y-1 text-amber-900">
                {data.pdfOnlyBookings.map((row) => (
                  <li key={row.bookingId}>
                    {row.testName} · {row.labName} · {formatAxisDate(row.scheduledAt)}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}

      {!loading &&
        data?.hasStructuredData &&
        data.series.map((series) => {
          const chartData = series.points.map((point) => ({
            ...point,
            label: formatAxisDate(point.testDate),
          }));

          return (
            <div key={series.canonicalCode} className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
              <div className="flex flex-wrap items-baseline justify-between gap-2 mb-4">
                <div>
                  <h3 className="text-lg text-gray-900">{series.displayName}</h3>
                  {series.category && <p className="text-sm text-gray-500">{series.category}</p>}
                </div>
                <span className="text-sm text-gray-600">Unit: {series.chartUnit || "—"}</span>
              </div>

              <div className="h-64 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={chartData} margin={{ top: 8, right: 16, left: 0, bottom: 8 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                    <XAxis dataKey="label" tick={{ fontSize: 12 }} stroke="#6b7280" />
                    <YAxis tick={{ fontSize: 12 }} stroke="#6b7280" domain={["auto", "auto"]} />
                    <Tooltip
                      formatter={(value: number | string) => [
                        typeof value === "number" ? value.toFixed(2) : String(value),
                        series.displayName,
                      ]}
                      labelFormatter={(label) => String(label)}
                    />
                    <Line
                      type="monotone"
                      dataKey="value"
                      stroke="#2563eb"
                      strokeWidth={2}
                      dot={{ r: 4 }}
                      activeDot={{ r: 6 }}
                      connectNulls
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              <div className="mt-4 space-y-2 text-sm text-gray-700">
                {series.points.map((point) => (
                  <div
                    key={`${point.bookingId}-${point.testDate}`}
                    className="flex flex-wrap gap-x-4 gap-y-1 border-t border-gray-100 pt-2 first:border-t-0 first:pt-0"
                  >
                    <span>{formatAxisDate(point.testDate)}</span>
                    <span className="font-medium">
                      {point.value.toFixed(2)} {series.chartUnit}
                    </span>
                    <span className="text-gray-500">{point.labName}</span>
                    {!point.comparable && (
                      <span className="text-amber-700">
                        {point.comparabilityNote ?? "Not comparable across labs for this point."}
                      </span>
                    )}
                  </div>
                ))}
              </div>
            </div>
          );
        })}
    </div>
  );
}
