"use client";

import { useRouter } from "next/navigation";
import { LabDashboard } from "../../../teslty/components/LabDashboard";

export default function LabDashboardPage() {
  const router = useRouter();

  return <LabDashboard onLogout={() => router.push("/login")} />;
}
