"use client";

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { apiFetch } from "../lib/api";

type Role = "Patient" | "LabStaff" | "Admin";
type LabOnboardingStatus = "PendingReview" | "Active" | "Rejected" | "Suspended";

export type CurrentUser = {
  id: string;
  email: string;
  role: Role;
  lab_profile?: { id: string; onboarding_status: LabOnboardingStatus; lab_name: string } | null;
  patient_profile?: { id: string; full_name: string | null } | null;
};

type SessionState = {
  user: CurrentUser | null;
  loading: boolean;
  refresh: () => Promise<void>;
  logout: () => Promise<void>;
};

const SessionContext = createContext<SessionState | null>(null);

export function SessionProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<CurrentUser | null>(null);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    try {
      const me = await apiFetch<CurrentUser>("/auth/me", { method: "GET" });
      setUser(me);
    } catch (err: any) {
      const status = typeof err?.status === "number" ? err.status : undefined;
      if (status === 401) {
        setUser(null);
      }
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(async () => {
    try {
      await apiFetch<{ message: string }>("/auth/logout", { method: "POST" });
    } catch {
      // Ignore network/API errors; still clear local session state.
    } finally {
      setUser(null);
    }
  }, []);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const value = useMemo<SessionState>(() => ({ user, loading, refresh, logout }), [user, loading, refresh, logout]);

  return <SessionContext.Provider value={value}>{children}</SessionContext.Provider>;
}

export function useSession() {
  const ctx = useContext(SessionContext);
  if (!ctx) {
    throw new Error("useSession must be used within SessionProvider");
  }
  return ctx;
}

