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
    highlights: {
      items: Array<{
        key: string;
        label: string;
        value: string;
        kind: "key_value" | "text" | "structured";
      }>;
    };
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

export type LabHistorySharing = "SAME_LAB_ONLY" | "FULL_HISTORY_AUTHORIZED";

export type PatientWorkspaceResponse = {
  profile: {
    fullName: string;
    phone: string;
    address: string;
    email: string;
    labHistorySharing: LabHistorySharing;
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

export type HealthProfileGroupBy = "analyte" | "lab_test";

export type HealthProfileSeries = {
  canonicalCode: string;
  displayName: string;
  chartUnit: string;
  category: string | null;
  labTestName: string | null;
  trend: {
    direction: "increasing" | "decreasing" | "stable" | "insufficient_data";
    narrative: string;
    qualitativeNote: string | null;
  };
  points: Array<{
    testDate: string;
    value: number;
    comparable: boolean;
    comparabilityNote: string | null;
    bookingId: string;
    labName: string;
    labTestName: string;
    refLow: number | null;
    refHigh: number | null;
    abnormal: boolean | null;
  }>;
};

export type PatientHealthProfileResponse = {
  range: HealthProfileRange;
  groupBy: HealthProfileGroupBy;
  hasStructuredData: boolean;
  disclaimer: string;
  series: HealthProfileSeries[];
  labTestGroups: Array<{ labTestName: string; series: HealthProfileSeries[] }>;
  pdfOnlyBookings: Array<{
    bookingId: string;
    scheduledAt: string;
    labName: string;
    testName: string;
  }>;
};

export async function fetchPatientHealthProfile(
  range: HealthProfileRange = "12m",
  groupBy: HealthProfileGroupBy = "analyte",
) {
  const params = new URLSearchParams({ range, groupBy });
  return await apiFetch<PatientHealthProfileResponse>(`/patient/health-profile?${params.toString()}`);
}

export async function updatePatientProfile(input: {
  fullName?: string;
  phone?: string;
  address?: string;
  labHistorySharing?: LabHistorySharing;
}) {
  return await apiFetch<{
    fullName: string;
    phone: string;
    address: string;
    labHistorySharing: LabHistorySharing;
  }>("/patient/profile", {
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
