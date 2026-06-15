"use client";

import { ArrowLeft, HeartPulse, Star } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Breadcrumb } from "../../../components/Breadcrumb";
import { API_BASE_URL, ApiError } from "../../../lib/api";
import { cancelPatientBooking, demoOnlinePayment } from "../../../lib/bookingsApi";
import {
  fetchPatientWorkspace,
  submitPatientReview,
  updatePatientProfile,
  type LabHistorySharing,
  type PatientWorkspaceResult,
  type PatientWorkspaceResponse,
} from "../../../lib/patientApi";
import { useSession } from "../../../components/SessionProvider";
import { HealthTrendsPanel } from "../../../components/patient/HealthTrendsPanel";
import { useToast } from "../../../components/ToastProvider";

type Tab = "bookings" | "results" | "trends" | "profile";

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

function bookingStatusClass(status: string) {
  if (status === "Confirmed") return "bg-green-100 text-green-700";
  if (status === "Pending") return "bg-yellow-100 text-yellow-700";
  if (status === "Cancelled") return "bg-gray-100 text-gray-700";
  if (status === "Rejected") return "bg-red-100 text-red-700";
  return "bg-blue-100 text-blue-700";
}

function paymentStatusClass(status: string) {
  if (status === "Paid") return "bg-emerald-100 text-emerald-800";
  if (status === "Pending") return "bg-amber-100 text-amber-800";
  if (status === "Failed") return "bg-red-100 text-red-800";
  if (status === "Refunded") return "bg-slate-100 text-slate-700";
  return "bg-gray-100 text-gray-700";
}

function formatPaymentMethod(method: string) {
  if (method === "Online") return "Online (demo)";
  if (method === "CashHomeCollection") return "Cash on collection";
  if (method === "CashLabVisit") return "Cash at lab";
  if (method === "CashOnDelivery") return "Cash on delivery";
  return method;
}

function KitStatusBar({ kitStatus, kitTrackingNumber }: { kitStatus: string | null; kitTrackingNumber: string | null }) {
  const stages = ["AwaitingShipment", "Shipped", "Delivered", "SampleReceived"];
  const currentIdx = kitStatus ? stages.indexOf(kitStatus) : 0;
  const labels = ["Awaiting Shipment", "Shipped", "Delivered", "Sample Received"];
  return (
    <div className="mt-3">
      <p className="text-xs text-gray-500 mb-2">Kit Status</p>
      <div className="flex items-center gap-1">
        {stages.map((stage, idx) => (
          <div key={stage} className="flex items-center gap-1 flex-1">
            <div
              className={`w-6 h-6 rounded-full flex items-center justify-center text-xs shrink-0 ${
                idx <= currentIdx ? "bg-blue-600 text-white" : "bg-gray-200 text-gray-400"
              }`}
            >
              {idx + 1}
            </div>
            <span className={`text-xs hidden sm:block ${idx <= currentIdx ? "text-blue-700" : "text-gray-400"}`}>
              {labels[idx]}
            </span>
            {idx < stages.length - 1 && (
              <div className={`h-0.5 flex-1 ${idx < currentIdx ? "bg-blue-600" : "bg-gray-200"}`} />
            )}
          </div>
        ))}
      </div>
      {kitTrackingNumber && (
        <p className="text-xs text-gray-600 mt-2">Tracking: <span className="font-mono">{kitTrackingNumber}</span></p>
      )}
    </div>
  );
}

function resolveResultFileUrl(fileUrl: string) {
  return `${API_BASE_URL}${fileUrl.startsWith("/") ? "" : "/"}${fileUrl}`;
}

export default function PatientDashboardPage() {
  const router = useRouter();
  const { user, logout } = useSession();

  const toast = useToast();
  const [tab, setTab] = useState<Tab>("bookings");
  const [workspace, setWorkspace] = useState<PatientWorkspaceResponse | null>(null);
  const [loading, setLoading] = useState(true);

  const [profileForm, setProfileForm] = useState<{
    fullName: string;
    phone: string;
    address: string;
    labHistorySharing: LabHistorySharing;
  }>({ fullName: "", phone: "", address: "", labHistorySharing: "SAME_LAB_ONLY" });
  const [savingProfile, setSavingProfile] = useState(false);
  const [reviewDrafts, setReviewDrafts] = useState<Record<string, { rating: number; comment: string }>>({});
  const [submittingReviewId, setSubmittingReviewId] = useState<string | null>(null);
  const [demoPayBookingId, setDemoPayBookingId] = useState<string | null>(null);

  const loadWorkspace = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetchPatientWorkspace();
      setWorkspace(response);
      setProfileForm({
        fullName: response.profile.fullName,
        phone: response.profile.phone,
        address: response.profile.address,
        labHistorySharing: response.profile.labHistorySharing ?? "SAME_LAB_ONLY",
      });
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        router.push("/login");
        return;
      }
      toast.error("Unable to load patient workspace.");
    } finally {
      setLoading(false);
    }
  }, [router, toast]);

  useEffect(() => {
    loadWorkspace();
  }, [loadWorkspace]);

  const allBookings = useMemo(() => {
    if (!workspace) return [];
    return [...workspace.bookings.upcoming, ...workspace.bookings.past].sort(
      (a, b) => new Date(b.scheduledAt).getTime() - new Date(a.scheduledAt).getTime(),
    );
  }, [workspace]);

  const handleCancel = async (bookingId: string) => {
    try {
      await cancelPatientBooking(bookingId);
      await loadWorkspace();
      toast.success("Booking cancelled.");
    } catch {
      toast.error("Could not cancel booking. Please try again.");
    }
  };

  const handleDemoOnlinePayment = async (bookingId: string, outcome: "success" | "failure") => {
    setDemoPayBookingId(bookingId);
    try {
      await demoOnlinePayment(bookingId, outcome);
      await loadWorkspace();
      toast.success(outcome === "success" ? "Payment processed successfully." : "Payment declined (demo).");
    } catch {
      toast.error("Demo payment could not be completed.");
    } finally {
      setDemoPayBookingId(null);
    }
  };

  const handleSaveProfile = async () => {
    setSavingProfile(true);
    try {
      await updatePatientProfile(profileForm);
      await loadWorkspace();
      toast.success("Profile saved.");
    } catch {
      toast.error("Could not update profile.");
    } finally {
      setSavingProfile(false);
    }
  };

  const ensureReviewDraft = (result: PatientWorkspaceResult) => {
    if (reviewDrafts[result.bookingId]) {
      return reviewDrafts[result.bookingId];
    }

    const draft = { rating: 5, comment: "" };
    setReviewDrafts((prev) => ({ ...prev, [result.bookingId]: draft }));
    return draft;
  };

  const handleSubmitReview = async (result: PatientWorkspaceResult) => {
    const draft = ensureReviewDraft(result);
    setSubmittingReviewId(result.bookingId);

    try {
      await submitPatientReview({
        bookingId: result.bookingId,
        rating: draft.rating,
        comment: draft.comment.trim() || undefined,
      });
      await loadWorkspace();
      toast.success("Review submitted. Thank you!");
    } catch {
      toast.error("Could not submit review. Please try again.");
    } finally {
      setSubmittingReviewId(null);
    }
  };

  const handleLogout = async () => {
    await logout();
    router.push("/login");
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white/95 backdrop-blur-sm shadow-sm border-b border-gray-100">
        <div className="max-w-6xl mx-auto px-4 py-3 flex justify-between items-center gap-4">
          <div className="flex items-center gap-3">
            {/* Avatar */}
            <div className="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center text-white font-bold text-sm shrink-0 shadow-sm">
              {(user?.patient_profile?.full_name || user?.email || 'P').charAt(0).toUpperCase()}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-base font-bold text-gray-900">{user?.patient_profile?.full_name || user?.email}</h1>
                <span className="px-2 py-0.5 bg-blue-50 text-blue-700 text-xs font-semibold rounded-full">Patient</span>
              </div>
              <button
                onClick={() => router.push("/")}
                className="flex items-center gap-1 text-xs text-gray-500 hover:text-blue-600 hover:-translate-x-0.5 transition-all duration-150 font-medium mt-0.5"
              >
                <ArrowLeft className="w-3 h-3" />
                Back to Home
              </button>
            </div>
          </div>
          <div className="flex gap-2">
            <button onClick={() => router.push("/patient/assistant")} className="flex items-center gap-1.5 px-2 sm:px-3 py-1.5 text-sm rounded-xl bg-blue-600 text-white hover:bg-blue-700 transition-all duration-150 font-medium shadow-sm">
              <HeartPulse className="w-4 h-4" />
              <span className="hidden sm:inline">AI Assistant</span>
            </button>
            <button onClick={() => router.push("/labs")} className="px-2 sm:px-3 py-1.5 text-sm border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-blue-300 transition-all duration-150 font-medium text-gray-700">
              <span className="hidden sm:inline">Browse Labs</span>
              <span className="sm:hidden">Labs</span>
            </button>
            <button onClick={handleLogout} className="px-2 sm:px-3 py-1.5 text-sm border border-gray-200 rounded-xl hover:bg-red-50 hover:border-red-300 hover:text-red-600 transition-all duration-150 font-medium text-gray-700">
              Logout
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-5">
        <Breadcrumb items={[{ label: "Patient Dashboard" }]} className="mb-4" />
        {/* Quick stats */}
        {workspace && (
          <div className="grid grid-cols-3 gap-3 mb-5">
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 text-center">
              <div className="text-2xl font-bold text-gray-900">{allBookings.length}</div>
              <div className="text-xs text-gray-500 mt-0.5">Total Bookings</div>
            </div>
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 text-center">
              <div className="text-2xl font-bold text-blue-600">{workspace.bookings.upcoming.length}</div>
              <div className="text-xs text-gray-500 mt-0.5">Upcoming</div>
            </div>
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 text-center">
              <div className="text-2xl font-bold text-green-600">{workspace.results.length}</div>
              <div className="text-xs text-gray-500 mt-0.5">Results</div>
            </div>
          </div>
        )}
        {/* Tab pills — #6: font-semibold active, font-medium inactive */}
        <div className="flex gap-1 sm:gap-1.5 mb-5 p-1 bg-white border border-gray-200 rounded-xl overflow-x-auto max-w-full">
          {(["bookings", "results", "trends", "profile"] as const).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`px-4 py-1.5 rounded-lg text-sm capitalize transition-all duration-150 ${
                tab === t
                  ? "bg-blue-600 text-white shadow-sm font-semibold"
                  : "text-gray-600 hover:text-gray-900 hover:bg-gray-50 font-medium"
              }`}
            >
              {t}
            </button>
          ))}
        </div>

        {loading ? (
          <div className="space-y-3">
            {[0, 1].map((i) => (
              <div key={i} className={`bg-white rounded-2xl p-5 shadow-sm border border-gray-200 animate-slide-up ${i === 1 ? 'animation-delay-100' : ''}`}>
                <div className="flex justify-between items-start mb-4">
                  <div className="space-y-2">
                    <div className="skeleton h-5 w-40 rounded" />
                    <div className="skeleton h-4 w-28 rounded" />
                  </div>
                  <div className="skeleton h-6 w-20 rounded-full" />
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  {[0, 1, 2, 3].map((j) => <div key={j} className="skeleton h-10 rounded" />)}
                </div>
              </div>
            ))}
          </div>
        ) : !workspace ? (
          <p>Unable to load workspace.</p>
        ) : (
          <>
            {tab === "bookings" && (
              <div key="bookings" className="space-y-3 animate-fade-in">
                {allBookings.length === 0 ? (
                  // Empty state — #19: rounded-2xl, font-semibold rounded-xl on button
                  <div className="bg-white rounded-2xl p-5 shadow-sm">
                    <p className="text-gray-700 mb-3">No bookings yet.</p>
                    <button onClick={() => router.push("/labs")} className="px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-semibold">
                      Start Booking
                    </button>
                  </div>
                ) : (
                  allBookings.map((booking) => (
                    // Booking card — #7: rounded-2xl
                    <div key={booking.id} className={`bg-white rounded-2xl p-5 shadow-sm border hover:shadow-md transition-all duration-200 ${booking.status === 'Confirmed' ? 'border-l-4 border-l-green-500 border-gray-200' : booking.status === 'Pending' ? 'border-l-4 border-l-yellow-400 border-gray-200' : booking.status === 'Cancelled' ? 'border-l-4 border-l-gray-400 border-gray-200' : 'border-gray-200'}`}>
                      <div className="flex justify-between items-start mb-4">
                        <div>
                          {/* Booking test name — #8: font-bold */}
                          <h2 className="text-lg text-gray-900 font-bold">{booking.test.name}</h2>
                          {/* Booking lab name — #9: font-medium */}
                          <p className="text-gray-600 font-medium">{booking.lab.name}</p>
                        </div>
                        {/* Booking status badge — #10: font-medium */}
                        <span className={`px-3 py-1 rounded-full font-medium ${bookingStatusClass(booking.status)}`}>{booking.status}</span>
                      </div>
                      {/* Booking fields — #11: label font-medium, #12: value font-semibold */}
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm text-gray-700">
                        <div>
                          <p className="text-gray-500 font-medium">{booking.bookingType === "HomeTestKit" ? "Order Date" : "Date & Time"}</p>
                          <p className="font-semibold">{formatDateTime(booking.scheduledAt)}</p>
                        </div>
                        <div>
                          <p className="text-gray-500 font-medium">Type</p>
                          <p className="font-semibold">
                            {booking.bookingType === "HomeCollection"
                              ? "Home Collection"
                              : booking.bookingType === "HomeTestKit"
                                ? "Home Test Kit"
                                : "Lab Visit"}
                          </p>
                        </div>
                        <div>
                          <p className="text-gray-500 font-medium">Total</p>
                          <p className="font-semibold">EGP {booking.totalPriceEgp}</p>
                        </div>
                        <div>
                          <p className="text-gray-500 font-medium">{booking.bookingType === "HomeTestKit" ? "Delivery Address" : "Address"}</p>
                          <p className="font-semibold">{booking.homeAddress || booking.lab.address}</p>
                        </div>
                      </div>
                      {booking.bookingType === "HomeTestKit" && (
                        <KitStatusBar kitStatus={booking.kitStatus ?? null} kitTrackingNumber={booking.kitTrackingNumber ?? null} />
                      )}
                      <div className="mt-4 flex flex-wrap items-center gap-2 text-sm">
                        <span className="text-gray-500">Payment</span>
                        <span className="text-gray-800">{formatPaymentMethod(booking.paymentMethod)}</span>
                        <span className={`px-2 py-0.5 rounded-full ${paymentStatusClass(booking.paymentStatus)}`}>
                          {booking.paymentStatus}
                        </span>
                        {booking.paymentReference && (
                          <span className="text-gray-500">Ref: {booking.paymentReference}</span>
                        )}
                      </div>
                      {booking.paymentFailureReason && (
                        <p className="mt-2 text-sm text-red-600">{booking.paymentFailureReason}</p>
                      )}
                      {booking.paymentMethod === "Online" &&
                        booking.status === "Pending" &&
                        (booking.paymentStatus === "Pending" || booking.paymentStatus === "Failed") && (
                          <div className="mt-4 flex flex-wrap gap-2">
                            {/* Demo pay successfully — #13: font-semibold */}
                            <button
                              onClick={() => handleDemoOnlinePayment(booking.id, "success")}
                              disabled={demoPayBookingId === booking.id}
                              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 font-semibold"
                            >
                              {demoPayBookingId === booking.id ? "Processing..." : "Demo: pay successfully"}
                            </button>
                            <button
                              onClick={() => handleDemoOnlinePayment(booking.id, "failure")}
                              disabled={demoPayBookingId === booking.id}
                              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50"
                            >
                              Demo: decline payment
                            </button>
                          </div>
                        )}
                      {["Pending", "Confirmed"].includes(booking.status) && (
                        <div className="mt-4">
                          {/* Cancel Booking — #14: font-medium */}
                          <button
                            onClick={() => handleCancel(booking.id)}
                            className="px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 font-medium"
                          >
                            Cancel Booking
                          </button>
                        </div>
                      )}
                    </div>
                  ))
                )}
              </div>
            )}

            {tab === "trends" && <HealthTrendsPanel onUnauthorized={() => router.push("/login")} />}

            {tab === "results" && (
              <div key="results" className="space-y-3 animate-fade-in">
                {workspace.results.length === 0 ? (
                  <div className="bg-white rounded-2xl p-5 shadow-sm">
                    <p className="text-gray-700">No result files yet.</p>
                  </div>
                ) : (
                  workspace.results.map((result) => {
                    const draft = reviewDrafts[result.bookingId] ?? { rating: 5, comment: "" };
                    const canSubmitReview = result.canReview && !result.review;

                    return (
                      // Results card — #15: rounded-2xl
                      <div key={result.bookingId} className="bg-white rounded-2xl p-5 shadow-sm border border-gray-200 hover:shadow-md transition-shadow duration-200">
                        <div className="flex justify-between items-start mb-4 gap-3 flex-wrap">
                          <div>
                            {/* Result test name — #15: font-bold */}
                            <h2 className="text-lg text-gray-900 font-bold">{result.testName}</h2>
                            {/* Result lab name — #15: font-medium */}
                            <p className="text-gray-600 font-medium">{result.labName}</p>
                            <p className="text-sm text-gray-500">{formatDateTime(result.scheduledAt)}</p>
                          </div>
                          <div className="flex flex-col items-end gap-2">
                            <span className={`px-3 py-1 rounded-full ${bookingStatusClass(result.resultStatus)}`}>{result.resultStatus}</span>
                            {result.hasStructuredData ? (
                              <span className="text-xs px-2 py-1 rounded-full bg-emerald-100 text-emerald-800">
                                Structured data · {result.structuredObservationCount} values
                              </span>
                            ) : (
                              <span className="text-xs px-2 py-1 rounded-full bg-gray-100 text-gray-700">PDF only</span>
                            )}
                          </div>
                        </div>

                        {result.summary && (
                          <div className="mb-4 p-4 bg-blue-50 rounded-lg border border-blue-100 space-y-3">
                            <div>
                              <p className="text-sm text-gray-500 mb-1">Summary</p>
                              <p className="text-gray-800">{result.summary.summary}</p>
                            </div>
                            {result.summary.highlights.items.length > 0 && (
                              <div>
                                <p className="text-sm text-gray-500 mb-2">Highlighted results</p>
                                <ul className="grid gap-2 sm:grid-cols-2">
                                  {result.summary.highlights.items.map((item) => (
                                    <li
                                      key={`${result.bookingId}-${item.key}`}
                                      className="rounded-lg bg-white/80 border border-blue-100 px-3 py-2 text-sm"
                                    >
                                      <p className="text-gray-500 text-xs uppercase tracking-wide">{item.label}</p>
                                      <p className="text-gray-900 font-medium">{item.value}</p>
                                    </li>
                                  ))}
                                </ul>
                              </div>
                            )}
                          </div>
                        )}

                        <div className="flex gap-3 mb-4">
                          {result.file ? (
                            // Open PDF — #16: font-semibold rounded-xl
                            <a
                              href={resolveResultFileUrl(result.file.fileUrl)}
                              target="_blank"
                              rel="noreferrer"
                              className="px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 font-semibold"
                            >
                              Open PDF
                            </a>
                          ) : (
                            <span className="text-gray-500">No file uploaded yet.</span>
                          )}
                        </div>

                        {result.review ? (
                          <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                            <p className="text-sm text-green-700 mb-1">Your review</p>
                            <div className="flex items-center gap-0.5">
                              {[1, 2, 3, 4, 5].map((v) => (
                                <Star key={v} className={`w-5 h-5 ${v <= result.review!.rating ? "fill-yellow-400 text-yellow-400" : "text-gray-300"}`} />
                              ))}
                            </div>
                            {result.review.comment && <p className="text-green-800 mt-2">{result.review.comment}</p>}
                          </div>
                        ) : canSubmitReview ? (
                          <div className="p-4 border border-gray-200 rounded-lg">
                            {/* Rate this lab — #17: font-semibold */}
                            <p className="text-gray-900 mb-3 font-semibold">Rate this lab</p>
                            <div className="flex items-center gap-1 mb-3">
                              {[1, 2, 3, 4, 5].map((value) => (
                                <button
                                  key={value}
                                  type="button"
                                  onClick={() =>
                                    setReviewDrafts((prev) => ({
                                      ...prev,
                                      [result.bookingId]: { rating: value, comment: draft.comment },
                                    }))
                                  }
                                  className="p-0.5 hover:scale-110 transition-transform"
                                  aria-label={`Rate ${value} star${value !== 1 ? "s" : ""}`}
                                >
                                  <Star className={`w-7 h-7 ${value <= draft.rating ? "fill-yellow-400 text-yellow-400" : "text-gray-300 hover:text-yellow-300"}`} />
                                </button>
                              ))}
                            </div>
                            <textarea
                              value={draft.comment}
                              onChange={(event) =>
                                setReviewDrafts((prev) => ({
                                  ...prev,
                                  [result.bookingId]: { rating: draft.rating, comment: event.target.value },
                                }))
                              }
                              placeholder="Share your experience (optional)"
                              className="w-full px-3 py-2 border border-gray-300 rounded-lg mb-3"
                              rows={3}
                            />
                            {/* Submit Review — #17: font-semibold */}
                            <button
                              onClick={() => handleSubmitReview(result)}
                              disabled={submittingReviewId === result.bookingId}
                              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 font-semibold"
                            >
                              {submittingReviewId === result.bookingId ? "Submitting..." : "Submit Review"}
                            </button>
                          </div>
                        ) : null}
                      </div>
                    );
                  })
                )}
              </div>
            )}

            {tab === "profile" && (
              // Profile card — #18: rounded-2xl
              <div className="animate-fade-in bg-white rounded-2xl p-5 shadow-sm border border-gray-200 max-w-2xl">
                <div className="space-y-3">
                  <div>
                    {/* Form labels — #18: font-medium */}
                    <label className="block text-sm text-gray-600 mb-1 font-medium">Full Name</label>
                    <input
                      value={profileForm.fullName}
                      onChange={(event) => setProfileForm((prev) => ({ ...prev, fullName: event.target.value }))}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600 mb-1 font-medium">Email</label>
                    <input value={workspace.profile.email} disabled className="w-full px-4 py-2 border border-gray-200 bg-gray-50 rounded-lg" />
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600 mb-1 font-medium">Phone</label>
                    <input
                      value={profileForm.phone}
                      onChange={(event) => setProfileForm((prev) => ({ ...prev, phone: event.target.value }))}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600 mb-1 font-medium">Address</label>
                    <textarea
                      value={profileForm.address}
                      onChange={(event) => setProfileForm((prev) => ({ ...prev, address: event.target.value }))}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                      rows={3}
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600 mb-2 font-medium">What labs can see (longitudinal care)</label>
                    <select
                      value={profileForm.labHistorySharing}
                      onChange={(event) =>
                        setProfileForm((prev) => ({
                          ...prev,
                          labHistorySharing: event.target.value as LabHistorySharing,
                        }))
                      }
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-900"
                    >
                      <option value="SAME_LAB_ONLY">
                        Same lab only — each lab sees only visits and results from that lab (default)
                      </option>
                      <option value="FULL_HISTORY_AUTHORIZED">
                        Broader history — labs you book with may see structured results from other labs (not their PDFs)
                      </option>
                    </select>
                    <p className="text-xs text-gray-500 mt-1">
                      Official documents always stay with the lab that uploaded them. This setting only affects
                      structured history and summaries labs use for context.
                    </p>
                  </div>
                  {/* Save Profile — #18: font-semibold rounded-xl */}
                  <button
                    onClick={handleSaveProfile}
                    disabled={savingProfile}
                    className="px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 disabled:opacity-50 font-semibold"
                  >
                    {savingProfile ? "Saving..." : "Save Profile"}
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
