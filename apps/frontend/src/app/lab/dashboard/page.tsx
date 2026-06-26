"use client";

import { ArrowLeft, Star, MessageSquare } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Breadcrumb } from "../../../components/Breadcrumb";
import { API_BASE_URL, ApiError } from "../../../lib/api";
import { markCashCollected, setLabBookingStatus, updateKitStatus, type KitStatus } from "../../../lib/bookingsApi";
import {
  createLabTest,
  deleteLabTest,
  createScheduleSlot,
  deactivateScheduleSlot,
  fetchLabPatientContext,
  fetchLabWorkspace,
  setLabResultStatus,
  updateLabProfile,
  updateLabTest,
  type LabPatientContextResponse,
  type LabWorkspaceResponse,
  uploadLabResult,
} from "../../../lib/labApi";
import { fetchPublicLabDetail, type PublicReview } from "../../../lib/publicApi";
import { useSession } from "../../../components/SessionProvider";
import { useToast } from "../../../components/ToastProvider";

type Tab = "bookings" | "tests" | "results" | "schedule" | "analytics" | "reviews" | "settings";

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

function resolveLabPdfUrl(fileUrl: string) {
  return `${API_BASE_URL}${fileUrl.startsWith("/") ? "" : "/"}${fileUrl}`;
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

  const toast = useToast();
  const [tab, setTab] = useState<Tab>("bookings");
  const [workspace, setWorkspace] = useState<LabWorkspaceResponse | null>(null);
  const [loading, setLoading] = useState(true);

  const [newTest, setNewTest] = useState({ name: "", category: "", priceEgp: "" });
  const [editingTestId, setEditingTestId] = useState<string | null>(null);
  const [editingTest, setEditingTest] = useState({ name: "", category: "", priceEgp: "" });
  const [newSlot, setNewSlot] = useState({ startsAt: "", endsAt: "", capacity: "1" });
  const [uploadState, setUploadState] = useState<Record<string, { summary: string; file: File | null }>>({});

  const [uploadingIds, setUploadingIds] = useState<Set<string>>(new Set());
  const [creatingTest, setCreatingTest] = useState(false);
  const [deletingTestId, setDeletingTestId] = useState<string | null>(null);
  const [togglingTestId, setTogglingTestId] = useState<string | null>(null);
  const [creatingSlot, setCreatingSlot] = useState(false);
  const [deactivatingSlotId, setDeactivatingSlotId] = useState<string | null>(null);
  const [cashActionId, setCashActionId] = useState<string | null>(null);
  const [kitActionId, setKitActionId] = useState<string | null>(null);
  const [kitTrackingInputs, setKitTrackingInputs] = useState<Record<string, string>>({});
  const [savingProfile, setSavingProfile] = useState(false);

  const [patientContext, setPatientContext] = useState<LabPatientContextResponse | null>(null);
  const [patientContextLoading, setPatientContextLoading] = useState(false);
  const [reviewItems, setReviewItems] = useState<PublicReview[]>([]);
  const [reviewsLoading, setReviewsLoading] = useState(false);
  const [reviewsLabId, setReviewsLabId] = useState<string | null>(null);

  const loadWorkspace = useCallback(async () => {
    setLoading(true);
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
      toast.error("Unable to load lab workspace.");
    } finally {
      setLoading(false);
    }
  }, [router, toast]);

  useEffect(() => {
    loadWorkspace();
  }, [loadWorkspace]);

  useEffect(() => {
    if (tab !== "reviews" || !workspace?.lab.id) return;
    if (reviewsLabId === workspace.lab.id) return;
    setReviewsLoading(true);
    fetchPublicLabDetail(workspace.lab.id)
      .then((res) => {
        setReviewItems(res.reviewItems ?? []);
        setReviewsLabId(workspace.lab.id);
      })
      .catch(() => { toast.error("Could not load reviews."); })
      .finally(() => setReviewsLoading(false));
  }, [tab, workspace?.lab.id, reviewsLabId]);

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
      toast.success(status === "Confirmed" ? "Booking confirmed." : "Booking rejected.");
    } catch {
      toast.error("Could not update booking status.");
    }
  };

  const handleMarkCash = async (bookingId: string) => {
    setCashActionId(bookingId);
    try {
      await markCashCollected(bookingId);
      await loadWorkspace();
      toast.success("Cash payment recorded.");
    } catch {
      toast.error("Could not record cash payment.");
    } finally {
      setCashActionId(null);
    }
  };

  const formatPaymentMethod = (method: string) => {
    if (method === "Online") return "Online (demo)";
    if (method === "CashHomeCollection") return "Cash on collection";
    if (method === "CashLabVisit") return "Cash at lab visit";
    if (method === "CashOnDelivery") return "Cash on delivery";
    return method;
  };

  const handleKitStatus = async (bookingId: string, kitStatus: KitStatus, trackingNumber?: string) => {
    setKitActionId(bookingId);
    try {
      await updateKitStatus(bookingId, kitStatus, trackingNumber);
      await loadWorkspace();
      const label = kitStatus === "Shipped" ? "Kit marked as shipped." : kitStatus === "Delivered" ? "Kit marked as delivered." : "Sample received.";
      toast.success(label);
    } catch {
      toast.error("Could not update kit status.");
    } finally {
      setKitActionId(null);
    }
  };

  const handleToggleHomeTestKit = async (current: boolean) => {
    setSavingProfile(true);
    try {
      await updateLabProfile({ homeTestKit: !current });
      await loadWorkspace();
      toast.success(`Home test kits ${!current ? "enabled" : "disabled"}.`);
    } catch {
      toast.error("Could not update lab profile.");
    } finally {
      setSavingProfile(false);
    }
  };

  const handleCreateTest = async () => {
    if (!newTest.name.trim() || !newTest.category.trim() || !newTest.priceEgp.trim()) return;
    setCreatingTest(true);
    try {
      await createLabTest({
        name: newTest.name,
        category: newTest.category,
        priceEgp: Number(newTest.priceEgp),
      });
      setNewTest({ name: "", category: "", priceEgp: "" });
      await loadWorkspace();
      toast.success("Test created.");
    } catch {
      toast.error("Could not create test.");
    } finally {
      setCreatingTest(false);
    }
  };

  const handleToggleTest = async (testId: string, isActive: boolean) => {
    setTogglingTestId(testId);
    try {
      await updateLabTest(testId, { isActive: !isActive });
      await loadWorkspace();
      toast.success(isActive ? "Test deactivated." : "Test activated.");
    } catch {
      toast.error("Could not update test state.");
    } finally {
      setTogglingTestId(null);
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
      toast.success("Test saved.");
    } catch {
      toast.error("Could not update test.");
    }
  };

  const handleDeleteTest = async (testId: string) => {
    setDeletingTestId(testId);
    try {
      await deleteLabTest(testId);
      if (editingTestId === testId) {
        setEditingTestId(null);
        setEditingTest({ name: "", category: "", priceEgp: "" });
      }
      await loadWorkspace();
      toast.success("Test deleted.");
    } catch (err) {
      if (err instanceof ApiError && err.status === 400) {
        toast.error("Cannot delete a test that already has bookings.");
        return;
      }
      toast.error("Could not delete test.");
    } finally {
      setDeletingTestId(null);
    }
  };

  const handleCreateSlot = async () => {
    if (!newSlot.startsAt || !newSlot.endsAt) return;
    setCreatingSlot(true);
    try {
      await createScheduleSlot({
        startsAt: new Date(newSlot.startsAt).toISOString(),
        endsAt: new Date(newSlot.endsAt).toISOString(),
        capacity: Number(newSlot.capacity) || 1,
      });
      setNewSlot({ startsAt: "", endsAt: "", capacity: "1" });
      await loadWorkspace();
      toast.success("Schedule slot added.");
    } catch {
      toast.error("Could not create schedule slot.");
    } finally {
      setCreatingSlot(false);
    }
  };

  const handleDeactivateSlot = async (slotId: string) => {
    setDeactivatingSlotId(slotId);
    try {
      await deactivateScheduleSlot(slotId);
      await loadWorkspace();
      toast.success("Slot deactivated.");
    } catch {
      toast.error("Could not deactivate slot.");
    } finally {
      setDeactivatingSlotId(null);
    }
  };

  const handleUploadResult = async (bookingId: string) => {
    const state = uploadState[bookingId];
    if (!state?.file || !state.summary.trim()) {
      toast.error("Select a PDF and add a summary before uploading.");
      return;
    }
    setUploadingIds((prev) => new Set(prev).add(bookingId));
    try {
      await uploadLabResult(bookingId, {
        file: state.file,
        summary: state.summary,
      });
      setUploadState((prev) => ({ ...prev, [bookingId]: { summary: "", file: null } }));
      await loadWorkspace();
      toast.success("Result uploaded.");
    } catch {
      toast.error("Could not upload result.");
    } finally {
      setUploadingIds((prev) => {
        const next = new Set(prev);
        next.delete(bookingId);
        return next;
      });
    }
  };

  const openPatientContext = async (bookingId: string) => {
    setPatientContextLoading(true);
    setPatientContext(null);
    try {
      const data = await fetchLabPatientContext({ bookingId });
      setPatientContext(data);
    } catch {
      toast.error("Could not load patient context.");
    } finally {
      setPatientContextLoading(false);
    }
  };

  const closePatientContext = () => {
    setPatientContext(null);
    setPatientContextLoading(false);
  };

  const handleDeliverResult = async (bookingId: string) => {
    try {
      await setLabResultStatus(bookingId, "Delivered");
      await loadWorkspace();
      toast.success("Result marked as delivered.");
    } catch (err) {
      if (err instanceof ApiError && err.status === 400) {
        toast.error("Upload the result PDF first, then mark it as delivered.");
        return;
      }
      toast.error("Could not mark result as delivered.");
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* 1. Header */}
      <header className="bg-white/95 backdrop-blur-sm shadow-sm border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
          <div className="space-y-1">
            {/* 2. Back to Home button */}
            <button
              onClick={() => router.push("/")}
              className="flex items-center gap-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:-translate-x-0.5 transition-all duration-150"
            >
              <ArrowLeft className="w-4 h-4" />
              Back to Home
            </button>
            {/* 3. Page title */}
            <h1 className="text-xl font-bold text-gray-900">Lab Workspace</h1>
            {/* 4. Lab name/email */}
            <p className="text-sm font-medium text-gray-500">{workspace?.lab.name || user?.lab_profile?.lab_name || user?.email}</p>
          </div>
          {/* 5. Logout button */}
          <button onClick={handleLogout} className="px-3 py-1.5 text-sm font-medium border border-gray-300 rounded-xl hover:bg-gray-50 transition-colors">
            Logout
          </button>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-5">
        <Breadcrumb items={[{ label: "Lab Dashboard" }]} className="mb-4" />
        {/* 6. Tab pill buttons */}
        <div className="flex flex-wrap gap-1.5 mb-5 p-1 bg-white border border-gray-200 rounded-xl">
          {(["bookings", "tests", "results", "schedule", "analytics", "reviews", "settings"] as Tab[]).map((item) => (
            <button
              key={item}
              onClick={() => setTab(item)}
              className={`px-4 py-1.5 rounded-lg text-sm capitalize transition-all duration-150 ${
                tab === item ? "bg-blue-600 text-white shadow-sm font-semibold" : "text-gray-600 hover:text-gray-900 hover:bg-gray-50 font-medium"
              }`}
            >
              {item}
            </button>
          ))}
        </div>

        {loading || !workspace ? (
          <div className="space-y-3">
            {/* 7. Loading skeleton cards */}
            {[0, 1].map((i) => (
              <div key={i} className={`bg-white rounded-2xl border border-gray-100 p-5 shadow-sm animate-slide-up ${i === 1 ? 'animation-delay-100' : ''}`}>
                <div className="flex items-start justify-between mb-3">
                  <div className="space-y-2">
                    <div className="skeleton h-5 w-36 rounded" />
                    <div className="skeleton h-4 w-24 rounded" />
                    <div className="skeleton h-4 w-32 rounded" />
                  </div>
                  <div className="skeleton h-6 w-20 rounded-full" />
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  {[0, 1, 2, 3].map((j) => <div key={j} className="skeleton h-10 rounded" />)}
                </div>
              </div>
            ))}
          </div>
        ) : (
          <>
            {tab === "bookings" && (
              <div key="bookings" className="space-y-3 animate-fade-in">
                {[...bookingsByStatus.pending, ...bookingsByStatus.nonPending].map((booking) => (
                  /* 8. Booking cards */
                  <div key={booking.id} className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm hover:shadow-md transition-shadow duration-200">
                    <div className="flex items-start justify-between mb-3">
                      <div>
                        {/* patient name h2 */}
                        <h2 className="text-lg font-bold text-gray-900">{booking.patient.fullName || "Patient"}</h2>
                        {/* test name p */}
                        <p className="font-medium text-gray-600">{booking.test.name}</p>
                        <p className="text-gray-500">{formatDateTime(booking.scheduledAt)}</p>
                      </div>
                      {/* status badge */}
                      <span className={`px-3 py-1 rounded-full font-medium ${statusClass(booking.status)}`}>{booking.status}</span>
                    </div>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm text-gray-700">
                      <div>
                        {/* field labels */}
                        <p className="font-medium text-gray-500">Type</p>
                        {/* field values */}
                        <p className="font-semibold">
                          {booking.bookingType === "HomeCollection"
                            ? "Home Collection"
                            : booking.bookingType === "HomeTestKit"
                              ? "Home Test Kit"
                              : "Lab Visit"}
                        </p>
                      </div>
                      <div>
                        <p className="font-medium text-gray-500">Phone</p>
                        <p className="font-semibold">{booking.patient.phone || "-"}</p>
                      </div>
                      <div>
                        <p className="font-medium text-gray-500">{booking.bookingType === "HomeTestKit" ? "Delivery Address" : "Address"}</p>
                        <p className="font-semibold">{booking.homeAddress || workspace.lab.address}</p>
                      </div>
                      <div>
                        <p className="font-medium text-gray-500">Amount</p>
                        <p className="font-semibold">EGP {booking.totalPriceEgp}</p>
                      </div>
                    </div>
                    {/* payment info div */}
                    <div className="mt-3 rounded-xl bg-slate-50 border border-slate-200 px-3 py-2 text-sm text-slate-800">
                      <span className="text-slate-500">Payment: </span>
                      {formatPaymentMethod(booking.paymentMethod)} ·{" "}
                      <span className="font-medium">{booking.paymentStatus}</span>
                      {booking.paymentMethod === "Online" && booking.paymentStatus === "Paid" && (
                        <span className="ml-2 text-emerald-700">(Prepaid — demo)</span>
                      )}
                      {(booking.paymentMethod === "CashHomeCollection" || booking.paymentMethod === "CashLabVisit" || booking.paymentMethod === "CashOnDelivery") &&
                        booking.paymentStatus === "Pending" && <span className="ml-2 text-amber-800">(Cash due)</span>}
                      {booking.paymentReference && (
                        <span className="ml-2 text-slate-600">Ref {booking.paymentReference}</span>
                      )}
                    </div>
                    {booking.status === "Pending" && (
                      <div className="mt-4 flex flex-wrap gap-2">
                        {/* Confirm button */}
                        <button
                          onClick={() => updateBookingStatus(booking.id, "Confirmed")}
                          disabled={
                            booking.paymentMethod === "Online" && booking.paymentStatus !== "Paid"
                          }
                          className="px-4 py-2 bg-green-600 text-white font-semibold rounded-xl hover:bg-green-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
                        >
                          Confirm
                        </button>
                        {/* Reject button */}
                        <button onClick={() => updateBookingStatus(booking.id, "Rejected")} className="px-4 py-2 border border-red-300 text-red-600 font-medium rounded-xl hover:bg-red-50">
                          Reject
                        </button>
                      </div>
                    )}
                    {["Pending", "Confirmed"].includes(booking.status) &&
                      (booking.paymentMethod === "CashHomeCollection" || booking.paymentMethod === "CashLabVisit" || booking.paymentMethod === "CashOnDelivery") &&
                      booking.paymentStatus === "Pending" && (
                        <div className="mt-3">
                          {/* "Record cash received" button */}
                          <button
                            onClick={() => handleMarkCash(booking.id)}
                            disabled={cashActionId === booking.id}
                            className="px-4 py-2 border border-slate-300 rounded-lg font-medium hover:bg-slate-50 disabled:opacity-50"
                          >
                            {cashActionId === booking.id ? "Recording..." : "Record cash received (demo)"}
                          </button>
                        </div>
                      )}
                    {booking.bookingType === "HomeTestKit" && booking.status === "Confirmed" && (
                      <div className="mt-3 space-y-2">
                        {booking.kitStatus === "AwaitingShipment" && (
                          <div className="flex flex-wrap gap-2 items-center">
                            <input
                              type="text"
                              placeholder="Tracking number (optional)"
                              value={kitTrackingInputs[booking.id] ?? ""}
                              onChange={(e) => setKitTrackingInputs((prev) => ({ ...prev, [booking.id]: e.target.value }))}
                              className="px-3 py-2 border border-gray-200 rounded-lg text-sm w-48"
                            />
                            {/* Kit action button — Ship Kit */}
                            <button
                              onClick={() => handleKitStatus(booking.id, "Shipped", kitTrackingInputs[booking.id])}
                              disabled={kitActionId === booking.id}
                              className="px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 disabled:opacity-50 text-sm"
                            >
                              {kitActionId === booking.id ? "Updating..." : "Ship Kit"}
                            </button>
                          </div>
                        )}
                        {booking.kitStatus === "Shipped" && (
                          // Kit action button — Mark Kit Delivered
                          <button
                            onClick={() => handleKitStatus(booking.id, "Delivered")}
                            disabled={kitActionId === booking.id}
                            className="px-4 py-2 border border-blue-300 text-blue-700 font-medium rounded-lg hover:bg-blue-50 disabled:opacity-50 text-sm"
                          >
                            {kitActionId === booking.id ? "Updating..." : "Mark Kit Delivered"}
                          </button>
                        )}
                        {booking.kitStatus === "Delivered" && (
                          // Kit action button — Mark Sample Received
                          <button
                            onClick={() => handleKitStatus(booking.id, "SampleReceived")}
                            disabled={kitActionId === booking.id}
                            className="px-4 py-2 border border-green-300 text-green-700 font-medium rounded-lg hover:bg-green-50 disabled:opacity-50 text-sm"
                          >
                            {kitActionId === booking.id ? "Updating..." : "Mark Sample Received"}
                          </button>
                        )}
                        {booking.kitStatus && (
                          <p className="text-xs text-gray-500">
                            Kit status: <span className="font-medium text-gray-700">{booking.kitStatus.replace(/([A-Z])/g, ' $1').trim()}</span>
                            {booking.kitTrackingNumber && <> · Tracking: <span className="font-mono">{booking.kitTrackingNumber}</span></>}
                          </p>
                        )}
                      </div>
                    )}
                    <div className="mt-4 pt-4 border-t border-gray-100">
                      {/* "Patient history & context" button — keep font-medium, change rounded-lg to rounded-xl */}
                      <button
                        type="button"
                        onClick={() => openPatientContext(booking.id)}
                        className="px-4 py-2 border border-blue-300 text-blue-900 rounded-xl hover:bg-blue-50 text-sm font-medium"
                      >
                        Patient history & context
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {tab === "tests" && (
              <div key="tests" className="space-y-3 animate-fade-in">
                {/* 9. "Add Test" card */}
                <div className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm">
                  {/* h2 "Add Test" */}
                  <h2 className="text-lg font-bold text-gray-900 mb-3">Add Test</h2>
                  <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3">
                    {/* input fields border-gray-200 */}
                    <input value={newTest.name} onChange={(e) => setNewTest((p) => ({ ...p, name: e.target.value }))} placeholder="Test name" className="px-3 py-2 border border-gray-200 rounded-lg" />
                    <input value={newTest.category} onChange={(e) => setNewTest((p) => ({ ...p, category: e.target.value }))} placeholder="Category" className="px-3 py-2 border border-gray-200 rounded-lg" />
                    <input value={newTest.priceEgp} onChange={(e) => setNewTest((p) => ({ ...p, priceEgp: e.target.value }))} placeholder="Price EGP" type="number" className="px-3 py-2 border border-gray-200 rounded-lg" />
                    {/* Create button */}
                    <button onClick={handleCreateTest} disabled={creatingTest} className="px-4 py-2 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 disabled:opacity-60 disabled:cursor-not-allowed">
                      {creatingTest ? "Creating…" : "Create"}
                    </button>
                  </div>
                </div>
                <div className="space-y-3">
                  {workspace.tests.map((test) => (
                    // test item cards
                    <div key={test.id} className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm">
                      {editingTestId === test.id ? (
                        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-3 items-center">
                          {/* edit input fields border-gray-200 */}
                          <input
                            value={editingTest.name}
                            onChange={(e) => setEditingTest((prev) => ({ ...prev, name: e.target.value }))}
                            className="px-3 py-2 border border-gray-200 rounded-lg"
                            placeholder="Test name"
                          />
                          <input
                            value={editingTest.category}
                            onChange={(e) => setEditingTest((prev) => ({ ...prev, category: e.target.value }))}
                            className="px-3 py-2 border border-gray-200 rounded-lg"
                            placeholder="Category"
                          />
                          <input
                            type="number"
                            value={editingTest.priceEgp}
                            onChange={(e) => setEditingTest((prev) => ({ ...prev, priceEgp: e.target.value }))}
                            className="px-3 py-2 border border-gray-200 rounded-lg"
                            placeholder="Price EGP"
                          />
                          {/* Save button */}
                          <button onClick={handleSaveTest} className="px-3 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700">
                            Save
                          </button>
                          {/* Cancel button */}
                          <button
                            onClick={() => {
                              setEditingTestId(null);
                              setEditingTest({ name: "", category: "", priceEgp: "" });
                            }}
                            className="px-3 py-2 border border-gray-200 rounded-lg font-medium hover:bg-gray-50"
                          >
                            Cancel
                          </button>
                        </div>
                      ) : (
                        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                          <div>
                            {/* test name p */}
                            <p className="font-semibold text-gray-900">{test.name}</p>
                            {/* test category-price p */}
                            <p className="text-sm font-medium text-gray-600">{test.category} - EGP {test.priceEgp}</p>
                          </div>
                          <div className="flex flex-wrap gap-2">
                            {/* Edit button */}
                            <button
                              onClick={() => startEditingTest(test)}
                              className="px-3 py-2 border border-gray-300 rounded-lg font-medium hover:bg-gray-50"
                            >
                              Edit
                            </button>
                            {/* Delete button */}
                            <button
                              onClick={() => handleDeleteTest(test.id)}
                              disabled={deletingTestId === test.id || togglingTestId === test.id}
                              className="px-3 py-2 border border-red-300 text-red-600 rounded-lg font-medium hover:bg-red-50 disabled:opacity-60 disabled:cursor-not-allowed"
                            >
                              {deletingTestId === test.id ? "Deleting…" : "Delete"}
                            </button>
                            {/* Active/Inactive button */}
                            <button
                              onClick={() => handleToggleTest(test.id, test.isActive)}
                              disabled={togglingTestId === test.id || deletingTestId === test.id}
                              className={`px-3 py-2 rounded-lg font-medium disabled:opacity-60 disabled:cursor-not-allowed ${test.isActive ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-700"}`}
                            >
                              {togglingTestId === test.id ? "Saving…" : test.isActive ? "Active" : "Inactive"}
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
              <div key="results" className="space-y-3 animate-fade-in">
                {workspace.bookings
                  .filter((booking) => booking.status === "Confirmed")
                  .map((booking) => {
                    const state = uploadState[booking.id] ?? { summary: "", file: null };
                    return (
                      // 10. result cards
                      <div key={booking.id} className="bg-white rounded-2xl border border-gray-100 p-6 shadow-sm space-y-4">
                        {/* test name h2 */}
                        <h2 className="text-lg font-bold text-gray-900">{booking.test.name}</h2>
                        {/* Patient: text */}
                        <p className="text-sm font-medium text-gray-600">Patient: {booking.patient.fullName || "Patient"}</p>
                        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
                          {/* input fields border-gray-200 */}
                          <input
                            type="file"
                            accept="application/pdf"
                            onChange={(event) =>
                              setUploadState((prev) => ({
                                ...prev,
                                [booking.id]: { summary: state.summary, file: event.target.files?.[0] || null },
                              }))
                            }
                            className="px-3 py-2 border border-gray-200 rounded-lg"
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
                            className="px-3 py-2 border border-gray-200 rounded-lg"
                          />
                          {/* Upload Result button */}
                          <button
                            onClick={() => handleUploadResult(booking.id)}
                            disabled={uploadingIds.has(booking.id)}
                            className="px-4 py-2 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 disabled:opacity-60 disabled:cursor-not-allowed"
                          >
                            {uploadingIds.has(booking.id) ? "Uploading…" : "Upload Result"}
                          </button>
                          {/* Mark Delivered button */}
                          <button
                            onClick={() => handleDeliverResult(booking.id)}
                            disabled={uploadingIds.has(booking.id)}
                            className="px-4 py-2 border border-green-300 text-green-700 font-semibold rounded-xl hover:bg-green-50 disabled:opacity-60 disabled:cursor-not-allowed"
                          >
                            Mark Delivered
                          </button>
                          <button
                            type="button"
                            onClick={() => openPatientContext(booking.id)}
                            className="px-4 py-2 border border-blue-300 text-blue-900 rounded-lg hover:bg-blue-50 text-sm font-medium md:col-span-3"
                          >
                            Patient history & context
                          </button>
                        </div>

                      </div>
                    );
                  })}
              </div>
            )}

            {tab === "schedule" && (
              <div key="schedule" className="space-y-3 animate-fade-in">
                {/* 11. "Add Slot" card */}
                <div className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm">
                  {/* h2 Add Slot */}
                  <h2 className="text-lg font-bold text-gray-900 mb-3">Add Slot</h2>
                  <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
                    {/* input fields border-gray-200 */}
                    <input type="datetime-local" value={newSlot.startsAt} onChange={(e) => setNewSlot((p) => ({ ...p, startsAt: e.target.value }))} className="px-3 py-2 border border-gray-200 rounded-lg" />
                    <input type="datetime-local" value={newSlot.endsAt} onChange={(e) => setNewSlot((p) => ({ ...p, endsAt: e.target.value }))} className="px-3 py-2 border border-gray-200 rounded-lg" />
                    <input type="number" min={1} value={newSlot.capacity} onChange={(e) => setNewSlot((p) => ({ ...p, capacity: e.target.value }))} className="px-3 py-2 border border-gray-200 rounded-lg" />
                    {/* "Create Slot" button */}
                    <button onClick={handleCreateSlot} disabled={creatingSlot} className="px-4 py-2 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 disabled:opacity-60 disabled:cursor-not-allowed">
                      {creatingSlot ? "Creating…" : "Create Slot"}
                    </button>
                  </div>
                </div>
                <div className="space-y-3">
                  {workspace.schedule.map((slot) => (
                    // slot cards
                    <div key={slot.id} className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm flex items-center justify-between gap-4">
                      <div>
                        {/* slot time p */}
                        <p className="font-medium text-gray-900">{formatDateTime(slot.startsAt)} - {formatDateTime(slot.endsAt)}</p>
                        <p className="text-sm text-gray-600">Capacity: {slot.capacity}</p>
                      </div>
                      {/* "Deactivate" button */}
                      <button
                        onClick={() => handleDeactivateSlot(slot.id)}
                        disabled={deactivatingSlotId === slot.id}
                        className="px-3 py-2 border border-red-300 text-red-600 font-medium rounded-lg hover:bg-red-50 disabled:opacity-60 disabled:cursor-not-allowed"
                      >
                        {deactivatingSlotId === slot.id ? "Deactivating…" : "Deactivate"}
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {tab === "reviews" && (
              <div key="reviews" className="animate-fade-in">
                {/* 13. Reviews tab */}
                <div className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm">
                  <div className="flex items-center gap-2 mb-5">
                    <MessageSquare className="w-5 h-5 text-blue-600" />
                    <h2 className="text-lg text-gray-900">Patient Reviews</h2>
                    {!reviewsLoading && (
                      <span className="text-sm text-gray-500">({reviewItems.length} published)</span>
                    )}
                  </div>
                  {reviewsLoading ? (
                    <div className="space-y-3">
                      {[0, 1, 2].map((i) => (
                        <div key={i} className="border border-gray-100 rounded-2xl p-4">
                          <div className="skeleton h-4 w-32 mb-2 rounded" />
                          <div className="skeleton h-4 w-full rounded" />
                        </div>
                      ))}
                    </div>
                  ) : reviewItems.length === 0 ? (
                    <p className="text-gray-500">No published reviews yet. Reviews appear here once a patient submits one after receiving their results.</p>
                  ) : (
                    <div className="space-y-3">
                      {reviewItems.map((review) => (
                        <div key={review.id} className="border border-gray-100 rounded-2xl p-4">
                          <div className="flex items-center justify-between mb-2">
                            <div className="flex items-center gap-2">
                              <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-sm">
                                {review.patientName[0].toUpperCase()}
                              </div>
                              {/* reviewer name */}
                              <span className="font-semibold text-gray-900">{review.patientName}</span>
                            </div>
                            <div className="flex items-center gap-0.5">
                              {[1, 2, 3, 4, 5].map((v) => (
                                <Star key={v} className={`w-4 h-4 ${v <= review.rating ? "fill-yellow-400 text-yellow-400" : "text-gray-300"}`} />
                              ))}
                            </div>
                          </div>
                          {review.comment && <p className="text-gray-700 text-sm">{review.comment}</p>}
                          <p className="text-gray-400 text-xs mt-2">
                            {new Date(review.createdAt).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" })}
                          </p>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            )}

            {tab === "settings" && (
              <div key="settings" className="space-y-3 max-w-lg animate-fade-in">
                {/* 14. Settings tab */}
                <div className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm">
                  {/* section heading */}
                  <h2 className="text-lg font-bold text-gray-900 mb-1">Service Options</h2>
                  <p className="text-sm text-gray-500 mb-4">Control which collection types patients can book with your lab.</p>
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="text-gray-900">Home Test Kits</p>
                        <p className="text-sm text-gray-500">Ship self-collection kits to patients (+EGP 150 fee)</p>
                      </div>
                      <button
                        onClick={() => handleToggleHomeTestKit(workspace.lab.homeTestKit)}
                        disabled={savingProfile}
                        className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors disabled:opacity-50 ${
                          workspace.lab.homeTestKit ? "bg-blue-600" : "bg-gray-200"
                        }`}
                      >
                        <span
                          className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                            workspace.lab.homeTestKit ? "translate-x-6" : "translate-x-1"
                          }`}
                        />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {tab === "analytics" && (
              <div key="analytics" className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3 animate-fade-in">
                {/* 12. Analytics stat cards */}
                <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm">
                  {/* stat label */}
                  <p className="text-sm font-medium text-gray-500">Total Bookings</p>
                  {/* stat value */}
                  <p className="text-2xl font-bold text-gray-900">{workspace.analytics.totalBookings}</p>
                </div>
                <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm">
                  <p className="text-sm font-medium text-gray-500">Completed</p>
                  <p className="text-2xl font-bold text-gray-900">{workspace.analytics.completedBookings}</p>
                </div>
                <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm">
                  <p className="text-sm font-medium text-gray-500">Pending Results</p>
                  <p className="text-2xl font-bold text-gray-900">{workspace.analytics.pendingResults}</p>
                </div>
                <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm">
                  <p className="text-sm font-medium text-gray-500">Revenue Estimate</p>
                  <p className="text-2xl font-bold text-gray-900">EGP {workspace.analytics.revenueEstimateEgp}</p>
                </div>
                <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm md:col-span-2 lg:col-span-4">
                  <p className="text-sm font-medium text-gray-500 mb-1.5">Capacity Usage</p>
                  <p className="text-xl font-bold text-gray-900">{workspace.analytics.capacityUsagePercent}%</p>
                </div>
                <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm md:col-span-2 lg:col-span-4">
                  <p className="font-medium text-gray-500 mb-2">Top Tests</p>
                  <div className="space-y-2">
                    {workspace.analytics.topTests.map((test) => (
                      <p key={test.testId} className="font-bold text-gray-900">{test.testName}: {test.count}</p>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </>
        )}
      </main>

      {(patientContextLoading || patientContext !== null) && (
        <>
          <div
            className="fixed inset-0 bg-black/40 z-40"
            onClick={closePatientContext}
            onKeyDown={(e) => e.key === "Escape" && closePatientContext()}
            role="presentation"
            aria-hidden
          />
          <aside className="fixed inset-y-0 right-0 z-50 w-full max-w-xl bg-white shadow-2xl overflow-y-auto border-l border-gray-200 flex flex-col">
            <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">Patient context</h2>
              <button
                type="button"
                onClick={closePatientContext}
                className="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                Close
              </button>
            </div>
            <div className="p-6 space-y-6 flex-1">
              {patientContextLoading && <p className="text-gray-600">Loading…</p>}
              {patientContext && !patientContextLoading && (
                <>
                  <p className="text-sm text-gray-700 bg-slate-50 border border-slate-200 rounded-lg p-3">{patientContext.privacyNotice}</p>
                  <p className="text-xs text-gray-500">
                    Patient sharing setting:{" "}
                    <span className="font-medium text-gray-800">
                      {patientContext.patientSharing === "FULL_HISTORY_AUTHORIZED"
                        ? "Broader history authorized"
                        : "Same lab only"}
                    </span>{" "}
                    · Effective view:{" "}
                    <span className="font-medium text-gray-800">
                      {patientContext.effectiveScopeForThisLab === "full_history" ? "Cross-lab summaries" : "This lab only"}
                    </span>
                  </p>

                  <section>
                    <h3 className="text-sm font-semibold text-gray-900 mb-2">Demographics</h3>
                    <ul className="text-sm text-gray-700 space-y-1">
                      <li>
                        <span className="text-gray-500">Name:</span> {patientContext.demographics.fullName || "—"}
                      </li>
                      <li>
                        <span className="text-gray-500">Phone:</span> {patientContext.demographics.phone || "—"}
                      </li>
                      <li>
                        <span className="text-gray-500">Email:</span> {patientContext.demographics.email || "—"}
                      </li>
                      <li>
                        <span className="text-gray-500">Address:</span> {patientContext.demographics.address || "—"}
                      </li>
                    </ul>
                  </section>

                  {patientContext.recurringTestsSummary.length > 0 && (
                    <section>
                      <h3 className="text-sm font-semibold text-gray-900 mb-2">Recurring tests (signal)</h3>
                      <ul className="list-disc pl-5 text-sm text-gray-700 space-y-1">
                        {patientContext.recurringTestsSummary.map((line) => (
                          <li key={line}>{line}</li>
                        ))}
                      </ul>
                    </section>
                  )}

                  {patientContext.trendSummary.length > 0 && (
                    <section>
                      <h3 className="text-sm font-semibold text-gray-900 mb-2">Recent trend summary (12 months)</h3>
                      <div className="space-y-3">
                        {patientContext.trendSummary.map((series) => (
                          <div key={series.canonicalCode} className="border border-gray-100 rounded-lg p-3 text-sm">
                            <p className="font-medium text-gray-900">
                              {series.displayName}{" "}
                              <span className="text-gray-500 font-normal">({series.chartUnit})</span>
                            </p>
                            <ul className="mt-2 space-y-1 text-gray-700">
                              {series.points.map((pt) => (
                                <li key={`${pt.bookingId}-${pt.testDate}`}>
                                  {new Date(pt.testDate).toLocaleDateString("en-GB")}: {pt.value.toFixed(2)} · {pt.labName}
                                </li>
                              ))}
                            </ul>
                          </div>
                        ))}
                      </div>
                    </section>
                  )}

                  <section>
                    <h3 className="text-sm font-semibold text-gray-900 mb-2">Prior bookings & results</h3>
                    <div className="space-y-4 max-h-[40vh] overflow-y-auto pr-1">
                      {patientContext.priorBookings.map((row) => (
                        <div key={row.bookingId} className="border border-gray-200 rounded-lg p-3 text-sm">
                          <div className="flex flex-wrap justify-between gap-2">
                            <span className="font-medium text-gray-900">{row.testName}</span>
                            <span className={`text-xs px-2 py-0.5 rounded-full ${statusClass(row.status)}`}>{row.status}</span>
                          </div>
                          <p className="text-gray-500 text-xs mt-1">
                            {formatDateTime(row.scheduledAt)} · {row.labName}
                            {!row.isThisLab && (
                              <span className="ml-2 text-amber-800 bg-amber-50 px-1 rounded">Other lab</span>
                            )}
                          </p>
                          {row.summaryPreview && (
                            <p className="text-gray-700 mt-2 line-clamp-3">{row.summaryPreview}</p>
                          )}
                          {row.structuredSummary.length > 0 && (
                            <ul className="mt-2 space-y-1 text-xs text-gray-800">
                              {row.structuredSummary.map((obs, idx) => (
                                <li key={`${row.bookingId}-obs-${idx}`}>
                                  {obs.displayName}: {obs.value} {obs.unit ?? ""}{" "}
                                  <span className="text-gray-500">
                                    ({new Date(obs.testDate).toLocaleDateString("en-GB")})
                                  </span>
                                </li>
                              ))}
                            </ul>
                          )}
                          {row.pdfAvailable && row.pdfUrl && (
                            <a
                              href={resolveLabPdfUrl(row.pdfUrl)}
                              target="_blank"
                              rel="noreferrer"
                              className="inline-block mt-2 text-blue-600 hover:underline"
                            >
                              Open PDF (your lab)
                            </a>
                          )}
                        </div>
                      ))}
                    </div>
                  </section>
                </>
              )}
            </div>
          </aside>
        </>
      )}
    </div>
  );
}
