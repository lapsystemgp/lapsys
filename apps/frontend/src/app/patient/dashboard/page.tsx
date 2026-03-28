"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { API_BASE_URL, ApiError } from "../../../lib/api";
import { cancelPatientBooking } from "../../../lib/bookingsApi";
import {
  fetchPatientWorkspace,
  submitPatientReview,
  updatePatientProfile,
  type PatientWorkspaceResult,
  type PatientWorkspaceResponse,
} from "../../../lib/patientApi";
import { useSession } from "../../../components/SessionProvider";

type Tab = "bookings" | "results" | "profile";

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

function resolveResultFileUrl(fileUrl: string) {
  if (/^https?:\/\//i.test(fileUrl)) return fileUrl;
  return `${API_BASE_URL}${fileUrl.startsWith("/") ? "" : "/"}${fileUrl}`;
}

export default function PatientDashboardPage() {
  const router = useRouter();
  const { user, logout } = useSession();

  const [tab, setTab] = useState<Tab>("bookings");
  const [workspace, setWorkspace] = useState<PatientWorkspaceResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [profileForm, setProfileForm] = useState({ fullName: "", phone: "", address: "" });
  const [savingProfile, setSavingProfile] = useState(false);
  const [reviewDrafts, setReviewDrafts] = useState<Record<string, { rating: number; comment: string }>>({});
  const [submittingReviewId, setSubmittingReviewId] = useState<string | null>(null);

  const loadWorkspace = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetchPatientWorkspace();
      setWorkspace(response);
      setProfileForm({
        fullName: response.profile.fullName,
        phone: response.profile.phone,
        address: response.profile.address,
      });
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        router.push("/login");
        return;
      }
      setError("Unable to load patient workspace.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadWorkspace();
  }, []);

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
    } catch {
      setError("Could not cancel booking. Please try again.");
    }
  };

  const handleSaveProfile = async () => {
    setSavingProfile(true);
    setError(null);
    try {
      await updatePatientProfile(profileForm);
      await loadWorkspace();
    } catch {
      setError("Could not update profile.");
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
    setError(null);

    try {
      await submitPatientReview({
        bookingId: result.bookingId,
        rating: draft.rating,
        comment: draft.comment.trim() || undefined,
      });
      await loadWorkspace();
    } catch {
      setError("Could not submit review. Please try again.");
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
      <header className="bg-white shadow-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 flex justify-between items-center">
          <div>
            <h1 className="text-2xl text-gray-900">Patient Workspace</h1>
            <p className="text-gray-600">{user?.patient_profile?.full_name || user?.email}</p>
          </div>
          <div className="flex gap-3">
            <button onClick={() => router.push("/labs")} className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
              Browse Labs
            </button>
            <button onClick={handleLogout} className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
              Logout
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-8">
        <div className="flex gap-2 mb-6">
          <button onClick={() => setTab("bookings")} className={`px-4 py-2 rounded-lg ${tab === "bookings" ? "bg-blue-600 text-white" : "bg-white border border-gray-200"}`}>
            Bookings
          </button>
          <button onClick={() => setTab("results")} className={`px-4 py-2 rounded-lg ${tab === "results" ? "bg-blue-600 text-white" : "bg-white border border-gray-200"}`}>
            Results
          </button>
          <button onClick={() => setTab("profile")} className={`px-4 py-2 rounded-lg ${tab === "profile" ? "bg-blue-600 text-white" : "bg-white border border-gray-200"}`}>
            Profile
          </button>
        </div>

        {error && <p className="text-red-600 mb-4">{error}</p>}

        {loading ? (
          <p>Loading workspace...</p>
        ) : !workspace ? (
          <p>Unable to load workspace.</p>
        ) : (
          <>
            {tab === "bookings" && (
              <div className="space-y-4">
                {allBookings.length === 0 ? (
                  <div className="bg-white rounded-xl p-6 shadow-sm">
                    <p className="text-gray-700 mb-4">No bookings yet.</p>
                    <button onClick={() => router.push("/labs")} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                      Start Booking
                    </button>
                  </div>
                ) : (
                  allBookings.map((booking) => (
                    <div key={booking.id} className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                      <div className="flex justify-between items-start mb-4">
                        <div>
                          <h2 className="text-lg text-gray-900">{booking.test.name}</h2>
                          <p className="text-gray-600">{booking.lab.name}</p>
                        </div>
                        <span className={`px-3 py-1 rounded-full ${bookingStatusClass(booking.status)}`}>{booking.status}</span>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 text-sm text-gray-700">
                        <div>
                          <p className="text-gray-500">Date & Time</p>
                          <p>{formatDateTime(booking.scheduledAt)}</p>
                        </div>
                        <div>
                          <p className="text-gray-500">Type</p>
                          <p>{booking.bookingType === "HomeCollection" ? "Home Collection" : "Lab Visit"}</p>
                        </div>
                        <div>
                          <p className="text-gray-500">Total</p>
                          <p>EGP {booking.totalPriceEgp}</p>
                        </div>
                        <div>
                          <p className="text-gray-500">Address</p>
                          <p>{booking.homeAddress || booking.lab.address}</p>
                        </div>
                      </div>
                      {["Pending", "Confirmed"].includes(booking.status) && (
                        <div className="mt-4">
                          <button
                            onClick={() => handleCancel(booking.id)}
                            className="px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50"
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

            {tab === "results" && (
              <div className="space-y-4">
                {workspace.results.length === 0 ? (
                  <div className="bg-white rounded-xl p-6 shadow-sm">
                    <p className="text-gray-700">No result files yet.</p>
                  </div>
                ) : (
                  workspace.results.map((result) => {
                    const draft = reviewDrafts[result.bookingId] ?? { rating: 5, comment: "" };
                    const canSubmitReview = result.canReview && !result.review;

                    return (
                      <div key={result.bookingId} className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                        <div className="flex justify-between items-start mb-4">
                          <div>
                            <h2 className="text-lg text-gray-900">{result.testName}</h2>
                            <p className="text-gray-600">{result.labName}</p>
                            <p className="text-sm text-gray-500">{formatDateTime(result.scheduledAt)}</p>
                          </div>
                          <span className={`px-3 py-1 rounded-full ${bookingStatusClass(result.resultStatus)}`}>{result.resultStatus}</span>
                        </div>

                        {result.summary && (
                          <div className="mb-4 p-4 bg-blue-50 rounded-lg border border-blue-100">
                            <p className="text-sm text-gray-500 mb-1">Summary</p>
                            <p className="text-gray-800">{result.summary.summary}</p>
                          </div>
                        )}

                        <div className="flex gap-3 mb-4">
                          {result.file ? (
                            <a
                              href={resolveResultFileUrl(result.file.fileUrl)}
                              target="_blank"
                              rel="noreferrer"
                              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                            >
                              Open PDF
                            </a>
                          ) : (
                            <span className="text-gray-500">No file uploaded yet.</span>
                          )}
                        </div>

                        {result.review ? (
                          <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                            <p className="text-green-800">Your review: {result.review.rating}/5</p>
                            {result.review.comment && <p className="text-green-700 mt-1">{result.review.comment}</p>}
                          </div>
                        ) : canSubmitReview ? (
                          <div className="p-4 border border-gray-200 rounded-lg">
                            <p className="text-gray-900 mb-3">Rate this lab</p>
                            <div className="flex items-center gap-3 mb-3">
                              <label className="text-sm text-gray-600">Rating</label>
                              <select
                                value={draft.rating}
                                onChange={(event) =>
                                  setReviewDrafts((prev) => ({
                                    ...prev,
                                    [result.bookingId]: {
                                      rating: Number(event.target.value),
                                      comment: draft.comment,
                                    },
                                  }))
                                }
                                className="px-3 py-2 border border-gray-300 rounded-lg"
                              >
                                {[5, 4, 3, 2, 1].map((value) => (
                                  <option key={value} value={value}>
                                    {value}
                                  </option>
                                ))}
                              </select>
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
                            <button
                              onClick={() => handleSubmitReview(result)}
                              disabled={submittingReviewId === result.bookingId}
                              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
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
              <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200 max-w-2xl">
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm text-gray-600 mb-1">Full Name</label>
                    <input
                      value={profileForm.fullName}
                      onChange={(event) => setProfileForm((prev) => ({ ...prev, fullName: event.target.value }))}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600 mb-1">Email</label>
                    <input value={workspace.profile.email} disabled className="w-full px-4 py-2 border border-gray-200 bg-gray-50 rounded-lg" />
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600 mb-1">Phone</label>
                    <input
                      value={profileForm.phone}
                      onChange={(event) => setProfileForm((prev) => ({ ...prev, phone: event.target.value }))}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600 mb-1">Address</label>
                    <textarea
                      value={profileForm.address}
                      onChange={(event) => setProfileForm((prev) => ({ ...prev, address: event.target.value }))}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                      rows={3}
                    />
                  </div>
                  <button
                    onClick={handleSaveProfile}
                    disabled={savingProfile}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
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
