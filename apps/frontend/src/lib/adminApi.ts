import { apiFetch } from "./api";

export type AdminLabOnboardingStatus =
  | "PendingReview"
  | "Active"
  | "Rejected"
  | "Suspended";

export type AdminWorkspaceResponse = {
  stats: {
    totalLabs: number;
    pendingLabs: number;
    activeLabs: number;
    rejectedLabs: number;
    suspendedLabs: number;
    readyPendingLabs: number;
    incompleteLabs: number;
  };
  labs: Array<{
    id: string;
    labName: string;
    email: string;
    phone: string;
    address: string;
    accreditation: string;
    turnaroundTime: string;
    homeCollection: boolean;
    onboardingStatus: AdminLabOnboardingStatus;
    ratingAverage: number | null;
    reviewCount: number;
    testsCount: number;
    bookingsCount: number;
    scheduleSlotsCount: number;
    onboardingReadiness: {
      isReady: boolean;
      completedRequirements: number;
      totalRequirements: number;
      missingRequirements: string[];
    };
    createdAt: string;
    updatedAt: string;
  }>;
};

export async function fetchAdminWorkspace() {
  return await apiFetch<AdminWorkspaceResponse>("/admin/workspace");
}

export async function setAdminLabOnboardingStatus(
  labProfileId: string,
  status: AdminLabOnboardingStatus,
) {
  return await apiFetch<{
    id: string;
    labName: string;
    email: string;
    onboardingStatus: AdminLabOnboardingStatus;
    updatedAt: string;
  }>(`/admin/labs/${encodeURIComponent(labProfileId)}/status`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status }),
  });
}

export type AdminPaymentRecord = {
  bookingId: string;
  bookingStatus: string;
  bookingType: string;
  scheduledAt: string;
  totalPriceEgp: number;
  paymentMethod: string;
  paymentStatus: string;
  paymentReference: string | null;
  paymentPaidAt: string | null;
  paymentFailedAt: string | null;
  paymentFailureReason: string | null;
  createdAt: string;
  patientEmail: string;
  patientName: string | null;
  labName: string;
  testName: string;
};

export async function fetchAdminRecentPayments() {
  return await apiFetch<{ items: AdminPaymentRecord[] }>("/admin/payments/recent");
}
