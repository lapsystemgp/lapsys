import { apiFetch } from "./api";

export type BookingStatus = "Pending" | "Confirmed" | "Rejected" | "Cancelled" | "Completed";
export type BookingType = "LabVisit" | "HomeCollection";

export type BookingAvailabilitySlot = {
  id: string;
  startsAt: string;
  endsAt: string;
};

export type BookingItem = {
  id: string;
  status: BookingStatus;
  bookingType: BookingType;
  scheduledAt: string;
  homeAddress: string | null;
  totalPriceEgp: number;
  createdAt: string;
  patient: {
    id: string;
    fullName: string | null;
    phone: string | null;
  };
  lab: {
    id: string;
    name: string;
    address: string;
    homeCollection: boolean;
  };
  test: {
    id: string;
    name: string;
    priceEgp: number;
  };
  slot: {
    id: string;
    startsAt: string;
    endsAt: string;
  } | null;
  timeline: Array<{
    id: string;
    status: BookingStatus;
    note: string | null;
    actorUserId: string | null;
    createdAt: string;
  }>;
};

export async function fetchBookingAvailability(params: {
  labId: string;
  testId: string;
  dateFrom?: string;
  days?: number;
}) {
  const query = new URLSearchParams();
  query.set("labId", params.labId);
  query.set("testId", params.testId);
  if (params.dateFrom) query.set("dateFrom", params.dateFrom);
  if (typeof params.days === "number") query.set("days", String(params.days));
  return await apiFetch<{ items: BookingAvailabilitySlot[] }>(`/bookings/availability?${query.toString()}`);
}

export async function createBooking(input: {
  labId: string;
  testId: string;
  slotId: string;
  bookingType: BookingType;
  homeAddress?: string;
}) {
  return await apiFetch<BookingItem>("/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
}

export async function fetchPatientBookings() {
  return await apiFetch<{ items: BookingItem[] }>("/bookings/patient");
}

export async function fetchLabBookings() {
  return await apiFetch<{ items: BookingItem[] }>("/bookings/lab");
}

export async function cancelPatientBooking(bookingId: string) {
  return await apiFetch<BookingItem>(`/bookings/${encodeURIComponent(bookingId)}/patient-cancel`, {
    method: "PATCH",
  });
}

export async function setLabBookingStatus(bookingId: string, status: "Confirmed" | "Rejected") {
  return await apiFetch<BookingItem>(`/bookings/${encodeURIComponent(bookingId)}/lab-status`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status }),
  });
}
