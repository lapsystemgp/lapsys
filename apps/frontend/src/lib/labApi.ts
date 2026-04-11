import { apiFetch } from "./api";

export type LabWorkspaceResponse = {
  lab: { id: string; name: string; address: string };
  bookings: Array<{
    id: string;
    status: "Pending" | "Confirmed" | "Rejected" | "Cancelled" | "Completed";
    bookingType: "LabVisit" | "HomeCollection";
    scheduledAt: string;
    homeAddress: string | null;
    totalPriceEgp: number;
    paymentMethod: "Online" | "CashHomeCollection" | "CashLabVisit";
    paymentStatus: "Pending" | "Paid" | "Failed" | "Refunded";
    paymentReference: string | null;
    paymentPaidAt: string | null;
    paymentFailedAt: string | null;
    paymentFailureReason: string | null;
    patient: { id: string; fullName: string | null; phone: string | null };
    test: { id: string; name: string; priceEgp: number };
  }>;
  tests: Array<{
    id: string;
    name: string;
    category: string;
    priceEgp: number;
    description: string;
    preparation: string;
    turnaroundTime: string;
    parametersCount: number | null;
    isActive: boolean;
  }>;
  schedule: Array<{
    id: string;
    startsAt: string;
    endsAt: string;
    capacity: number;
    isActive: boolean;
  }>;
  analytics: {
    totalBookings: number;
    completedBookings: number;
    pendingResults: number;
    revenueEstimateEgp: number;
    capacityUsagePercent: number;
    topTests: Array<{ testId: string; testName: string; count: number }>;
  };
};

export async function fetchLabWorkspace() {
  return await apiFetch<LabWorkspaceResponse>("/lab/workspace");
}

export async function createLabTest(input: {
  name: string;
  category: string;
  priceEgp: number;
  description?: string;
  preparation?: string;
  turnaroundTime?: string;
  parametersCount?: number;
  isActive?: boolean;
}) {
  return await apiFetch("/lab/tests", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
}

export async function updateLabTest(testId: string, input: Record<string, unknown>) {
  return await apiFetch(`/lab/tests/${encodeURIComponent(testId)}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
}

export async function deleteLabTest(testId: string) {
  return await apiFetch(`/lab/tests/${encodeURIComponent(testId)}`, {
    method: "DELETE",
  });
}

export async function createScheduleSlot(input: {
  startsAt: string;
  endsAt: string;
  capacity?: number;
}) {
  return await apiFetch("/lab/schedule", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
}

export async function updateScheduleSlot(slotId: string, input: Record<string, unknown>) {
  return await apiFetch(`/lab/schedule/${encodeURIComponent(slotId)}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
}

export async function deactivateScheduleSlot(slotId: string) {
  return await apiFetch(`/lab/schedule/${encodeURIComponent(slotId)}`, {
    method: "DELETE",
  });
}

export async function uploadLabResult(bookingId: string, input: {
  file: File;
  summary: string;
  highlights?: string;
}) {
  const formData = new FormData();
  formData.append("file", input.file);
  formData.append("summary", input.summary);
  if (input.highlights) formData.append("highlights", input.highlights);

  return await apiFetch(`/lab/results/${encodeURIComponent(bookingId)}/upload`, {
    method: "POST",
    body: formData,
  });
}

export async function setLabResultStatus(bookingId: string, status: "Pending" | "Uploaded" | "Delivered") {
  return await apiFetch(`/lab/results/${encodeURIComponent(bookingId)}/status`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status }),
  });
}

export type LabStructuredPanelInput = {
  name?: string;
  testDate: string;
  observations: Array<{
    name: string;
    canonicalCode?: string;
    value?: number;
    valueText?: string;
    unit?: string;
    refLow?: number;
    refHigh?: number;
    refText?: string;
  }>;
};

export async function upsertLabStructuredResults(bookingId: string, panels: LabStructuredPanelInput[]) {
  return await apiFetch<{ bookingId: string; panelCount: number; observationCount: number }>(
    `/lab/results/${encodeURIComponent(bookingId)}/structured`,
    {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ panels }),
    },
  );
}

export type LabPatientContextResponse = {
  lab: { id: string; name: string };
  patientProfileId: string;
  demographics: {
    fullName: string;
    phone: string;
    address: string;
    email: string;
  };
  patientSharing: "SAME_LAB_ONLY" | "FULL_HISTORY_AUTHORIZED";
  effectiveScopeForThisLab: "same_lab" | "full_history";
  privacyNotice: string;
  priorBookings: Array<{
    bookingId: string;
    scheduledAt: string;
    status: string;
    testName: string;
    labId: string;
    labName: string;
    isThisLab: boolean;
    hasResult: boolean;
    summaryPreview: string | null;
    structuredSummary: Array<{
      displayName: string;
      code: string | null;
      value: string;
      unit: string | null;
      testDate: string;
    }>;
    pdfAvailable: boolean;
    pdfUrl: string | null;
  }>;
  recurringTestsSummary: string[];
  trendSummary: Array<{
    canonicalCode: string;
    displayName: string;
    chartUnit: string;
    category: string | null;
    points: Array<{
      testDate: string;
      value: number;
      bookingId: string;
      labName: string;
    }>;
  }>;
};

export async function fetchLabPatientContext(params: { bookingId: string } | { patientProfileId: string }) {
  const search = new URLSearchParams();
  if ("bookingId" in params) {
    search.set("bookingId", params.bookingId);
  } else {
    search.set("patientProfileId", params.patientProfileId);
  }
  return await apiFetch<LabPatientContextResponse>(`/lab/patient-context?${search.toString()}`);
}
