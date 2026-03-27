"use client";

import { useRouter } from "next/navigation";
import { LabDashboard } from "../../../teslty/components/LabDashboard";
import { useSession } from "../../../components/SessionProvider";

export default function LabDashboardPage() {
  const router = useRouter();
  const { user, logout } = useSession();

  const handleLogout = async () => {
    await logout();
    router.push("/login");
  };

  return <LabDashboard onLogout={handleLogout} labName={user?.lab_profile?.lab_name || undefined} />;
}
