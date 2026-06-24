"use client";

import { Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { LoginPage } from "../../../teslty/components/LoginPage";

function labUnauthorizedReason(status?: string | null) {
  if (status === "Rejected") return "rejected";
  if (status === "Suspended") return "suspended";
  return "pending_review";
}

function LoginRouteInner() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const sessionExpired = searchParams.get("reason") === "expired";

  return (
    <LoginPage
      defaultMode="login"
      sessionExpired={sessionExpired}
      onBack={() => router.push("/")}
      onAuthenticated={({ role, lab_onboarding_status }) => {
        if (role === "lab" && lab_onboarding_status !== "Active") {
          router.push(`/unauthorized?reason=${labUnauthorizedReason(lab_onboarding_status)}`);
          return;
        }
        if (role === "lab") {
          router.push("/lab/dashboard");
          return;
        }
        router.push("/patient/dashboard");
      }}
      onLogin={(role) => {
        if (role === "lab") {
          router.push("/lab/dashboard");
          return;
        }
        router.push("/patient/dashboard");
      }}
    />
  );
}

export default function LoginRoute() {
  return (
    <Suspense>
      <LoginRouteInner />
    </Suspense>
  );
}
