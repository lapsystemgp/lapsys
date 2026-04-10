"use client";

import { ArrowLeft } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { ApiError } from "../../../lib/api";
import { setLabBookingStatus } from "../../../lib/bookingsApi";
import {
  createLabTest,
  deleteLabTest,
  createScheduleSlot,
  deactivateScheduleSlot,
  fetchLabWorkspace,
  setLabResultStatus,
  updateLabTest,
  type LabWorkspaceResponse,
  uploadLabResult,
} from "../../../lib/labApi";
import { useSession } from "../../../components/SessionProvider";

type Tab = "bookings" | "tests" | "results" | "schedule" | "analytics";

function formatDateTime(value: string) {
  const date = new Date(value);
  return date.toLocaleString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function statusClass(status: string) {
  if (status === "Confirmed") return "bg-green-100 text-green-700";
  if (status === "Pending") return "bg-yellow-100 text-yellow-700";
  if (status === "Cancelled") return "bg-gray-100 text-gray-700";
  if (status === "Rejected") return "bg-red-100 text-red-700";
  if (status === "Completed") return "bg-blue-100 text-blue-700";
  return "bg-gray-100 text-gray-700";
}

export default function LabDashboardPage() {
  const router = useRouter();
  const { user, logout } = useSession();

  const [tab, setTab] = useState<Tab>("bookings");
  const [workspace, setWorkspace] = useState<LabWorkspaceResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [newTest, setNewTest] = useState({ name: "", category: "", priceEgp: "" });
  const [editingTestId, setEditingTestId] = useState<string | null>(null);
  const [editingTest, setEditingTest] = useState({ name: "", category: "", priceEgp: "" });
  const [newSlot, setNewSlot] = useState({ startsAt: "", endsAt: "", capacity: "1" });
  const [uploadState, setUploadState] = useState<Record<string, { summary: string; file: File | null }>>({});

  const loadWorkspace = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetchLabWorkspace();
      setWorkspace(response);
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        router.push("/login");
        return;
      }
      if (err instanceof ApiError && err.status === 403) {
        router.push("/unauthorized?reason=pending_review");
        return;
      }
      setError("Unable to load lab workspace.");
    } finally {
      setLoading(false);
    }
  }, [router]);

  useEffect(() => {
    loadWorkspace();
  }, [loadWorkspace]);

  const bookingsByStatus = useMemo(() => {
    const pending = workspace?.bookings.filter((booking) => booking.status === "Pending") ?? [];
    const nonPending = workspace?.bookings.filter((booking) => booking.status !== "Pending") ?? [];
    return { pending, nonPending };
  }, [workspace]);

  const handleLogout = async () => {
    await logout();
    router.push("/login");
  };

  const updateBookingStatus = async (bookingId: string, status: "Confirmed" | "Rejected") => {
    try {
      await setLabBookingStatus(bookingId, status);
      await loadWorkspace();
    } catch {
      setError("Could not update booking status.");
    }
  };

  const handleCreateTest = async () => {
    if (!newTest.name.trim() || !newTest.category.trim() || !newTest.priceEgp.trim()) return;
    try {
      await createLabTest({
        name: newTest.name,
        category: newTest.category,
        priceEgp: Number(newTest.priceEgp),
      });
      setNewTest({ name: "", category: "", priceEgp: "" });
      await loadWorkspace();
    } catch {
      setError("Could not create test.");
    }
  };

  const handleToggleTest = async (testId: string, isActive: boolean) => {
    try {
      await updateLabTest(testId, { isActive: !isActive });
      await loadWorkspace();
    } catch {
      setError("Could not update test state.");
    }
  };

  const startEditingTest = (test: LabWorkspaceResponse["tests"][number]) => {
    setEditingTestId(test.id);
    setEditingTest({
      name: test.name,
      category: test.category,
      priceEgp: String(test.priceEgp),
    });
  };

  const handleSaveTest = async () => {
    if (!editingTestId) return;
    try {
      await updateLabTest(editingTestId, {
        name: editingTest.name.trim(),
        category: editingTest.category.trim(),
        priceEgp: Number(editingTest.priceEgp),
      });
      setEditingTestId(null);
      setEditingTest({ name: "", category: "", priceEgp: "" });
      await loadWorkspace();
    } catch {
      setError("Could not update test.");
    }
  };

  const handleDeleteTest = async (testId: string) => {
    try {
      await deleteLabTest(testId);
      if (editingTestId === testId) {
        setEditingTestId(null);
        setEditingTest({ name: "", category: "", priceEgp: "" });
      }
      await loadWorkspace();
    } catch (err) {
      if (err instanceof ApiError && err.status === 400) {
        setError("Cannot delete a test that already has bookings.");
        return;
      }
      setError("Could not delete test.");
    }
  };

  const handleCreateSlot = async () => {
    if (!newSlot.startsAt || !newSlot.endsAt) return;
    try {
      await createScheduleSlot({
        startsAt: new Date(newSlot.startsAt).toISOString(),
        endsAt: new Date(newSlot.endsAt).toISOString(),
        capacity: Number(newSlot.capacity) || 1,
      });
      setNewSlot({ startsAt: "", endsAt: "", capacity: "1" });
      await loadWorkspace();
    } catch {
      setError("Could not create schedule slot.");
    }
  };

  const handleDeactivateSlot = async (slotId: string) => {
    try {
      await deactivateScheduleSlot(slotId);
      await loadWorkspace();
    } catch {
      setError("Could not deactivate slot.");
    }
  };

  const handleUploadResult = async (bookingId: string) => {
    const state = uploadState[bookingId];
    if (!state?.file || !state.summary.trim()) {
      setError("Select PDF and summary before upload.");
      return;
    }
    try {
      await uploadLabResult(bookingId, {
        file: state.file,
        summary: state.summary,
      });
      setUploadState((prev) => ({ ...prev, [bookingId]: { summary: "", file: null } }));
      await loadWorkspace();
    } catch {
      setError("Could not upload result.");
    }
  };

  const handleDeliverResult = async (bookingId: string) => {
    try {
      await setLabResultStatus(bookingId, "Delivered");
      await loadWorkspace();
    } catch (err) {
      if (err instanceof ApiError && err.status === 400) {
        setError("Upload the result PDF first, then mark it as delivered.");
        return;
      }
      setError("Could not mark result as delivered.");
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="space-y-2">
            <button
              onClick={() => router.push("/")}
              className="flex items-center gap-2 text-sm text-gray-600 hover:text-gray-900"
            >
              <ArrowLeft className="w-4 h-4" />
              Back to Home
            </button>
            <h1 className="text-2xl text-gray-900">Lab Workspace</h1>
            <p className="text-gray-600">{workspace?.lab.name || user?.lab_profile?.lab_name || user?.email}</p>
          </div>
          <button onClick={handleLogout} className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
            Logout
          </button>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-8">
        <div className="flex gap-2 mb-6 flex-wrap">
          {(["bookings", "tests", "results", "schedule", "analytics"] as Tab[]).map((item) => (
            <button
              key={item}
              onClick={() => setTab(item)}
              className={`px-4 py-2 rounded-lg capitalize ${tab === item ? "bg-blue-600 text-white" : "bg-white border border-gray-200"}`}
            >
              {item}
            </button>
          ))}
        </div>

        {error && <p className="text-red-600 mb-4">{error}</p>}

        {loading || !workspace ? (
          <p>Loading lab workspace...</p>
        ) : (
          <>
            {tab === "bookings" && (
              <div className="space-y-4">
                {[...bookingsByStatus.pending, ...bookingsByStatus.nonPending].map((booking) => (
                  <div key={booking.id} className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <h2 className="text-lg text-gray-900">{booking.patient.fullName || "Patient"}</h2>
                        <p className="text-gray-600">{booking.test.name}</p>
                        <p className="text-gray-500">{formatDateTime(booking.scheduledAt)}</p>
                      </div>
                      <span className={`px-3 py-1 rounded-full ${statusClass(booking.status)}`}>{booking.status}</span>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-4 gap-3 text-sm text-gray-700">
                      <div>
                        <p className="text-gray-500">Type</p>
                        <p>{booking.bookingType === "HomeCollection" ? "Home Collection" : "Lab Visit"}</p>
                      </div>
                      <div>
                        <p className="text-gray-500">Phone</p>
                        <p>{booking.patient.phone || "-"}</p>
                      </div>
                      <div>
                        <p className="text-gray-500">Address</p>
                        <p>{booking.homeAddress || workspace.lab.address}</p>
                      </div>
                      <div>
                        <p className="text-gray-500">Amount</p>
                        <p>EGP {booking.totalPriceEgp}</p>
                      </div>
                    </div>
                    {booking.status === "Pending" && (
                      <div className="mt-4 flex gap-2">
                        <button onClick={() => updateBookingStatus(booking.id, "Confirmed")} className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700">
                          Confirm
                        </button>
                        <button onClick={() => updateBookingStatus(booking.id, "Rejected")} className="px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50">
                          Reject
                        </button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}

            {tab === "tests" && (
              <div className="space-y-4">
                <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
                  <h2 className="text-lg text-gray-900 mb-3">Add Test</h2>
                  <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
                    <input value={newTest.name} onChange={(e) => setNewTest((p) => ({ ...p, name: e.target.value }))} placeholder="Test name" className="px-3 py-2 border border-gray-300 rounded-lg" />
                    <input value={newTest.category} onChange={(e) => setNewTest((p) => ({ ...p, category: e.target.value }))} placeholder="Category" className="px-3 py-2 border border-gray-300 rounded-lg" />
                    <input value={newTest.priceEgp} onChange={(e) => setNewTest((p) => ({ ...p, priceEgp: e.target.value }))} placeholder="Price EGP" type="number" className="px-3 py-2 border border-gray-300 rounded-lg" />
                    <button onClick={handleCreateTest} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Create</button>
                  </div>
                </div>
                <div className="space-y-3">
                  {workspace.tests.map((test) => (
                    <div key={test.id} className="bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
                      {editingTestId === test.id ? (
                        <div className="grid grid-cols-1 md:grid-cols-5 gap-3 items-center">
                          <input
                            value={editingTest.name}
                            onChange={(e) => setEditingTest((prev) => ({ ...prev, name: e.target.value }))}
                            className="px-3 py-2 border border-gray-300 rounded-lg"
                            placeholder="Test name"
                          />
                          <input
                            value={editingTest.category}
                            onChange={(e) => setEditingTest((prev) => ({ ...prev, category: e.target.value }))}
                            className="px-3 py-2 border border-gray-300 rounded-lg"
                            placeholder="Category"
                          />
                          <input
                            type="number"
                            value={editingTest.priceEgp}
                            onChange={(e) => setEditingTest((prev) => ({ ...prev, priceEgp: e.target.value }))}
                            className="px-3 py-2 border border-gray-300 rounded-lg"
                            placeholder="Price EGP"
                          />
                          <button onClick={handleSaveTest} className="px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                            Save
                          </button>
                          <button
                            onClick={() => {
                              setEditingTestId(null);
                              setEditingTest({ name: "", category: "", priceEgp: "" });
                            }}
                            className="px-3 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                          >
                            Cancel
                          </button>
                        </div>
                      ) : (
                        <div className="flex items-center justify-between gap-4">
                          <div>
                            <p className="text-gray-900">{test.name}</p>
                            <p className="text-sm text-gray-600">{test.category} - EGP {test.priceEgp}</p>
                          </div>
                          <div className="flex gap-2">
                            <button
                              onClick={() => startEditingTest(test)}
                              className="px-3 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                            >
                              Edit
                            </button>
                            <button
                              onClick={() => handleDeleteTest(test.id)}
                              className="px-3 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50"
                            >
                              Delete
                            </button>
                            <button onClick={() => handleToggleTest(test.id, test.isActive)} className={`px-3 py-2 rounded-lg ${test.isActive ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-700"}`}>
                              {test.isActive ? "Active" : "Inactive"}
                            </button>
                          </div>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {tab === "results" && (
              <div className="space-y-4">
                {workspace.bookings
                  .filter((booking) => booking.status === "Confirmed" || booking.status === "Completed")
                  .map((booking) => {
                    const state = uploadState[booking.id] ?? { summary: "", file: null };
                    return (
                      <div key={booking.id} className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
                        <h2 className="text-lg text-gray-900">{booking.test.name}</h2>
                        <p className="text-sm text-gray-600 mb-3">Patient: {booking.patient.fullName || "Patient"}</p>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                          <input
                            type="file"
                            accept="application/pdf"
                            onChange={(event) =>
                              setUploadState((prev) => ({
                                ...prev,
                                [booking.id]: { summary: state.summary, file: event.target.files?.[0] || null },
                              }))
                            }
                            className="px-3 py-2 border border-gray-300 rounded-lg"
                          />
                          <input
                            value={state.summary}
                            onChange={(event) =>
                              setUploadState((prev) => ({
                                ...prev,
                                [booking.id]: { summary: event.target.value, file: state.file },
                              }))
                            }
                            placeholder="Result summary"
                            className="px-3 py-2 border border-gray-300 rounded-lg"
                          />
                          <button onClick={() => handleUploadResult(booking.id)} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                            Upload Result
                          </button>
                          <button
                            onClick={() => handleDeliverResult(booking.id)}
                            className="px-4 py-2 border border-green-300 text-green-700 rounded-lg hover:bg-green-50"
                          >
                            Mark Delivered
                          </button>
                        </div>
                      </div>
                    );
                  })}
              </div>
            )}

            {tab === "schedule" && (
              <div className="space-y-4">
                <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
                  <h2 className="text-lg text-gray-900 mb-3">Add Slot</h2>
                  <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
                    <input type="datetime-local" value={newSlot.startsAt} onChange={(e) => setNewSlot((p) => ({ ...p, startsAt: e.target.value }))} className="px-3 py-2 border border-gray-300 rounded-lg" />
                    <input type="datetime-local" value={newSlot.endsAt} onChange={(e) => setNewSlot((p) => ({ ...p, endsAt: e.target.value }))} className="px-3 py-2 border border-gray-300 rounded-lg" />
                    <input type="number" min={1} value={newSlot.capacity} onChange={(e) => setNewSlot((p) => ({ ...p, capacity: e.target.value }))} className="px-3 py-2 border border-gray-300 rounded-lg" />
                    <button onClick={handleCreateSlot} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Create Slot</button>
                  </div>
                </div>
                <div className="space-y-3">
                  {workspace.schedule.map((slot) => (
                    <div key={slot.id} className="bg-white rounded-xl border border-gray-200 p-4 shadow-sm flex items-center justify-between gap-4">
                      <div>
                        <p className="text-gray-900">{formatDateTime(slot.startsAt)} - {formatDateTime(slot.endsAt)}</p>
                        <p className="text-sm text-gray-600">Capacity: {slot.capacity}</p>
                      </div>
                      <button onClick={() => handleDeactivateSlot(slot.id)} className="px-3 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50">
                        Deactivate
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {tab === "analytics" && (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
                  <p className="text-gray-500">Total Bookings</p>
                  <p className="text-3xl text-gray-900">{workspace.analytics.totalBookings}</p>
                </div>
                <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
                  <p className="text-gray-500">Completed</p>
                  <p className="text-3xl text-gray-900">{workspace.analytics.completedBookings}</p>
                </div>
                <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
                  <p className="text-gray-500">Pending Results</p>
                  <p className="text-3xl text-gray-900">{workspace.analytics.pendingResults}</p>
                </div>
                <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
                  <p className="text-gray-500">Revenue Estimate</p>
                  <p className="text-3xl text-gray-900">EGP {workspace.analytics.revenueEstimateEgp}</p>
                </div>
                <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm md:col-span-2 lg:col-span-4">
                  <p className="text-gray-500 mb-2">Capacity Usage</p>
                  <p className="text-2xl text-gray-900">{workspace.analytics.capacityUsagePercent}%</p>
                </div>
                <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm md:col-span-2 lg:col-span-4">
                  <p className="text-gray-500 mb-2">Top Tests</p>
                  <div className="space-y-2">
                    {workspace.analytics.topTests.map((test) => (
                      <p key={test.testId} className="text-gray-900">{test.testName}: {test.count}</p>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
