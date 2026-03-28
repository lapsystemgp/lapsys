"use client";

import { useRouter } from "next/navigation";
import { UserDashboard } from "../../../teslty/components/UserDashboard";
import type { Page } from "../../../teslty/types";
import { useSession } from "../../../components/SessionProvider";

export default function PatientDashboardPage() {
  const router = useRouter();
  const { user, logout } = useSession();

  const handleLogout = async () => {
    await logout();
    router.push("/login");
  };

  const handleNavigate = (page: Page) => {
    switch (page) {
      case "landing":
        router.push("/");
        break;
      case "labs":
        router.push("/labs");
        break;
      case "lab-details":
        router.push("/labs");
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

  const userLabel = user?.patient_profile?.full_name || user?.email;

  return (
    <UserDashboard
      onNavigate={handleNavigate}
      onLogout={handleLogout}
      currentUserLabel={userLabel}
      currentUserEmail={user?.email}
    />
  );
}
