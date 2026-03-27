"use client";

import { useRouter } from "next/navigation";
import { LoginPage } from "../../../teslty/components/LoginPage";

export default function LoginRoute() {
  const router = useRouter();

  return (
    <LoginPage
      defaultMode="login"
      onBack={() => router.push("/")}
      onAuthenticated={({ role, lab_onboarding_status }) => {
        if (role === "lab" && lab_onboarding_status !== "Active") {
          router.push("/unauthorized?reason=pending_review");
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
