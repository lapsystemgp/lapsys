"use client";

import { useState } from "react";
import { ChatBot } from "../teslty/components/ChatBot";

interface AppShellProps {
  children: React.ReactNode;
}

export function AppShell({ children }: AppShellProps) {
  const [isChatOpen, setIsChatOpen] = useState(false);

  return (
    <>
      {children}
      <ChatBot isOpen={isChatOpen} onToggle={() => setIsChatOpen((open) => !open)} />
    </>
  );
}
