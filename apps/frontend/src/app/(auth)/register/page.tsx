"use client";

import { useRouter } from "next/navigation";
import { LoginPage } from "../../../teslty/components/LoginPage";

function labUnauthorizedReason(status?: string | null) {
  if (status === "Rejected") return "rejected";
  if (status === "Suspended") return "suspended";
  return "pending_review";
}

export default function RegisterRoute() {
  const router = useRouter();

  return (
    <LoginPage
      defaultMode="register"
      onBack={() => router.push("/")}
      onAuthenticated={({ role, lab_onboarding_status }) => {
        if (role === "lab" && lab_onboarding_status !== "Active") {
          router.push(`/unauthorized?reason=${labUnauthorizedReason(lab_onboarding_status)}`);
          return;
        }
        if (role === "admin") {
          router.push("/admin/dashboard");
          return;
        }
        if (role === "lab") {
          router.push("/lab/dashboard");
          return;
        }
        router.push("/patient/dashboard");
      }}
      onLogin={(role) => {
        if (role === "admin") {
          router.push("/admin/dashboard");
          return;
        }
        if (role === "lab") {
          router.push("/lab/dashboard");
          return;
        }
        router.push("/patient/dashboard");
      }}
    />
  );
}
