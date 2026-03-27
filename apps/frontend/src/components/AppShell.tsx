"use client";

import { useState } from "react";
import { ChatBot } from "../teslty/components/ChatBot";
import { SessionProvider } from "./SessionProvider";

interface AppShellProps {
  children: React.ReactNode;
}

export function AppShell({ children }: AppShellProps) {
  const [isChatOpen, setIsChatOpen] = useState(false);

  return (
    <SessionProvider>
      {children}
      <ChatBot isOpen={isChatOpen} onToggle={() => setIsChatOpen((open) => !open)} />
    </SessionProvider>
  );
}
