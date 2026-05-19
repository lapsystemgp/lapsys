"use client";

import { useState } from "react";
import { ChatBot } from "../teslty/components/ChatBot";
import { SessionProvider } from "./SessionProvider";
import { ToastProvider } from "./ToastProvider";

interface AppShellProps {
  children: React.ReactNode;
}

export function AppShell({ children }: AppShellProps) {
  const [isChatOpen, setIsChatOpen] = useState(false);

  return (
    <SessionProvider>
      <ToastProvider>
        {children}
        <ChatBot isOpen={isChatOpen} onToggle={() => setIsChatOpen((open) => !open)} />
      </ToastProvider>
    </SessionProvider>
  );
}
