"use client";

import { useRouter } from "next/navigation";
import { UserDashboard } from "../../../teslty/components/UserDashboard";
import type { Page } from "../../../teslty/types";

export default function PatientDashboardPage() {
  const router = useRouter();

  const handleNavigate = (page: Page) => {
    switch (page) {
      case "landing":
        router.push("/");
        break;
      case "labs":
        router.push("/labs");
        break;
      case "lab-details":
        router.push("/labs/1");
        break;
      case "booking":
        router.push("/booking");
        break;
      case "user-dashboard":
        router.push("/patient/dashboard");
        break;
      case "lab-dashboard":
        router.push("/lab/dashboard");
        break;
      case "login":
        router.push("/login");
        break;
      default:
        router.push("/");
    }
  };

  return <UserDashboard onNavigate={handleNavigate} onLogout={() => router.push("/login")} />;
}
