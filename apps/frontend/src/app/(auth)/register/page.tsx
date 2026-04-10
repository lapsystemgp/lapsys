"use client";

import { useRouter } from "next/navigation";
import { LoginPage } from "../../../teslty/components/LoginPage";

export default function RegisterRoute() {
  const router = useRouter();

  return (
    <LoginPage
      defaultMode="register"
      onBack={() => router.push("/")}
      onAuthenticated={({ role, lab_onboarding_status }) => {
        if (role === "lab" && lab_onboarding_status !== "Active") {
          router.push("/unauthorized?reason=pending_review");
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
