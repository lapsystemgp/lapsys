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
