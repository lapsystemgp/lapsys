"use client";

import {
  ArrowLeft,
  ArrowUp,
  FlaskConical,
  HeartPulse,
  Home,
  MapPin,
  Plus,
  Star,
} from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { Breadcrumb } from "../../../components/Breadcrumb";
import { useSession } from "../../../components/SessionProvider";
import { useToast } from "../../../components/ToastProvider";
import { ApiError } from "../../../lib/api";
import {
  streamChatMessage,
  type AssistantLabCard,
  type AssistantMessage,
  type AssistantTestCard,
  type ToolResult,
} from "../../../lib/chatApi";

type UiMessage = AssistantMessage & { streaming?: boolean };

const SUGGESTIONS = [
  "How do I prepare for a fasting blood test?",
  "What does a CBC test measure?",
  "What is HbA1c used for?",
];

const DISCLAIMER =
  "AI assistant — not a substitute for professional medical advice.";

export default function PatientAssistantPage() {
  const router = useRouter();
  const { user } = useSession();
  const toast = useToast();

  const [messages, setMessages] = useState<UiMessage[]>([]);
  const [conversationId, setConversationId] = useState<string | undefined>();
  const [input, setInput] = useState("");
  const [isStreaming, setIsStreaming] = useState(false);

  const scrollRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = useCallback(() => {
    requestAnimationFrame(() => {
      const el = scrollRef.current;
      if (el) el.scrollTop = el.scrollHeight;
    });
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages, scrollToBottom]);

  const startNewChat = useCallback(() => {
    if (isStreaming) return;
    setMessages([]);
    setConversationId(undefined);
  }, [isStreaming]);

  const send = useCallback(
    async (raw: string) => {
      const text = raw.trim();
      if (!text || isStreaming) return;

      setInput("");
      setIsStreaming(true);

      const stamp = Date.now();
      const userMessage: UiMessage = {
        id: `local-user-${stamp}`,
        role: "user",
        content: text,
      };
      // Unique per send — a fixed id would let later deltas also match the
      // previous assistant bubble and rewrite it.
      const assistantId = `local-assistant-${stamp}`;
      setMessages((prev) => [
        ...prev,
        userMessage,
        { id: assistantId, role: "assistant", content: "", streaming: true },
      ]);

      try {
        await streamChatMessage({ text, conversationId }, (event) => {
          switch (event.type) {
            case "meta":
              setConversationId(event.conversationId);
              break;
            case "delta":
              setMessages((prev) =>
                prev.map((m) =>
                  m.id === assistantId
                    ? { ...m, content: m.content + event.text }
                    : m,
                ),
              );
              break;
            case "tool":
              setMessages((prev) =>
                prev.map((m) =>
                  m.id === assistantId
                    ? { ...m, tools: [...(m.tools ?? []), event.result] }
                    : m,
                ),
              );
              break;
            case "done":
              setMessages((prev) =>
                prev.map((m) =>
                  m.id === assistantId ? { ...m, streaming: false } : m,
                ),
              );
              break;
            case "error":
              throw new Error(event.message);
          }
        });
        // Clear the streaming flag if the stream ended without a `done` event.
        setMessages((prev) =>
          prev.map((m) =>
            m.id === assistantId ? { ...m, streaming: false } : m,
          ),
        );
      } catch (err) {
        if (err instanceof ApiError && err.status === 401) {
          router.push("/login");
          return;
        }
        const message =
          err instanceof Error ? err.message : "Something went wrong.";
        toast.error(message);
        // Drop the empty assistant placeholder on failure.
        setMessages((prev) =>
          prev.filter(
            (m) => !(m.id === assistantId && m.content.length === 0),
          ),
        );
      } finally {
        setIsStreaming(false);
      }
    },
    [conversationId, isStreaming, router, toast],
  );

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <header className="bg-white/95 backdrop-blur-sm shadow-sm border-b border-gray-100">
        <div className="max-w-3xl mx-auto px-4 py-3 flex justify-between items-center gap-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center text-white shrink-0 shadow-sm">
              <HeartPulse className="w-5 h-5" />
            </div>
            <div>
              <h1 className="text-base font-bold text-gray-900">
                Health Assistant
              </h1>
              <button
                onClick={() => router.push("/patient/dashboard")}
                className="flex items-center gap-1 text-xs text-gray-500 hover:text-blue-600 hover:-translate-x-0.5 transition-all duration-150 font-medium mt-0.5"
              >
                <ArrowLeft className="w-3 h-3" />
                Back to Dashboard
              </button>
            </div>
          </div>
          <button
            onClick={startNewChat}
            disabled={isStreaming || messages.length === 0}
            className="flex items-center gap-1.5 px-3 py-1.5 text-sm border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-blue-300 transition-all duration-150 font-medium text-gray-700 disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <Plus className="w-4 h-4" />
            New chat
          </button>
        </div>
      </header>

      <main className="flex-1 w-full max-w-3xl mx-auto px-4 py-4 flex flex-col min-h-0">
        <Breadcrumb
          items={[
            { label: "Patient Dashboard", href: "/patient/dashboard" },
            { label: "Health Assistant" },
          ]}
          className="mb-3"
        />

        <div
          ref={scrollRef}
          className="flex-1 overflow-y-auto rounded-2xl bg-white border border-gray-200 shadow-sm p-4"
        >
          {messages.length === 0 ? (
            <EmptyState onSuggestion={send} userName={user?.patient_profile?.full_name} />
          ) : (
            <div className="flex flex-col gap-3">
              {messages.map((m) => (
                <MessageBubble key={m.id} message={m} />
              ))}
            </div>
          )}
        </div>

        <form
          onSubmit={(e) => {
            e.preventDefault();
            send(input);
          }}
          className="mt-3"
        >
          <div className="flex items-end gap-2">
            <textarea
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter" && !e.shiftKey) {
                  e.preventDefault();
                  send(input);
                }
              }}
              rows={1}
              placeholder="Ask about a test, prep, or your health…"
              className="flex-1 resize-none rounded-2xl border border-gray-200 bg-white px-4 py-3 text-sm text-gray-900 shadow-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 max-h-40"
            />
            <button
              type="submit"
              disabled={isStreaming || input.trim().length === 0}
              className="h-11 w-11 shrink-0 flex items-center justify-center rounded-full bg-blue-600 text-white hover:bg-blue-700 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
              aria-label="Send"
            >
              <ArrowUp className="w-5 h-5" />
            </button>
          </div>
          <p className="mt-2 text-center text-xs text-gray-400">{DISCLAIMER}</p>
        </form>
      </main>
    </div>
  );
}

function MessageBubble({ message }: { message: UiMessage }) {
  const isUser = message.role === "user";
  const showTyping = message.streaming && message.content.length === 0;
  const tools = message.tools ?? [];

  return (
    <div className={`flex flex-col ${isUser ? "items-end" : "items-start"}`}>
      {(message.content.length > 0 || showTyping) && (
        <div
          className={`max-w-[80%] rounded-2xl px-4 py-2.5 text-sm leading-relaxed whitespace-pre-wrap ${
            isUser
              ? "bg-blue-600 text-white rounded-br-sm"
              : "bg-gray-100 text-gray-900 rounded-bl-sm"
          }`}
        >
          {showTyping ? <TypingDots /> : message.content}
        </div>
      )}
      {tools.length > 0 && (
        <div className="mt-2 w-full max-w-[90%] flex flex-col gap-2">
          {tools.map((tool, i) => (
            <ToolResultCards key={i} tool={tool} />
          ))}
        </div>
      )}
    </div>
  );
}

function ToolResultCards({ tool }: { tool: ToolResult }) {
  if (tool.tool === "find_labs") {
    if (tool.labs.length === 0) return null;
    return (
      <div className="flex flex-col gap-2">
        {tool.labs.map((lab) => (
          <LabCard key={lab.labId} lab={lab} />
        ))}
      </div>
    );
  }
  if (tool.tests.length === 0) return null;
  return (
    <div className="flex flex-col gap-2">
      {tool.tests.map((test) => (
        <TestCard key={`${test.name}-${test.category}`} test={test} />
      ))}
    </div>
  );
}

function LabCard({ lab }: { lab: AssistantLabCard }) {
  const router = useRouter();
  return (
    <button
      onClick={() => router.push(`/labs/${lab.labId}`)}
      className="text-left rounded-xl border border-gray-200 bg-white p-3 shadow-sm hover:border-blue-300 hover:shadow transition-all duration-150"
    >
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2 min-w-0">
          <div className="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
            <FlaskConical className="w-4 h-4" />
          </div>
          <div className="min-w-0">
            <p className="font-semibold text-gray-900 text-sm truncate">
              {lab.name}
            </p>
            <p className="text-xs text-gray-500 flex items-center gap-1 truncate">
              <MapPin className="w-3 h-3 shrink-0" />
              {lab.city ?? lab.address}
            </p>
          </div>
        </div>
        {lab.priceEgp != null && (
          <div className="text-right shrink-0">
            <p className="text-sm font-bold text-blue-600">{lab.priceEgp} EGP</p>
            <p className="text-[10px] text-gray-400">from</p>
          </div>
        )}
      </div>
      <div className="mt-2 flex flex-wrap items-center gap-2 text-xs text-gray-500">
        {lab.rating != null && (
          <span className="inline-flex items-center gap-1">
            <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
            {lab.rating.toFixed(1)}
            <span className="text-gray-400">({lab.reviews})</span>
          </span>
        )}
        {lab.homeCollection && (
          <span className="inline-flex items-center gap-1 text-emerald-600">
            <Home className="w-3 h-3" />
            Home collection
          </span>
        )}
        {lab.accreditation && (
          <span className="px-1.5 py-0.5 rounded bg-gray-100 text-gray-600">
            {lab.accreditation}
          </span>
        )}
      </div>
    </button>
  );
}

function TestCard({ test }: { test: AssistantTestCard }) {
  const router = useRouter();
  return (
    <button
      onClick={() =>
        router.push(
          `/tests/${encodeURIComponent(test.name)}?category=${encodeURIComponent(test.category)}`,
        )
      }
      className="text-left rounded-xl border border-gray-200 bg-white p-3 shadow-sm hover:border-blue-300 hover:shadow transition-all duration-150 flex items-center justify-between gap-2"
    >
      <div className="min-w-0">
        <p className="font-semibold text-gray-900 text-sm truncate">
          {test.name}
        </p>
        <p className="text-xs text-gray-500">
          {test.category} · {test.labCount}{" "}
          {test.labCount === 1 ? "lab" : "labs"}
        </p>
      </div>
      {test.minPriceEgp != null && (
        <div className="text-right shrink-0">
          <p className="text-sm font-bold text-blue-600">
            {test.minPriceEgp} EGP
          </p>
          <p className="text-[10px] text-gray-400">from</p>
        </div>
      )}
    </button>
  );
}

function TypingDots() {
  return (
    <span className="inline-flex items-center gap-1 py-1">
      {[0, 150, 300].map((delay) => (
        <span
          key={delay}
          className="w-1.5 h-1.5 rounded-full bg-gray-400 animate-bounce"
          style={{ animationDelay: `${delay}ms` }}
        />
      ))}
    </span>
  );
}

function EmptyState({
  onSuggestion,
  userName,
}: {
  onSuggestion: (text: string) => void;
  userName?: string | null;
}) {
  return (
    <div className="h-full flex flex-col items-center justify-center text-center py-8">
      <div className="w-16 h-16 rounded-full bg-blue-600 flex items-center justify-center text-white shadow-sm">
        <HeartPulse className="w-8 h-8" />
      </div>
      <h2 className="mt-4 text-lg font-bold text-gray-900">
        {userName ? `Hi ${userName}!` : "Hi!"} I&apos;m your health assistant
      </h2>
      <p className="mt-1 max-w-md text-sm text-gray-600">
        Ask me about lab tests, how to prepare, or what a result generally
        means. I can&apos;t replace a doctor&apos;s advice.
      </p>
      <div className="mt-5 w-full max-w-md flex flex-col gap-2">
        {SUGGESTIONS.map((s) => (
          <button
            key={s}
            onClick={() => onSuggestion(s)}
            className="text-left px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-700 hover:bg-gray-50 hover:border-blue-300 transition-all duration-150"
          >
            {s}
          </button>
        ))}
      </div>
    </div>
  );
}
