"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ApiError } from "../../../lib/api";
import { cancelPatientBooking, fetchPatientBookings, type BookingItem } from "../../../lib/bookingsApi";
import { useSession } from "../../../components/SessionProvider";

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

function statusClass(status: BookingItem["status"]) {
  if (status === "Confirmed") return "bg-green-100 text-green-700";
  if (status === "Pending") return "bg-yellow-100 text-yellow-700";
  if (status === "Cancelled") return "bg-gray-100 text-gray-700";
  if (status === "Rejected") return "bg-red-100 text-red-700";
  return "bg-blue-100 text-blue-700";
}

export default function PatientDashboardPage() {
  const router = useRouter();
  const { user, logout } = useSession();
  const [bookings, setBookings] = useState<BookingItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadBookings = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetchPatientBookings();
      setBookings(response.items);
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        router.push("/login");
        return;
      }
      setError("Unable to load your bookings.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadBookings();
  }, []);

  const handleCancel = async (bookingId: string) => {
    try {
      await cancelPatientBooking(bookingId);
      await loadBookings();
    } catch (err) {
      setError("Could not cancel booking. Please try again.");
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
            <h1 className="text-2xl text-gray-900">Patient Dashboard</h1>
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
        {error && <p className="text-red-600 mb-4">{error}</p>}
        {loading ? (
          <p>Loading bookings...</p>
        ) : bookings.length === 0 ? (
          <div className="bg-white rounded-xl p-6 shadow-sm">
            <p className="text-gray-700 mb-4">No bookings yet.</p>
            <button onClick={() => router.push("/labs")} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
              Start Booking
            </button>
          </div>
        ) : (
          <div className="space-y-4">
            {bookings.map((booking) => (
              <div key={booking.id} className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h2 className="text-lg text-gray-900">{booking.test.name}</h2>
                    <p className="text-gray-600">{booking.lab.name}</p>
                  </div>
                  <span className={`px-3 py-1 rounded-full ${statusClass(booking.status)}`}>{booking.status}</span>
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
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
