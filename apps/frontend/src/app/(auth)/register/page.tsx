"use client";

import { useRouter } from "next/navigation";
import { LoginPage } from "../../../teslty/components/LoginPage";

export default function RegisterRoute() {
  const router = useRouter();

  return (
    <LoginPage
      defaultMode="register"
      onBack={() => router.push("/")}
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
