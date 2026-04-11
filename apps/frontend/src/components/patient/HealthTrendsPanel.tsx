"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import {
  CartesianGrid,
  Line,
  LineChart,
  ReferenceArea,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { ApiError } from "../../lib/api";
import {
  fetchPatientHealthProfile,
  type HealthProfileGroupBy,
  type HealthProfileRange,
  type HealthProfileSeries,
  type PatientHealthProfileResponse,
} from "../../lib/patientApi";

const RANGE_OPTIONS: { value: HealthProfileRange; label: string }[] = [
  { value: "3m", label: "Last 3 months" },
  { value: "6m", label: "Last 6 months" },
  { value: "12m", label: "Last 12 months" },
  { value: "all", label: "All time" },
];

const GROUP_OPTIONS: { value: HealthProfileGroupBy; label: string }[] = [
  { value: "analyte", label: "By analyte" },
  { value: "lab_test", label: "By lab test" },
];

function formatAxisDate(iso: string) {
  return new Date(iso).toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function trendBadge(direction: HealthProfileSeries["trend"]["direction"]) {
  switch (direction) {
    case "increasing":
      return { label: "Rising", className: "bg-amber-100 text-amber-900" };
    case "decreasing":
      return { label: "Falling", className: "bg-sky-100 text-sky-900" };
    case "stable":
      return { label: "Stable", className: "bg-slate-100 text-slate-800" };
    default:
      return { label: "Not enough points", className: "bg-gray-100 text-gray-600" };
  }
}

function referenceBandFromPoints(points: HealthProfileSeries["points"]) {
  const ordered = [...points].sort(
    (a, b) => new Date(a.testDate).getTime() - new Date(b.testDate).getTime(),
  );
  const latest = [...ordered].reverse().find((p) => p.refLow != null && p.refHigh != null);
  if (!latest || latest.refLow == null || latest.refHigh == null) return null;
  return { y1: latest.refLow, y2: latest.refHigh, label: "Reference (latest report)" };
}

function buildChartRows(series: HealthProfileSeries) {
  return series.points
    .map((point) => ({
      ...point,
      label: formatAxisDate(point.testDate),
    }))
    .sort((a, b) => new Date(a.testDate).getTime() - new Date(b.testDate).getTime());
}

function SeriesChartCard({ series }: { series: HealthProfileSeries }) {
  const chartData = useMemo(() => buildChartRows(series), [series]);
  const refBand = useMemo(() => referenceBandFromPoints(series.points), [series.points]);
  const badge = trendBadge(series.trend.direction);

  return (
    <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
      <div className="flex flex-wrap items-baseline justify-between gap-2 mb-3">
        <div>
          <h3 className="text-lg text-gray-900">{series.displayName}</h3>
          {series.category && <p className="text-sm text-gray-500">{series.category}</p>}
          {series.labTestName && (
            <p className="text-sm text-gray-600 mt-0.5">Lab test: {series.labTestName}</p>
          )}
        </div>
        <div className="flex flex-col items-end gap-1">
          <span className="text-sm text-gray-600">Unit: {series.chartUnit || "—"}</span>
          <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${badge.className}`}>{badge.label}</span>
        </div>
      </div>

      <p className="text-sm text-gray-700 mb-2">{series.trend.narrative}</p>
      {series.trend.qualitativeNote && (
        <p className="text-sm text-indigo-900 bg-indigo-50 border border-indigo-100 rounded-lg px-3 py-2 mb-4">
          {series.trend.qualitativeNote}
        </p>
      )}

      <div className="h-64 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={chartData} margin={{ top: 8, right: 16, left: 0, bottom: 8 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
            <XAxis dataKey="label" tick={{ fontSize: 12 }} stroke="#6b7280" />
            <YAxis tick={{ fontSize: 12 }} stroke="#6b7280" domain={["auto", "auto"]} />
            {refBand && (
              <ReferenceArea
                y1={refBand.y1}
                y2={refBand.y2}
                fill="#bfdbfe"
                fillOpacity={0.35}
                stroke="#93c5fd"
                strokeDasharray="4 4"
                ifOverflow="extendDomain"
              />
            )}
            <Tooltip
              formatter={(value: number | string, _name, props) => {
                const p = props.payload as (typeof chartData)[0];
                const main =
                  typeof value === "number" ? `${value.toFixed(2)} ${series.chartUnit}` : String(value);
                const ab =
                  p.abnormal === true ? " (outside reference on report)" : p.abnormal === false ? " (within reference)" : "";
                return [`${main}${ab}`, series.displayName];
              }}
              labelFormatter={(label) => String(label)}
            />
            <Line
              type="monotone"
              dataKey="value"
              stroke="#2563eb"
              strokeWidth={2}
              dot={(props) => {
                const { cx, cy, payload } = props;
                const abnormal = payload?.abnormal;
                const fill =
                  abnormal === true ? "#dc2626" : abnormal === false ? "#059669" : "#2563eb";
                const r = abnormal === true ? 5 : 4;
                return <circle cx={cx} cy={cy} r={r} fill={fill} stroke="#fff" strokeWidth={1} />;
              }}
              activeDot={{ r: 7 }}
              connectNulls
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
      {refBand && (
        <p className="text-xs text-gray-500 mt-2">
          Shaded band: reported reference interval from the most recent result that included limits ({refBand.label}).
          Limits can differ between labs and visits.
        </p>
      )}

      <div className="mt-4 space-y-2 text-sm text-gray-700">
        {series.points
          .slice()
          .sort((a, b) => new Date(a.testDate).getTime() - new Date(b.testDate).getTime())
          .map((point) => (
            <div
              key={`${point.bookingId}-${point.testDate}`}
              className="flex flex-wrap gap-x-4 gap-y-1 border-t border-gray-100 pt-2 first:border-t-0 first:pt-0"
            >
              <span>{formatAxisDate(point.testDate)}</span>
              <span className="font-medium">
                {point.value.toFixed(2)} {series.chartUnit}
              </span>
              <span className="text-gray-500">{point.labName}</span>
              {point.labTestName && <span className="text-gray-500">{point.labTestName}</span>}
              {point.abnormal === true && <span className="text-red-700 font-medium">Outside reference</span>}
              {point.abnormal === false && <span className="text-emerald-800">Within reference</span>}
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
}

function exportTrendsCsv(data: PatientHealthProfileResponse | null) {
  if (!data) return;
  const lines: string[] = [];
  lines.push("group,canonicalCode,displayName,labTest,testDate,value,unit,refLow,refHigh,abnormal,lab,bookingId");
  const writeSeries = (series: HealthProfileSeries, groupLabel: string) => {
    for (const p of series.points) {
      lines.push(
        [
          groupLabel,
          series.canonicalCode,
          `"${series.displayName.replace(/"/g, '""')}"`,
          `"${(p.labTestName ?? "").replace(/"/g, '""')}"`,
          p.testDate,
          p.value,
          series.chartUnit,
          p.refLow ?? "",
          p.refHigh ?? "",
          p.abnormal === null ? "" : p.abnormal ? "yes" : "no",
          `"${p.labName.replace(/"/g, '""')}"`,
          p.bookingId,
        ].join(","),
      );
    }
  };
  if (data.groupBy === "lab_test") {
    for (const g of data.labTestGroups) {
      for (const s of g.series) writeSeries(s, g.labTestName);
    }
  } else {
    for (const s of data.series) writeSeries(s, "all");
  }
  const blob = new Blob([lines.join("\n")], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `lab-trends-${data.range}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}

type Props = {
  onUnauthorized: () => void;
};

export function HealthTrendsPanel({ onUnauthorized }: Props) {
  const [range, setRange] = useState<HealthProfileRange>("12m");
  const [groupBy, setGroupBy] = useState<HealthProfileGroupBy>("analyte");
  const [data, setData] = useState<PatientHealthProfileResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(
    async (nextRange: HealthProfileRange, nextGroup: HealthProfileGroupBy) => {
      setLoading(true);
      setError(null);
      try {
        const response = await fetchPatientHealthProfile(nextRange, nextGroup);
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
    void load(range, groupBy);
  }, [load, range, groupBy]);

  const hasCharts =
    data?.hasStructuredData &&
    (groupBy === "analyte" ? data.series.length > 0 : data.labTestGroups.some((g) => g.series.length > 0));

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
        <h2 className="text-lg text-gray-900 mb-1">Medical history & trends</h2>
        <p className="text-sm text-gray-600 mb-4">
          Line charts use normalized numeric values when structured data is available. Official records remain the
          uploaded PDFs from each lab.
        </p>
        <div className="flex flex-col gap-4">
          <div>
            <p className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-2">Date range</p>
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
          <div>
            <p className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-2">Group results</p>
            <div className="flex flex-wrap gap-2">
              {GROUP_OPTIONS.map((option) => (
                <button
                  key={option.value}
                  type="button"
                  onClick={() => setGroupBy(option.value)}
                  className={`px-3 py-1.5 rounded-lg text-sm ${
                    groupBy === option.value ? "bg-blue-600 text-white" : "bg-gray-100 text-gray-800 hover:bg-gray-200"
                  }`}
                >
                  {option.label}
                </button>
              ))}
            </div>
            <p className="text-xs text-gray-500 mt-2">
              <strong>By analyte</strong> merges the same test name across bookings. <strong>By lab test</strong> keeps
              each booked panel separate—useful when the same marker appears under different packages.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <button
              type="button"
              onClick={() => exportTrendsCsv(data)}
              disabled={!data || !hasCharts}
              className="px-3 py-1.5 rounded-lg text-sm border border-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Export CSV (visible range)
            </button>
            <span className="text-xs text-gray-500">PNG export can be added later; CSV works in Excel/Sheets.</span>
          </div>
        </div>
      </div>

      {error && <p className="text-red-600">{error}</p>}
      {loading && <p className="text-gray-600">Loading trends...</p>}

      {data && (
        <p className="text-xs text-gray-600 bg-gray-100 border border-gray-200 rounded-lg px-3 py-2">{data.disclaimer}</p>
      )}

      {!loading && data && data.hasStructuredData && !hasCharts && (
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
        groupBy === "analyte" &&
        data.series.map((series) => <SeriesChartCard key={series.canonicalCode} series={series} />)}

      {!loading &&
        data?.hasStructuredData &&
        groupBy === "lab_test" &&
        data.labTestGroups.map((group) => (
          <div key={group.labTestName} className="space-y-4">
            <div className="border-b border-gray-200 pb-2">
              <h3 className="text-base font-semibold text-gray-900">{group.labTestName}</h3>
              <p className="text-sm text-gray-500">Structured analytes recorded under this booked test.</p>
            </div>
            {group.series.map((series) => (
              <SeriesChartCard key={`${group.labTestName}-${series.canonicalCode}`} series={series} />
            ))}
          </div>
        ))}
    </div>
  );
}
