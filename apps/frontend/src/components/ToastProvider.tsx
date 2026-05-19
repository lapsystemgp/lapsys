"use client";

import { createContext, useCallback, useContext, useState } from "react";
import { AlertCircle, CheckCircle, Info, X } from "lucide-react";

type ToastType = "success" | "error" | "info";

interface ToastItem {
  id: string;
  message: string;
  type: ToastType;
  dismissing: boolean;
}

interface ToastContextValue {
  success: (message: string) => void;
  error: (message: string) => void;
  info: (message: string) => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error("useToast must be used within ToastProvider");
  return ctx;
}

const DURATION = 3500;

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([]);

  const dismiss = useCallback((id: string) => {
    setToasts((prev) => prev.map((t) => (t.id === id ? { ...t, dismissing: true } : t)));
    setTimeout(() => setToasts((prev) => prev.filter((t) => t.id !== id)), 280);
  }, []);

  const add = useCallback(
    (message: string, type: ToastType) => {
      const id = Math.random().toString(36).slice(2);
      setToasts((prev) => [...prev, { id, message, type, dismissing: false }]);
      setTimeout(() => dismiss(id), DURATION);
    },
    [dismiss],
  );

  const success = useCallback((msg: string) => add(msg, "success"), [add]);
  const error = useCallback((msg: string) => add(msg, "error"), [add]);
  const info = useCallback((msg: string) => add(msg, "info"), [add]);

  return (
    <ToastContext.Provider value={{ success, error, info }}>
      {children}
      <div className="fixed top-4 right-4 z-[9999] flex flex-col gap-2 pointer-events-none">
        {toasts.map((t) => (
          <ToastCard key={t.id} toast={t} onDismiss={() => dismiss(t.id)} />
        ))}
      </div>
    </ToastContext.Provider>
  );
}

const typeConfig = {
  success: {
    icon: CheckCircle,
    border: "border-l-green-500",
    iconClass: "text-green-500",
    bar: "bg-green-500",
  },
  error: {
    icon: AlertCircle,
    border: "border-l-red-500",
    iconClass: "text-red-500",
    bar: "bg-red-500",
  },
  info: {
    icon: Info,
    border: "border-l-blue-500",
    iconClass: "text-blue-500",
    bar: "bg-blue-500",
  },
};

function ToastCard({ toast, onDismiss }: { toast: ToastItem; onDismiss: () => void }) {
  const { icon: Icon, border, iconClass, bar } = typeConfig[toast.type];
  return (
    <div
      className={`pointer-events-auto w-80 bg-white rounded-xl shadow-raised border border-gray-200 border-l-4 ${border} overflow-hidden ${
        toast.dismissing ? "animate-slide-out-right" : "animate-slide-in-right"
      }`}
    >
      <div className="flex items-start gap-3 px-4 py-3">
        <Icon className={`w-5 h-5 mt-0.5 shrink-0 ${iconClass}`} />
        <p className="text-sm text-gray-800 flex-1 leading-snug">{toast.message}</p>
        <button
          onClick={onDismiss}
          className="text-gray-400 hover:text-gray-600 transition-colors shrink-0 mt-0.5"
        >
          <X className="w-4 h-4" />
        </button>
      </div>
      <div className={`h-0.5 ${bar} animate-drain`} />
    </div>
  );
}
