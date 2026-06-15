import { API_BASE_URL, ApiError, apiFetch } from "./api";

export type ChatRole = "user" | "assistant";

export type AssistantConversation = {
  id: string;
  title: string | null;
  updatedAt: string;
};

export type AssistantMessage = {
  id: string;
  role: ChatRole;
  content: string;
  createdAt?: string;
};

/** Events streamed by `POST /chat/messages`, one per SSE `data:` line. */
export type ChatStreamEvent =
  | { type: "meta"; conversationId: string }
  | { type: "delta"; text: string }
  | { type: "done"; messageId: string }
  | { type: "error"; message: string };

export function fetchConversations() {
  return apiFetch<AssistantConversation[]>("/chat/conversations");
}

export function fetchConversationMessages(conversationId: string) {
  return apiFetch<AssistantMessage[]>(
    `/chat/conversations/${conversationId}/messages`,
  );
}

/**
 * Sends a message and invokes `onEvent` for each parsed SSE event as the
 * assistant reply streams in. Uses the httpOnly auth cookie (credentials:
 * include), so it mirrors the rest of the API layer.
 */
export async function streamChatMessage(
  params: { text: string; conversationId?: string; signal?: AbortSignal },
  onEvent: (event: ChatStreamEvent) => void,
): Promise<void> {
  const response = await fetch(`${API_BASE_URL}/chat/messages`, {
    method: "POST",
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      Accept: "text/event-stream",
    },
    body: JSON.stringify({
      text: params.text,
      ...(params.conversationId ? { conversationId: params.conversationId } : {}),
    }),
    signal: params.signal,
  });

  if (!response.ok || !response.body) {
    const bodyText = await response.text().catch(() => undefined);
    throw new ApiError(`Chat request failed: ${response.status}`, {
      status: response.status,
      bodyText,
    });
  }

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = "";

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });

    // SSE events are separated by a blank line.
    let sep = buffer.indexOf("\n\n");
    while (sep !== -1) {
      const event = parseEvent(buffer.slice(0, sep));
      buffer = buffer.slice(sep + 2);
      if (event) onEvent(event);
      sep = buffer.indexOf("\n\n");
    }
  }
}

function parseEvent(raw: string): ChatStreamEvent | null {
  const payload = raw
    .split("\n")
    .filter((line) => line.startsWith("data:"))
    .map((line) => line.slice(5).replace(/^ /, ""))
    .join("\n");
  if (!payload) return null;
  try {
    return JSON.parse(payload) as ChatStreamEvent;
  } catch {
    return null;
  }
}
