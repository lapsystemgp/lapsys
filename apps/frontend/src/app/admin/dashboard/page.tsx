"use client";

import { AlertTriangle, ArrowLeft, Building2, CheckCircle2, Clock3, PauseCircle, Search, XCircle } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { ApiError } from "../../../lib/api";
import {
  fetchAdminRecentPayments,
  fetchAdminWorkspace,
  setAdminLabOnboardingStatus,
  type AdminLabOnboardingStatus,
  type AdminPaymentRecord,
  type AdminWorkspaceResponse,
} from "../../../lib/adminApi";
import { useSession } from "../../../components/SessionProvider";

type StatusFilter = "All" | AdminLabOnboardingStatus;
type ReadinessFilter = "All" | "Ready" | "NeedsSetup";

function statusClasses(status: AdminLabOnboardingStatus) {
  if (status === "Active") return "bg-green-100 text-green-700";
  if (status === "PendingReview") return "bg-amber-100 text-amber-700";
  if (status === "Rejected") return "bg-red-100 text-red-700";
  return "bg-slate-200 text-slate-700";
}

function formatDate(value: string) {
  return new Date(value).toLocaleString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function readApiErrorMessage(err: unknown, fallback: string) {
  if (err instanceof ApiError && err.bodyText) {
    try {
      const parsed = JSON.parse(err.bodyText) as { message?: string | string[] };
      if (Array.isArray(parsed.message)) {
        return parsed.message.join(", ");
      }
      if (typeof parsed.message === "string" && parsed.message.trim()) {
        return parsed.message;
      }
    } catch {
      if (err.bodyText.trim()) {
        return err.bodyText.trim();
      }
    }
  }

  if (err instanceof Error && err.message.trim()) {
    return err.message;
  }

  return fallback;
}

const statusFilters: StatusFilter[] = ["All", "PendingReview", "Active", "Rejected", "Suspended"];

export default function AdminDashboardPage() {
  const router = useRouter();
  const { user, logout } = useSession();

  const [workspace, setWorkspace] = useState<AdminWorkspaceResponse | null>(null);
  const [paymentRows, setPaymentRows] = useState<AdminPaymentRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("All");
  const [readinessFilter, setReadinessFilter] = useState<ReadinessFilter>("All");
  const [updatingLabId, setUpdatingLabId] = useState<string | null>(null);

  const loadWorkspace = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [response, payments] = await Promise.all([fetchAdminWorkspace(), fetchAdminRecentPayments()]);
      setWorkspace(response);
      setPaymentRows(payments.items);
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        router.push("/login");
        return;
      }
      if (err instanceof ApiError && err.status === 403) {
        router.push("/unauthorized");
        return;
      }
      setError("Unable to load admin workspace.");
    } finally {
      setLoading(false);
    }
  }, [router]);

  useEffect(() => {
    loadWorkspace();
  }, [loadWorkspace]);

  const filteredLabs = useMemo(() => {
    const normalizedQuery = searchQuery.trim().toLowerCase();

    return (workspace?.labs ?? []).filter((lab) => {
      const matchesStatus = statusFilter === "All" || lab.onboardingStatus === statusFilter;
      const matchesReadiness =
        readinessFilter === "All" ||
        (readinessFilter === "Ready" ? lab.onboardingReadiness.isReady : !lab.onboardingReadiness.isReady);
      const matchesQuery =
        normalizedQuery.length === 0 ||
        lab.labName.toLowerCase().includes(normalizedQuery) ||
        lab.email.toLowerCase().includes(normalizedQuery) ||
        lab.address.toLowerCase().includes(normalizedQuery) ||
        lab.accreditation.toLowerCase().includes(normalizedQuery);

      return matchesStatus && matchesReadiness && matchesQuery;
    });
  }, [readinessFilter, searchQuery, statusFilter, workspace?.labs]);

  const handleLogout = async () => {
    await logout();
    router.push("/login");
  };

  const handleStatusUpdate = async (
    labProfileId: string,
    status: AdminLabOnboardingStatus,
  ) => {
    setUpdatingLabId(labProfileId);
    setError(null);
    try {
      await setAdminLabOnboardingStatus(labProfileId, status);
      await loadWorkspace();
    } catch (err) {
      setError(readApiErrorMessage(err, "Could not update lab status."));
    } finally {
      setUpdatingLabId(null);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4">
          <div className="space-y-2">
            <button
              onClick={() => router.push("/")}
              className="flex items-center gap-2 text-sm text-slate-600 hover:text-slate-900"
            >
              <ArrowLeft className="h-4 w-4" />
              Back to Home
            </button>
            <div>
              <h1 className="text-2xl text-slate-900">Admin Dashboard</h1>
              <p className="text-slate-600">{user?.email}</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="rounded-lg border border-slate-300 px-4 py-2 hover:bg-slate-50"
          >
            Logout
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-7xl px-4 py-8">
        {error && <p className="mb-4 text-red-600">{error}</p>}

        {loading || !workspace ? (
          <p>Loading admin workspace...</p>
        ) : (
          <div className="space-y-6">
            <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
              <StatCard icon={<Building2 className="h-5 w-5 text-blue-600" />} label="Total Labs" value={workspace.stats.totalLabs} />
              <StatCard icon={<Clock3 className="h-5 w-5 text-amber-600" />} label="Pending Review" value={workspace.stats.pendingLabs} />
              <StatCard icon={<CheckCircle2 className="h-5 w-5 text-green-600" />} label="Active Labs" value={workspace.stats.activeLabs} />
              <StatCard icon={<XCircle className="h-5 w-5 text-red-600" />} label="Rejected Labs" value={workspace.stats.rejectedLabs} />
              <StatCard icon={<PauseCircle className="h-5 w-5 text-slate-600" />} label="Suspended Labs" value={workspace.stats.suspendedLabs} />
              <StatCard icon={<CheckCircle2 className="h-5 w-5 text-emerald-600" />} label="Ready Pending Labs" value={workspace.stats.readyPendingLabs} />
              <StatCard icon={<AlertTriangle className="h-5 w-5 text-orange-600" />} label="Needs Setup" value={workspace.stats.incompleteLabs} />
            </section>

            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <h2 className="text-lg text-slate-900 mb-1">Payment audit (demo gateway)</h2>
              <p className="text-sm text-slate-600 mb-4">
                Recent bookings with payment method, status, and references. No real processor is connected.
              </p>
              <div className="overflow-x-auto">
                <table className="min-w-full text-left text-sm text-slate-800">
                  <thead>
                    <tr className="border-b border-slate-200 text-slate-500">
                      <th className="py-2 pr-4 font-medium">Created</th>
                      <th className="py-2 pr-4 font-medium">Patient</th>
                      <th className="py-2 pr-4 font-medium">Lab / test</th>
                      <th className="py-2 pr-4 font-medium">Method</th>
                      <th className="py-2 pr-4 font-medium">Pay status</th>
                      <th className="py-2 pr-4 font-medium">Amount</th>
                      <th className="py-2 font-medium">Reference</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paymentRows.length === 0 ? (
                      <tr>
                        <td colSpan={7} className="py-6 text-center text-slate-600">
                          No booking records yet.
                        </td>
                      </tr>
                    ) : (
                      paymentRows.map((row) => (
                        <tr key={row.bookingId} className="border-b border-slate-100">
                          <td className="py-2 pr-4 whitespace-nowrap">{formatDate(row.createdAt)}</td>
                          <td className="py-2 pr-4">
                            <div>{row.patientEmail}</div>
                            {row.patientName && <div className="text-slate-500">{row.patientName}</div>}
                          </td>
                          <td className="py-2 pr-4">
                            <div>{row.labName}</div>
                            <div className="text-slate-500">{row.testName}</div>
                          </td>
                          <td className="py-2 pr-4">{row.paymentMethod}</td>
                          <td className="py-2 pr-4">{row.paymentStatus}</td>
                          <td className="py-2 pr-4">EGP {row.totalPriceEgp}</td>
                          <td className="py-2 font-mono text-xs text-slate-600">{row.paymentReference ?? "—"}</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </section>

            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="mb-4 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                <div>
                  <h2 className="text-lg text-slate-900">Lab Onboarding Queue</h2>
                  <p className="text-sm text-slate-600">
                    Review new labs, approve them for platform access, or manage existing statuses.
                  </p>
                </div>
                <div className="relative w-full lg:max-w-sm">
                  <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                  <input
                    value={searchQuery}
                    onChange={(event) => setSearchQuery(event.target.value)}
                    placeholder="Search by lab, email, address..."
                    className="w-full rounded-lg border border-slate-300 py-2 pl-9 pr-3 outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="mb-4 flex flex-wrap gap-2">
                {statusFilters.map((item) => (
                  <button
                    key={item}
                    onClick={() => setStatusFilter(item)}
                    className={`rounded-full px-4 py-2 text-sm ${
                      statusFilter === item
                        ? "bg-blue-600 text-white"
                        : "border border-slate-300 bg-white text-slate-700 hover:bg-slate-50"
                    }`}
                  >
                    {item === "All" ? "All Statuses" : item}
                  </button>
                ))}
              </div>

              <div className="mb-4 flex flex-wrap gap-2">
                {(["All", "Ready", "NeedsSetup"] as ReadinessFilter[]).map((item) => (
                  <button
                    key={item}
                    onClick={() => setReadinessFilter(item)}
                    className={`rounded-full px-4 py-2 text-sm ${
                      readinessFilter === item
                        ? "bg-slate-900 text-white"
                        : "border border-slate-300 bg-white text-slate-700 hover:bg-slate-50"
                    }`}
                  >
                    {item === "All" ? "All Readiness" : item === "Ready" ? "Ready for Activation" : "Needs Setup"}
                  </button>
                ))}
              </div>

              <div className="space-y-4">
                {filteredLabs.length === 0 ? (
                  <div className="rounded-xl border border-dashed border-slate-300 p-8 text-center text-slate-600">
                    No labs match the current filters.
                  </div>
                ) : (
                  filteredLabs.map((lab) => (
                    <div key={lab.id} className="rounded-xl border border-slate-200 p-5">
                      <div className="mb-4 flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
                        <div className="space-y-2">
                          <div className="flex flex-wrap items-center gap-3">
                            <h3 className="text-xl text-slate-900">{lab.labName}</h3>
                            <span className={`rounded-full px-3 py-1 text-sm ${statusClasses(lab.onboardingStatus)}`}>
                              {lab.onboardingStatus}
                            </span>
                          </div>
                          <p className="text-slate-600">{lab.email}</p>
                          <p className="text-sm text-slate-500">{lab.address}</p>
                        </div>
                        <div className="rounded-xl bg-slate-50 px-4 py-3 text-sm text-slate-700">
                          <p>Created: {formatDate(lab.createdAt)}</p>
                          <p>Updated: {formatDate(lab.updatedAt)}</p>
                        </div>
                      </div>

                      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                        <InfoBlock label="Phone" value={lab.phone || "Not provided"} />
                        <InfoBlock label="Accreditation" value={lab.accreditation || "Not provided"} />
                        <InfoBlock label="Turnaround Time" value={lab.turnaroundTime || "Not provided"} />
                        <InfoBlock label="Home Collection" value={lab.homeCollection ? "Available" : "Not available"} />
                        <InfoBlock label="Tests" value={String(lab.testsCount)} />
                        <InfoBlock label="Bookings" value={String(lab.bookingsCount)} />
                        <InfoBlock label="Schedule Slots" value={String(lab.scheduleSlotsCount)} />
                        <InfoBlock
                          label="Rating"
                          value={lab.ratingAverage ? `${lab.ratingAverage.toFixed(1)} (${lab.reviewCount} reviews)` : "No ratings yet"}
                        />
                      </div>

                      <div className="mt-4 rounded-xl border border-slate-200 bg-slate-50 p-4">
                        <div className="mb-2 flex items-center justify-between gap-3">
                          <div>
                            <p className="text-sm text-slate-500">Onboarding Readiness</p>
                            <p className="text-slate-900">
                              {lab.onboardingReadiness.completedRequirements}/{lab.onboardingReadiness.totalRequirements} requirements completed
                            </p>
                          </div>
                          <span
                            className={`rounded-full px-3 py-1 text-sm ${
                              lab.onboardingReadiness.isReady
                                ? "bg-green-100 text-green-700"
                                : "bg-orange-100 text-orange-700"
                            }`}
                          >
                            {lab.onboardingReadiness.isReady ? "Ready" : "Needs Setup"}
                          </span>
                        </div>
                        {lab.onboardingReadiness.missingRequirements.length > 0 ? (
                          <div className="flex flex-wrap gap-2">
                            {lab.onboardingReadiness.missingRequirements.map((item) => (
                              <span
                                key={item}
                                className="rounded-full bg-white px-3 py-1 text-sm text-slate-700 border border-slate-200"
                              >
                                Missing: {item}
                              </span>
                            ))}
                          </div>
                        ) : (
                          <p className="text-sm text-slate-600">This lab has completed the minimum onboarding checklist.</p>
                        )}
                      </div>

                      <div className="mt-5 flex flex-wrap gap-2">
                        {lab.onboardingStatus !== "Active" && (
                          <ActionButton
                            loading={updatingLabId === lab.id}
                            disabled={!lab.onboardingReadiness.isReady}
                            onClick={() => handleStatusUpdate(lab.id, "Active")}
                            className="bg-green-600 text-white hover:bg-green-700"
                          >
                            Approve / Activate
                          </ActionButton>
                        )}
                        {lab.onboardingStatus !== "Rejected" && (
                          <ActionButton
                            loading={updatingLabId === lab.id}
                            disabled={false}
                            onClick={() => handleStatusUpdate(lab.id, "Rejected")}
                            className="border border-red-300 text-red-700 hover:bg-red-50"
                          >
                            Reject
                          </ActionButton>
                        )}
                        {lab.onboardingStatus !== "Suspended" && (
                          <ActionButton
                            loading={updatingLabId === lab.id}
                            disabled={false}
                            onClick={() => handleStatusUpdate(lab.id, "Suspended")}
                            className="border border-slate-300 text-slate-700 hover:bg-slate-100"
                          >
                            Suspend
                          </ActionButton>
                        )}
                      </div>
                    </div>
                  ))
                )}
              </div>
            </section>
          </div>
        )}
      </main>
    </div>
  );
}

function StatCard({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode;
  label: string;
  value: number;
}) {
  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <div className="mb-3 flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50">
        {icon}
      </div>
      <p className="text-sm text-slate-500">{label}</p>
      <p className="mt-1 text-3xl text-slate-900">{value}</p>
    </div>
  );
}

function InfoBlock({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-slate-50 p-4">
      <p className="text-sm text-slate-500">{label}</p>
      <p className="mt-1 text-slate-900">{value}</p>
    </div>
  );
}

function ActionButton({
  children,
  className,
  loading,
  disabled,
  onClick,
}: {
  children: React.ReactNode;
  className: string;
  loading: boolean;
  disabled: boolean;
  onClick: () => void;
}) {
  return (
    <button
      disabled={disabled || loading}
      onClick={onClick}
      className={`rounded-lg px-4 py-2 text-sm disabled:cursor-not-allowed disabled:opacity-60 ${className}`}
    >
      {loading ? "Updating..." : children}
    </button>
  );
}
