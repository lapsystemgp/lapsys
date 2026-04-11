import { apiFetch } from "./api";

export type PatientWorkspaceBooking = {
  id: string;
  status: "Pending" | "Confirmed" | "Rejected" | "Cancelled" | "Completed";
  bookingType: "LabVisit" | "HomeCollection";
  scheduledAt: string;
  totalPriceEgp: number;
  homeAddress: string | null;
  paymentMethod: "Online" | "CashHomeCollection" | "CashLabVisit";
  paymentStatus: "Pending" | "Paid" | "Failed" | "Refunded";
  paymentReference: string | null;
  paymentPaidAt: string | null;
  paymentFailedAt: string | null;
  paymentFailureReason: string | null;
  lab: { id: string; name: string; address: string };
  test: { id: string; name: string; priceEgp: number };
  timeline: Array<{ id: string; status: string; note: string | null; createdAt: string }>;
};

export type PatientWorkspaceResult = {
  bookingId: string;
  bookingStatus: "Pending" | "Confirmed" | "Rejected" | "Cancelled" | "Completed";
  scheduledAt: string;
  labName: string;
  testName: string;
  resultStatus: "Pending" | "Uploaded" | "Delivered";
  hasStructuredData: boolean;
  structuredObservationCount: number;
  file: {
    id: string;
    fileName: string;
    fileUrl: string;
    mimeType: string;
    sizeBytes: number;
    uploadedAt: string;
  } | null;
  summary: {
    summary: string;
    highlights: unknown;
  } | null;
  review: {
    id: string;
    rating: number;
    comment: string | null;
    status: "Pending" | "Published" | "Rejected";
    createdAt: string;
  } | null;
  canReview: boolean;
};

export type PatientWorkspaceResponse = {
  profile: {
    fullName: string;
    phone: string;
    address: string;
    email: string;
  };
  bookings: {
    upcoming: PatientWorkspaceBooking[];
    past: PatientWorkspaceBooking[];
  };
  results: PatientWorkspaceResult[];
};

export async function fetchPatientWorkspace() {
  return await apiFetch<PatientWorkspaceResponse>("/patient/workspace");
}

export type HealthProfileRange = "3m" | "6m" | "12m" | "all";

export type PatientHealthProfileResponse = {
  range: HealthProfileRange;
  hasStructuredData: boolean;
  series: Array<{
    canonicalCode: string;
    displayName: string;
    chartUnit: string;
    category: string | null;
    points: Array<{
      testDate: string;
      value: number;
      comparable: boolean;
      comparabilityNote: string | null;
      bookingId: string;
      labName: string;
    }>;
  }>;
  pdfOnlyBookings: Array<{
    bookingId: string;
    scheduledAt: string;
    labName: string;
    testName: string;
  }>;
};

export async function fetchPatientHealthProfile(range: HealthProfileRange = "12m") {
  const params = new URLSearchParams({ range });
  return await apiFetch<PatientHealthProfileResponse>(`/patient/health-profile?${params.toString()}`);
}

export async function updatePatientProfile(input: {
  fullName?: string;
  phone?: string;
  address?: string;
}) {
  return await apiFetch<{ fullName: string; phone: string; address: string }>("/patient/profile", {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
}

export async function submitPatientReview(input: {
  bookingId: string;
  rating: number;
  comment?: string;
}) {
  return await apiFetch<{
    id: string;
    rating: number;
    comment: string | null;
    status: "Pending" | "Published" | "Rejected";
    createdAt: string;
  }>("/patient/reviews", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
}
