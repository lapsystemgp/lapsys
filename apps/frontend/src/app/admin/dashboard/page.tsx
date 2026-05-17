"use client";

import {
  AlertTriangle,
  BarChart2,
  CalendarDays,
  CheckCircle,
  Eye,
  FlaskConical,
  LogOut,
  Search,
  Shield,
  ShieldCheck,
  Users,
  XCircle,
} from "lucide-react";
import { type ReactNode, useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Breadcrumb } from "../../../components/Breadcrumb";
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

type Tab = "labApprovals" | "userManagement" | "allBookings" | "analytics" | "security";

function formatDate(value: string) {
  return new Date(value).toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function readApiErrorMessage(err: unknown, fallback: string) {
  if (err instanceof ApiError && err.bodyText) {
    try {
      const parsed = JSON.parse(err.bodyText) as { message?: string | string[] };
      if (Array.isArray(parsed.message)) return parsed.message.join(", ");
      if (typeof parsed.message === "string" && parsed.message.trim()) return parsed.message;
    } catch {
      if (err.bodyText.trim()) return err.bodyText.trim();
    }
  }
  if (err instanceof Error && err.message.trim()) return err.message;
  return fallback;
}

export default function AdminDashboardPage() {
  const router = useRouter();
  const { logout } = useSession();

  const [workspace, setWorkspace] = useState<AdminWorkspaceResponse | null>(null);
  const [paymentRows, setPaymentRows] = useState<AdminPaymentRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<Tab>("labApprovals");
  const [labStatusFilter, setLabStatusFilter] = useState<"All" | AdminLabOnboardingStatus>("All");
  const [labSearch, setLabSearch] = useState("");
  const [userSearch, setUserSearch] = useState("");
  const [updatingLabId, setUpdatingLabId] = useState<string | null>(null);
  const [expandedLabId, setExpandedLabId] = useState<string | null>(null);
  const [twoFaEnabled, setTwoFaEnabled] = useState(true);
  const [rateLimitEnabled, setRateLimitEnabled] = useState(true);

  const loadWorkspace = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [response, payments] = await Promise.all([fetchAdminWorkspace(), fetchAdminRecentPayments()]);
      setWorkspace(response);
      setPaymentRows(payments.items);
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) { router.push("/login"); return; }
      if (err instanceof ApiError && err.status === 403) { router.push("/unauthorized"); return; }
      setError("Unable to load admin workspace.");
    } finally {
      setLoading(false);
    }
  }, [router]);

  useEffect(() => { loadWorkspace(); }, [loadWorkspace]);

  const handleLogout = async () => {
    await logout();
    router.push("/login");
  };

  const handleStatusUpdate = async (labProfileId: string, status: AdminLabOnboardingStatus) => {
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

  const pendingCount = workspace?.stats.pendingLabs ?? 0;

  const filteredLabs = useMemo(() => {
    const q = labSearch.trim().toLowerCase();
    return (workspace?.labs ?? []).filter((lab) => {
      const matchesStatus = labStatusFilter === "All" || lab.onboardingStatus === labStatusFilter;
      const matchesQuery =
        !q ||
        lab.labName.toLowerCase().includes(q) ||
        lab.email.toLowerCase().includes(q) ||
        lab.address.toLowerCase().includes(q);
      return matchesStatus && matchesQuery;
    });
  }, [workspace, labStatusFilter, labSearch]);

  // Derive unique patients from payment rows
  const patients = useMemo(() => {
    const map = new Map<string, { name: string | null; email: string; bookings: number; joined: string }>();
    for (const row of paymentRows) {
      const existing = map.get(row.patientEmail);
      if (existing) {
        existing.bookings += 1;
      } else {
        map.set(row.patientEmail, { name: row.patientName, email: row.patientEmail, bookings: 1, joined: row.createdAt });
      }
    }
    return Array.from(map.values());
  }, [paymentRows]);

  const filteredPatients = useMemo(() => {
    const q = userSearch.trim().toLowerCase();
    if (!q) return patients;
    return patients.filter((p) => p.email.toLowerCase().includes(q) || (p.name ?? "").toLowerCase().includes(q));
  }, [patients, userSearch]);

  // Analytics
  const topLabs = useMemo(() => {
    const map = new Map<string, { bookings: number; revenue: number }>();
    for (const row of paymentRows) {
      const e = map.get(row.labName);
      if (e) { e.bookings++; e.revenue += row.totalPriceEgp; }
      else map.set(row.labName, { bookings: 1, revenue: row.totalPriceEgp });
    }
    return Array.from(map.entries()).map(([name, d]) => ({ name, ...d })).sort((a, b) => b.revenue - a.revenue).slice(0, 5);
  }, [paymentRows]);

  const topTests = useMemo(() => {
    const map = new Map<string, number>();
    for (const row of paymentRows) map.set(row.testName, (map.get(row.testName) ?? 0) + 1);
    return Array.from(map.entries()).map(([name, count]) => ({ name, count })).sort((a, b) => b.count - a.count).slice(0, 5);
  }, [paymentRows]);

  const totalRevenue = useMemo(() => paymentRows.reduce((s, r) => s + r.totalPriceEgp, 0), [paymentRows]);

  const tabs: { key: Tab; label: string; icon: ReactNode; badge?: number }[] = [
    { key: "labApprovals", label: "Lab Approvals", icon: <FlaskConical className="w-4 h-4" />, badge: pendingCount || undefined },
    { key: "userManagement", label: "User Management", icon: <Users className="w-4 h-4" /> },
    { key: "allBookings", label: "All Bookings", icon: <CalendarDays className="w-4 h-4" /> },
    { key: "analytics", label: "Analytics", icon: <BarChart2 className="w-4 h-4" /> },
    { key: "security", label: "Security", icon: <ShieldCheck className="w-4 h-4" /> },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* ── Header ── */}
      <header className="bg-gradient-to-r from-indigo-600 to-purple-700 px-4 py-4">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full border-2 border-white/30 flex items-center justify-center">
              <Shield className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="text-white font-semibold leading-tight">Admin Panel</p>
              <p className="text-indigo-200 text-xs">TesTly Platform</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white text-sm px-4 py-2 rounded-lg border border-white/20 transition-colors"
          >
            <LogOut className="w-4 h-4" />
            Logout
          </button>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-6">
        <Breadcrumb items={[{ label: "Admin Dashboard" }]} className="mb-5" />

        {error && (
          <div className="mb-4 bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm">
            {error}
          </div>
        )}

        {/* ── Stats Row ── */}
        <div className="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
          <StatCard label="Total Labs" value={workspace?.stats.totalLabs ?? 0} />
          <StatCard label="Active Labs" value={workspace?.stats.activeLabs ?? 0} />
          <StatCard label="Total Bookings" value={paymentRows.length} />
          <StatCard label="Platform Revenue" value={`EGP ${(totalRevenue / 1000).toFixed(0)}K`} />
          <StatCard label="Pending Approvals" value={pendingCount} highlight />
        </div>

        {/* ── Tabs ── */}
        {loading ? (
          <div className="bg-white rounded-xl shadow-sm p-12 text-center text-gray-400">
            Loading admin workspace…
          </div>
        ) : (
          <div className="bg-white rounded-xl shadow-sm overflow-hidden">
            {/* Tab bar */}
            <div className="flex overflow-x-auto border-b border-gray-200">
              {tabs.map((tab) => {
                const active = activeTab === tab.key;
                return (
                  <button
                    key={tab.key}
                    onClick={() => setActiveTab(tab.key)}
                    className={`flex items-center gap-2 px-5 py-4 text-sm whitespace-nowrap border-b-2 transition-colors ${
                      active
                        ? "border-violet-600 text-violet-700 font-medium"
                        : "border-transparent text-gray-500 hover:text-gray-700"
                    }`}
                  >
                    <span className={active ? "text-violet-600" : "text-gray-400"}>{tab.icon}</span>
                    {tab.label}
                    {tab.badge ? (
                      <span className="ml-1 bg-orange-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center font-medium">
                        {tab.badge}
                      </span>
                    ) : null}
                  </button>
                );
              })}
            </div>

            {/* Tab content */}
            <div className="p-6">
              {activeTab === "labApprovals" && (
                <LabApprovalsTab
                  labs={filteredLabs}
                  statusFilter={labStatusFilter}
                  searchQuery={labSearch}
                  updatingLabId={updatingLabId}
                  expandedLabId={expandedLabId}
                  onStatusFilterChange={setLabStatusFilter}
                  onSearchChange={setLabSearch}
                  onToggleExpand={(id) => setExpandedLabId((prev) => (prev === id ? null : id))}
                  onStatusUpdate={handleStatusUpdate}
                />
              )}
              {activeTab === "userManagement" && (
                <UserManagementTab
                  patients={filteredPatients}
                  searchQuery={userSearch}
                  onSearchChange={setUserSearch}
                />
              )}
              {activeTab === "allBookings" && <AllBookingsTab bookings={paymentRows} />}
              {activeTab === "analytics" && <AnalyticsTab topLabs={topLabs} topTests={topTests} />}
              {activeTab === "security" && (
                <SecurityTab
                  twoFaEnabled={twoFaEnabled}
                  onToggleTwoFa={() => setTwoFaEnabled((v) => !v)}
                  rateLimitEnabled={rateLimitEnabled}
                  onToggleRateLimit={() => setRateLimitEnabled((v) => !v)}
                />
              )}
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

/* ─────────────────────────────── Sub-components ─────────────────────────────── */

function StatCard({ label, value, highlight }: { label: string; value: number | string; highlight?: boolean }) {
  return (
    <div className={`bg-white rounded-xl p-5 shadow-sm border ${highlight ? "border-orange-300" : "border-gray-200"}`}>
      <p className="text-sm text-gray-500 mb-1">{label}</p>
      <p className={`text-3xl font-bold ${highlight ? "text-orange-500" : "text-gray-900"}`}>{value}</p>
    </div>
  );
}

function Toggle({ enabled, onToggle }: { enabled: boolean; onToggle: () => void }) {
  return (
    <button
      onClick={onToggle}
      className={`relative inline-flex h-6 w-11 shrink-0 items-center rounded-full transition-colors ${
        enabled ? "bg-violet-600" : "bg-gray-200"
      }`}
    >
      <span
        className={`inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform ${
          enabled ? "translate-x-6" : "translate-x-1"
        }`}
      />
    </button>
  );
}

function LabStatusBadge({ status }: { status: AdminLabOnboardingStatus }) {
  const map: Record<AdminLabOnboardingStatus, string> = {
    PendingReview: "bg-orange-100 text-orange-600",
    Active: "bg-green-100 text-green-700",
    Rejected: "bg-red-100 text-red-700",
    Suspended: "bg-gray-100 text-gray-600",
  };
  const labels: Record<AdminLabOnboardingStatus, string> = {
    PendingReview: "Pending",
    Active: "Active",
    Rejected: "Rejected",
    Suspended: "Suspended",
  };
  return (
    <span className={`px-3 py-1 rounded-full text-sm font-medium ${map[status]}`}>
      {labels[status]}
    </span>
  );
}

function BookingStatusBadge({ status }: { status: string }) {
  const map: Record<string, string> = {
    Confirmed: "bg-blue-100 text-blue-700",
    Completed: "bg-green-100 text-green-700",
    Pending: "bg-yellow-100 text-yellow-700",
    Cancelled: "bg-gray-100 text-gray-600",
    Rejected: "bg-red-100 text-red-700",
  };
  return (
    <span className={`px-3 py-1 rounded-full text-xs font-medium ${map[status] ?? "bg-gray-100 text-gray-600"}`}>
      {status}
    </span>
  );
}

/* ── Lab Approvals Tab ── */
function LabApprovalsTab({
  labs,
  statusFilter,
  searchQuery,
  updatingLabId,
  expandedLabId,
  onStatusFilterChange,
  onSearchChange,
  onToggleExpand,
  onStatusUpdate,
}: {
  labs: AdminWorkspaceResponse["labs"];
  statusFilter: "All" | AdminLabOnboardingStatus;
  searchQuery: string;
  updatingLabId: string | null;
  expandedLabId: string | null;
  onStatusFilterChange: (f: "All" | AdminLabOnboardingStatus) => void;
  onSearchChange: (q: string) => void;
  onToggleExpand: (id: string) => void;
  onStatusUpdate: (id: string, status: AdminLabOnboardingStatus) => void;
}) {
  const filters: ("All" | AdminLabOnboardingStatus)[] = ["All", "PendingReview", "Active", "Rejected", "Suspended"];
  const filterLabels: Record<string, string> = {
    All: "All",
    PendingReview: "Pending",
    Active: "Active",
    Rejected: "Rejected",
    Suspended: "Suspended",
  };

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4">
        <h2 className="text-lg font-semibold text-gray-900">Pending Lab Approvals</h2>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search labs…"
            className="pl-9 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-violet-300 w-52"
          />
        </div>
      </div>

      <div className="flex flex-wrap gap-2 mb-5">
        {filters.map((f) => (
          <button
            key={f}
            onClick={() => onStatusFilterChange(f)}
            className={`px-4 py-1.5 rounded-full text-sm transition-colors ${
              statusFilter === f
                ? "bg-violet-600 text-white"
                : "border border-gray-300 text-gray-600 hover:bg-gray-50"
            }`}
          >
            {filterLabels[f]}
          </button>
        ))}
      </div>

      {labs.length === 0 ? (
        <div className="border border-dashed border-gray-300 rounded-xl p-10 text-center text-gray-400">
          No labs match the current filters.
        </div>
      ) : (
        <div className="space-y-4">
          {labs.map((lab) => {
            const isPending = lab.onboardingStatus === "PendingReview";
            const isExpanded = expandedLabId === lab.id;
            return (
              <div
                key={lab.id}
                className={`rounded-xl border p-5 transition-colors ${
                  isPending ? "border-orange-200 bg-orange-50/40" : "border-gray-200 bg-white"
                }`}
              >
                <div className="flex items-start justify-between mb-3">
                  <h3 className="text-base font-semibold text-gray-900">{lab.labName}</h3>
                  <LabStatusBadge status={lab.onboardingStatus} />
                </div>

                <div className="text-sm text-gray-600 space-y-0.5 mb-4">
                  <p>Email: {lab.email}</p>
                  <p>Phone: {lab.phone || "Not provided"}</p>
                  <p>Address: {lab.address}</p>
                  <p>Accreditation: {lab.accreditation || "Not provided"}</p>
                  <p className="text-gray-400 text-xs mt-1">Submitted: {formatDate(lab.createdAt)}</p>
                </div>

                <div className="flex flex-wrap gap-3">
                  {lab.onboardingStatus !== "Active" && (
                    <button
                      onClick={() => onStatusUpdate(lab.id, "Active")}
                      disabled={!lab.onboardingReadiness.isReady || updatingLabId === lab.id}
                      className="flex items-center gap-1.5 bg-green-600 hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                    >
                      <CheckCircle className="w-4 h-4" />
                      Approve Lab
                    </button>
                  )}
                  {lab.onboardingStatus !== "Rejected" && (
                    <button
                      onClick={() => onStatusUpdate(lab.id, "Rejected")}
                      disabled={updatingLabId === lab.id}
                      className="flex items-center gap-1.5 bg-red-600 hover:bg-red-700 disabled:opacity-50 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                    >
                      <XCircle className="w-4 h-4" />
                      Reject
                    </button>
                  )}
                  <button
                    onClick={() => onToggleExpand(lab.id)}
                    className="flex items-center gap-1.5 border border-gray-300 text-gray-700 hover:bg-gray-50 px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                  >
                    <Eye className="w-4 h-4" />
                    {isExpanded ? "Hide Details" : "View Details"}
                  </button>
                </div>

                {isExpanded && (
                  <div className="mt-4 pt-4 border-t border-gray-200 space-y-3">
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
                      {[
                        ["Tests", lab.testsCount],
                        ["Bookings", lab.bookingsCount],
                        ["Schedule Slots", lab.scheduleSlotsCount],
                        ["Rating", lab.ratingAverage ? `${lab.ratingAverage.toFixed(1)} (${lab.reviewCount})` : "—"],
                      ].map(([label, val]) => (
                        <div key={String(label)} className="bg-gray-50 rounded-lg p-3">
                          <p className="text-gray-400 text-xs">{label}</p>
                          <p className="text-gray-900 font-medium mt-0.5">{val}</p>
                        </div>
                      ))}
                    </div>
                    <div className={`rounded-lg p-3 text-sm ${lab.onboardingReadiness.isReady ? "bg-green-50 text-green-700" : "bg-orange-50 text-orange-700"}`}>
                      Onboarding: {lab.onboardingReadiness.completedRequirements}/{lab.onboardingReadiness.totalRequirements} requirements
                      {lab.onboardingReadiness.missingRequirements.length > 0 && (
                        <span className="ml-2 text-xs">— missing: {lab.onboardingReadiness.missingRequirements.join(", ")}</span>
                      )}
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

/* ── User Management Tab ── */
function UserManagementTab({
  patients,
  searchQuery,
  onSearchChange,
}: {
  patients: { name: string | null; email: string; bookings: number; joined: string }[];
  searchQuery: string;
  onSearchChange: (q: string) => void;
}) {
  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-5">
        <h2 className="text-lg font-semibold text-gray-900">User Management</h2>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search users…"
            className="pl-9 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-violet-300 w-52"
          />
        </div>
      </div>

      {patients.length === 0 ? (
        <p className="text-gray-400 text-sm py-8 text-center">No patient data available yet.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-200 text-left text-gray-700 font-semibold">
                <th className="pb-3 pr-4">Name</th>
                <th className="pb-3 pr-4">Email</th>
                <th className="pb-3 pr-4">Role</th>
                <th className="pb-3 pr-4">Bookings</th>
                <th className="pb-3 pr-4">Status</th>
                <th className="pb-3 pr-4">Joined</th>
                <th className="pb-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {patients.map((p) => (
                <tr key={p.email} className="border-b border-gray-100 text-gray-800">
                  <td className="py-3 pr-4 font-medium">{p.name ?? "—"}</td>
                  <td className="py-3 pr-4 text-gray-600">{p.email}</td>
                  <td className="py-3 pr-4">Patient</td>
                  <td className="py-3 pr-4">{p.bookings}</td>
                  <td className="py-3 pr-4">
                    <span className="bg-green-100 text-green-700 px-2.5 py-1 rounded-full text-xs font-medium">
                      Active
                    </span>
                  </td>
                  <td className="py-3 pr-4 text-gray-500">{formatDate(p.joined)}</td>
                  <td className="py-3">
                    <button className="text-blue-600 hover:text-blue-800 text-sm font-medium">View</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

/* ── All Bookings Tab ── */
function AllBookingsTab({ bookings }: { bookings: AdminPaymentRecord[] }) {
  return (
    <div>
      <h2 className="text-lg font-semibold text-gray-900 mb-5">All Platform Bookings</h2>
      {bookings.length === 0 ? (
        <p className="text-gray-400 text-sm py-8 text-center">No booking records yet.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-200 text-left text-gray-700 font-semibold">
                <th className="pb-3 pr-4">Booking ID</th>
                <th className="pb-3 pr-4">Patient</th>
                <th className="pb-3 pr-4">Lab</th>
                <th className="pb-3 pr-4">Test</th>
                <th className="pb-3 pr-4">Date</th>
                <th className="pb-3 pr-4">Status</th>
                <th className="pb-3">Amount</th>
              </tr>
            </thead>
            <tbody>
              {bookings.map((row, i) => (
                <tr key={row.bookingId} className="border-b border-gray-100 text-gray-800">
                  <td className="py-3 pr-4 text-gray-500">#{String(i + 1).padStart(6, "0")}</td>
                  <td className="py-3 pr-4">{row.patientName ?? row.patientEmail}</td>
                  <td className="py-3 pr-4 text-gray-600">{row.labName}</td>
                  <td className="py-3 pr-4 text-gray-600">{row.testName}</td>
                  <td className="py-3 pr-4 text-gray-500">{formatDate(row.scheduledAt || row.createdAt)}</td>
                  <td className="py-3 pr-4">
                    <BookingStatusBadge status={row.bookingStatus} />
                  </td>
                  <td className="py-3 font-medium">EGP {row.totalPriceEgp}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

/* ── Analytics Tab ── */
function AnalyticsTab({
  topLabs,
  topTests,
}: {
  topLabs: { name: string; bookings: number; revenue: number }[];
  topTests: { name: string; count: number }[];
}) {
  return (
    <div>
      <h2 className="text-lg font-semibold text-gray-900 mb-5">Platform Analytics</h2>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="border border-gray-200 rounded-xl p-5">
          <h3 className="font-semibold text-gray-900 mb-4">Top Performing Labs</h3>
          {topLabs.length === 0 ? (
            <p className="text-gray-400 text-sm">No booking data yet.</p>
          ) : (
            <div className="space-y-4">
              {topLabs.map((lab) => (
                <div key={lab.name} className="flex items-start justify-between">
                  <div>
                    <p className="text-gray-900 font-medium">{lab.name}</p>
                    <p className="text-xs text-gray-400">{lab.bookings} bookings</p>
                  </div>
                  <span className="text-green-600 font-semibold">EGP {lab.revenue.toLocaleString()}</span>
                </div>
              ))}
            </div>
          )}
        </div>
        <div className="border border-gray-200 rounded-xl p-5">
          <h3 className="font-semibold text-gray-900 mb-4">Most Popular Tests</h3>
          {topTests.length === 0 ? (
            <p className="text-gray-400 text-sm">No booking data yet.</p>
          ) : (
            <div className="space-y-4">
              {topTests.map((test) => (
                <div key={test.name} className="flex items-center justify-between">
                  <p className="text-gray-900">{test.name}</p>
                  <span className="text-blue-600 font-semibold">{test.count} tests</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

/* ── Security Tab ── */
function SecurityTab({
  twoFaEnabled,
  onToggleTwoFa,
  rateLimitEnabled,
  onToggleRateLimit,
}: {
  twoFaEnabled: boolean;
  onToggleTwoFa: () => void;
  rateLimitEnabled: boolean;
  onToggleRateLimit: () => void;
}) {
  return (
    <div>
      <h2 className="text-lg font-semibold text-gray-900 mb-5">Security Settings</h2>
      <div className="space-y-4">
        {/* 2FA */}
        <div className="border border-gray-200 rounded-xl p-5 flex items-center justify-between">
          <div>
            <p className="font-semibold text-gray-900">Two-Factor Authentication</p>
            <p className="text-sm text-gray-500 mt-0.5">Require 2FA for all admin accounts</p>
          </div>
          <Toggle enabled={twoFaEnabled} onToggle={onToggleTwoFa} />
        </div>

        {/* Data Encryption */}
        <div className="border border-gray-200 rounded-xl p-5">
          <p className="font-semibold text-gray-900">Data Encryption</p>
          <p className="text-sm text-gray-500 mt-0.5">AES-256 encryption for all sensitive data</p>
          <div className="flex items-center gap-1.5 mt-2">
            <CheckCircle className="w-4 h-4 text-green-500" />
            <span className="text-green-600 text-sm font-medium">Enabled</span>
          </div>
        </div>

        {/* Rate Limiting */}
        <div className="border border-gray-200 rounded-xl p-5 flex items-center justify-between">
          <div>
            <p className="font-semibold text-gray-900">Rate Limiting</p>
            <p className="text-sm text-gray-500 mt-0.5">Protect against brute force attacks</p>
          </div>
          <Toggle enabled={rateLimitEnabled} onToggle={onToggleRateLimit} />
        </div>

        {/* OWASP */}
        <div className="border border-orange-200 bg-orange-50 rounded-xl p-5">
          <div className="flex items-center gap-2 mb-1">
            <AlertTriangle className="w-4 h-4 text-orange-500" />
            <p className="font-semibold text-gray-900">OWASP Protection</p>
          </div>
          <p className="text-sm text-gray-600 mb-3">
            Active protection against SQL Injection, XSS, CSRF, and other OWASP Top 10 vulnerabilities
          </p>
          <button className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
            View Security Logs
          </button>
        </div>

        {/* Encrypted Backups */}
        <div className="border border-gray-200 rounded-xl p-5">
          <p className="font-semibold text-gray-900 mb-3">Encrypted Backups</p>
          <div className="space-y-2 text-sm">
            {[
              ["Last Backup", "—"],
              ["Backup Frequency", "Daily"],
            ].map(([label, val]) => (
              <div key={label} className="flex justify-between">
                <span className="text-gray-500">{label}</span>
                <span className="text-gray-900">{val}</span>
              </div>
            ))}
            <div className="flex justify-between">
              <span className="text-gray-500">Encryption Status</span>
              <span className="flex items-center gap-1 text-green-600 font-medium">
                <CheckCircle className="w-3.5 h-3.5" />
                Encrypted (AES-256)
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
