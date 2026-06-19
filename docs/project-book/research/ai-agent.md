# The TesTly AI Assistant — End-to-End Architecture

This chapter documents the AI assistant subsystem of **TesTly**, a medical lab-testing
marketplace for Egypt. TesTly ships **two distinct conversational features** that are
easy to confuse but serve different purposes:

1. **The "Health Assistant"** — a true *agentic* LLM assistant powered by Google Gemini.
   It explains lab tests, answers wellness questions, and — crucially — calls **tools** to
   look up real labs and tests from the catalog, surfacing them to the user as structured
   **lab/test cards**. It streams its replies token-by-token. This is the patient-facing
   "AI agent." (Backend: `apps/backend/src/chat/`.)
2. **The "Guided FAQ" chatbot** — a deterministic, **non-LLM** bot that matches the
   user's question against a curated, seeded FAQ knowledge base in the database. It is a
   keyword search dressed up as a chat widget, with no AI model involved at all.
   (Backend: `apps/backend/src/faq/`.)

Both are reached from the web app (`apps/frontend`) and the agentic assistant is also in
the Flutter mobile app (`apps/mobile`). The sections below cover each layer with code
citations relative to the repository root.

---

## Overall Assistant Architecture (Diagram in Words)

The agentic Health Assistant follows a streaming, server-orchestrated, function-calling loop:

```
  [Patient]
     │  types "where can I get a CBC in Cairo?"
     ▼
  Web (apps/frontend/src/app/patient/assistant/page.tsx)
  Mobile (apps/mobile/lib/features/patient/assistant/...)
     │  POST /chat/messages  { text, conversationId? }   (Accept: text/event-stream)
     │  (auth via httpOnly JWT cookie / Dio)
     ▼
  ChatController.sendMessage  (apps/backend/src/chat/chat.controller.ts)
     │  sets SSE headers, defines a write(event) → "data: <json>\n\n"
     ▼
  ChatService.streamReply  (apps/backend/src/chat/chat.service.ts)
     1. Resolve/create Conversation  → emit  { type:'meta', conversationId }
     2. Persist the user ChatMessage
     3. Load last 20 messages → map to Gemini Content[]  (role user|model)
     4. FUNCTION-CALLING LOOP (≤ 4 rounds):
        ├─ generateContentStream(gemini-2.5-flash, systemInstruction, tools)
        ├─ for each chunk:
        │     text delta  → emit { type:'delta', text }   (also accumulated)
        │     functionCall → buffered
        ├─ if no functionCalls → final answer, break
        └─ else run each tool (find_labs / search_tests):
              ├─ query Prisma over LabTest + LabProfile (real data)
              ├─ emit { type:'tool', result: <cards> }   to the client
              └─ append functionResponse → next round so the model can summarise
     5. Persist assistant ChatMessage (content + metadata={tools:[...]})
     6. Touch Conversation.updated_at
     7. emit { type:'done', messageId }
     ▼
  Client parses each SSE event:
     meta  → store conversationId
     delta → append text to the streaming assistant bubble
     tool  → append a lab/test card group under the bubble
     done  → mark streaming complete
     error → toast / snackbar, drop empty placeholder
```

The guided FAQ bot is far simpler and **synchronous** (no streaming, no model):

```
  [Patient] → Web ChatBot widget (apps/frontend/src/teslty/components/ChatBot.tsx)
     │  GET  /faq/intents          → quick-topic buttons
     │  POST /faq/ask { question } → keyword search over seeded FaqEntry rows
     ▼
  FaqController → FaqService.ask  (apps/backend/src/faq/)
     └─ returns top FAQ answer + matched list + escalation text
```

Key architectural decisions worth noting up front:

- **The backend, not the client, drives the agent loop.** Tool execution, grounding, and
  persistence all happen server-side; the client is a thin renderer of SSE events. This
  keeps the Gemini API key and the database off the client and lets web + mobile share one
  contract.
- **One streaming HTTP request per user turn**, carrying *four* event types
  (`meta`, `delta`, `tool`, `done`/`error`) over Server-Sent Events. There is no WebSocket.
- **Structured tool output is persisted alongside the text**, so reopening a conversation
  re-hydrates the same lab/test cards (see the `metadata` JSON column).

---

## Data Model: Conversation, ChatMessage, and the `metadata` Tool-Card Payload

The agent's persistence layer is defined in `apps/backend/prisma/schema.prisma` and was
introduced across two migrations:
`prisma/migrations/20260615000000_add_chat_models/` (the tables + `ChatRole` enum) and
`prisma/migrations/20260615120000_add_chat_message_metadata/` (the JSON column, added as
`ALTER TABLE "ChatMessage" ADD COLUMN "metadata" JSONB;`).

**The `ChatRole` enum** (`schema.prisma:373`) has two values, `User` and `Assistant` —
deliberately *not* a "system" or "tool" role, because tool calls are not persisted as
separate messages; only the user's text and the assistant's final text are stored.

**`Conversation`** (`schema.prisma:379`) is a thread owned by one user:

```prisma
model Conversation {
  id         String   @id @default(uuid())
  user_id    String
  title      String?
  created_at DateTime @default(now())
  updated_at DateTime @updatedAt

  user     User          @relation(fields: [user_id], references: [id], onDelete: Cascade)
  messages ChatMessage[]

  @@index([user_id, updated_at])
}
```

The `@@index([user_id, updated_at])` directly supports the conversation list query, which
sorts a user's threads most-recent-first (`ChatService.listConversations`). The `title` is
auto-derived from the first user message via `deriveTitle()` (first ~57 chars + `...`),
and `updated_at` is bumped after every assistant reply so the list stays ordered by recency.
Deleting a user cascades to their conversations.

**`ChatMessage`** (`schema.prisma:393`) is the heart of the persistence story:

```prisma
model ChatMessage {
  id              String   @id @default(uuid())
  conversation_id String
  role            ChatRole
  content         String
  // Structured agentic payload (e.g. lab/test cards the assistant surfaced),
  // shaped as { tools: ToolResult[] }. Null for plain text messages.
  metadata        Json?
  created_at      DateTime @default(now())

  conversation Conversation @relation(fields: [conversation_id], references: [id], onDelete: Cascade)

  @@index([conversation_id, created_at])
}
```

**The `metadata` JSON column is the agentic-card payload.** When the assistant calls a
tool, the resulting cards are saved as `{ tools: ToolResult[] }`. The write site is in
`ChatService.streamReply` (`chat.service.ts:276`):

```ts
const saved = await this.prisma.chatMessage.create({
  data: {
    conversation_id: conversation.id,
    role: ChatRole.Assistant,
    content: answer,
    metadata:
      toolResults.length > 0
        ? ({ tools: toolResults } as unknown as Prisma.InputJsonValue)
        : undefined,
  },
});
```

For plain-text replies `metadata` stays `NULL`. On read, `toMessageDto` +
`extractTools` (`chat.service.ts:457-484`) defensively unwrap the column — checking it is a
non-array object whose `tools` field is an array — and re-attach `tools` to the DTO. This
is *why* a returning user who reopens an old conversation sees the same lab/test cards
re-rendered: the structured output round-trips through Postgres, not just the prose.

The `@@index([conversation_id, created_at])` backs the chronological message fetch
(`getMessages`, `orderBy: { created_at: 'asc' }`) and the history slice used to build the
model prompt.

**Ownership / multi-tenancy.** Every read is gated by `assertOwnership`
(`chat.service.ts:446`), which loads the conversation and throws `NotFoundException`
unless `conversation.user_id === userId`. This both enforces access control and hides
existence (404, not 403) of other users' threads.

---

## The Agentic Tool / Card Mechanism

This is the defining feature of the assistant: it does not merely *talk* about labs and
tests, it *looks them up in the live catalog* and renders them as interactive cards. The
mechanism is Gemini **function calling** wired to **Prisma queries**.

### Tool declarations

Two tools are declared to the model in `TOOL_DECLARATIONS` (`chat.service.ts:98-136`),
using the `@google/genai` `FunctionDeclaration` / `Type` schema types:

- **`find_labs(query, city?)`** — "Find real labs that offer a given test, with price,
  address and rating. Use when the user asks where to get a test, the nearest/cheapest
  lab, or about availability." `query` (required) is the test/panel; `city` (optional)
  narrows the search only if the user named one.
- **`search_tests(query)`** — "Look up tests in the catalog with their lowest price and how
  many labs offer them. Use when the user asks what a test costs, what tests exist, or to
  compare tests."

The comment on the array is telling: *"Schemas are intentionally minimal for reliability."*
A small, unambiguous tool surface makes the model far more reliable at choosing and filling
the right tool than a sprawling schema would.

### The function-calling loop

`streamReply` (`chat.service.ts:188`) runs up to `MAX_TOOL_ROUNDS = 4` iterations
(a *"Safety bound on the function-calling loop so a misbehaving model can't spin"*). Each
round calls `generateContentStream` and consumes the stream chunk-by-chunk:

```ts
for (let round = 0; round < MAX_TOOL_ROUNDS; round++) {
  const stream = await client.models.generateContentStream({
    model: MODEL,
    contents,
    config: {
      systemInstruction: SYSTEM_PROMPT,
      maxOutputTokens: MAX_TOKENS,
      tools: [{ functionDeclarations: TOOL_DECLARATIONS }],
    },
  });

  const calls: Array<{ name: string; args: Record<string, unknown> }> = [];
  for await (const chunk of stream) {
    const delta = chunk.text;
    if (delta) { answer += delta; onEvent({ type: 'delta', text: delta }); }
    for (const fc of chunk.functionCalls ?? []) {
      if (fc.name) calls.push({ name: fc.name, args: fc.args ?? {} });
    }
  }

  if (calls.length === 0) break;            // model produced its final answer

  contents.push({ role: 'model', parts: calls.map((c) => ({
    functionCall: { name: c.name, args: c.args } })) });

  const responseParts: Part[] = [];
  for (const call of calls) {
    const { result, modelPayload } = await this.runTool(call.name, call.args);
    if (result) { toolResults.push(result); onEvent({ type: 'tool', result }); }
    responseParts.push({ functionResponse: { name: call.name, response: modelPayload } });
  }
  contents.push({ role: 'user', parts: responseParts });
}
```

The loop manually maintains the Gemini `contents` conversation: it appends the model's
`functionCall` turn and a synthetic `user` turn carrying the `functionResponse` so the
*next* round has the tool output in context and can write a natural-language summary. The
loop exits as soon as a round yields no function calls (the final prose answer). This
hand-rolled orchestration — rather than an SDK "automatic function calling" helper — is
what lets the server **emit a `tool` SSE event the instant a lookup completes**, so cards
appear in the UI *before* the summarising text streams in.

### The two-headed tool result: `result` (for the UI) vs `modelPayload` (for the model)

`runTool` (`chat.service.ts:300`) returns **two** shapes for every call — a deliberate and
elegant separation:

- `result` — a rich `ToolResult` with full card fields (address, rating, reviews, home
  collection, accreditation, turnaround). This is streamed to the client and saved to
  `metadata`. It is the *render payload*.
- `modelPayload` — a **compact** object the model reads to compose its reply. For
  `find_labs` it deliberately strips down to `{ count, labs: [{ name, priceEgp, city,
  rating, homeCollection }] }`. This is the *reasoning payload*.

Why two? The system prompt instructs the model to *summarise* rather than recite every
field ("The app renders the lab/test cards for you, so do NOT repeat every price and
address"). Feeding the model a trimmed payload reinforces that behaviour and saves tokens,
while the UI still gets the full record.

### Grounding on real lab/test/booking data

Both tools query **live catalog data** via Prisma — there is genuine retrieval-augmented
grounding here, not hallucination.

**`find_labs(query, city?)`** (`chat.service.ts:338`):
- Tokenizes the query (dropping the noise words `test`/`tests` via `tokenize`,
  `chat.service.ts:487`).
- Queries `LabTest` filtered to `is_active: true` and only labs whose
  `LabProfile.onboarding_status === LabOnboardingStatus.Active` — i.e. **only approved,
  live labs surface.** An optional case-insensitive `city contains` filter applies when the
  user named a city.
- Every token must match (`AND` of per-token `OR` over `name`, `category`, `description`),
  giving an all-terms keyword match.
- Rows come back price-ascending; the service keeps the **cheapest matching test per lab**
  (dedup by `lab.id` in a `Map`), then re-sorts **highest-rated first, then cheapest**, and
  caps at `TOOL_RESULT_LIMIT = 6` cards.
- Each card carries `labId` and `labTestId` so the client can deep-link into the lab page.

**`search_tests(query)`** (`chat.service.ts:413`) uses a Prisma `groupBy(['name',
'category'])` aggregation over the same active-lab-filtered set, returning per test the
`_min.price_egp` ("from" price) and `_count._all` (how many labs offer it), ordered by
cheapest, capped at 6. This produces the "X labs, from Y EGP" comparison cards.

So the assistant's grounding source is the **`LabTest` + `LabProfile` catalog** (the same
data that powers the marketplace's search/booking flow). It does **not** read a specific
user's bookings or medical results — by design, since the prompt forbids interpreting an
individual's results.

### The `ToolResult` contract (shared across all layers)

The discriminated union in `chat.service.ts:53-79` is the canonical card contract, mirrored
verbatim in `apps/frontend/src/lib/chatApi.ts` (TypeScript) and
`apps/mobile/.../chat_models.dart` (Freezed/Dart):

```ts
export type ToolResult =
  | { tool: 'find_labs';    query: string; labs: AssistantLabCard[] }
  | { tool: 'search_tests'; query: string; tests: AssistantTestCard[] };
```

`AssistantLabCard` carries `{ labId, labTestId, name, address, city, priceEgp, rating,
reviews, homeCollection, accreditation, turnaroundTime }`; `AssistantTestCard` carries
`{ name, category, minPriceEgp, labCount }`.

---

## Google GenAI Integration: Model, Prompt, and Streaming

### Package, client, and model

- **Package:** `@google/genai` (the newer unified Google GenAI SDK), pinned at `^2.8.0` in
  `apps/backend/package.json`. It is imported *only* in `chat.service.ts` — the FAQ module
  uses no AI at all.
- **Client:** lazily constructed in `getClient()` (`chat.service.ts:144`):
  `new GoogleGenAI({ apiKey })`, where `apiKey = process.env.GEMINI_API_KEY`. If the env
  var is missing it throws `ServiceUnavailableException('AI assistant is not configured.
  Set GEMINI_API_KEY.')`, so a deployment without a key degrades gracefully (the endpoint
  emits an `error` SSE event rather than crashing). The client is memoised on the service
  instance.
- **Model id:** `const MODEL = 'gemini-2.5-flash'` (`chat.service.ts:16`) — Google's fast,
  cost-efficient model, a sensible choice for an interactive, latency-sensitive,
  high-volume student-project assistant.
- **Generation config:** `maxOutputTokens: MAX_TOKENS = 1500`; history capped at
  `HISTORY_LIMIT = 20` most-recent turns (`recent = history.slice(-HISTORY_LIMIT)`) to bound
  prompt size and cost.

### How it is called

The only model call is `client.models.generateContentStream({ model, contents, config })`
(`chat.service.ts:227`). Notable points:

- **Roles are mapped to Gemini's `user`/`model` vocabulary** (`chat.service.ts:217`):
  stored `Assistant` rows become `model`, everything else `user`.
- **The system prompt is passed via `config.systemInstruction`**, not as a content turn.
- **Tools are passed as** `tools: [{ functionDeclarations: TOOL_DECLARATIONS }]`.
- Streaming uses an async iterator (`for await (const chunk of stream)`), reading
  `chunk.text` for token deltas and `chunk.functionCalls` for tool invocations.

### Prompt design — the system prompt (quoted in full)

The single system prompt, `SYSTEM_PROMPT` (`chat.service.ts:25-45`), encodes the
assistant's persona, its agentic policy, and its safety guardrails:

```
You are the TesTly Health Assistant, an in-app AI helper for a medical lab-testing marketplace.

Your role:
- Explain lab tests, what biomarkers/analytes mean, normal ranges in general terms, and how to prepare for a test (e.g. fasting).
- Help users understand the purpose of common panels (CBC, lipid profile, thyroid, HbA1c, etc.).
- Offer general, educational wellness guidance.
- Help users find where to book tests and at what price using the tools available to you.

Agentic behaviour — use your tools, do not guess:
- When the user asks where to get a test, which lab to use, the nearest/cheapest place for a test, or about availability, call `find_labs` to look up real labs from the catalog.
- When the user asks what a test costs, which tests exist, or to compare tests, call `search_tests`.
- Pass the test name (e.g. "CBC", "lipid profile") as the query. Pass a city only if the user named one.
- After a tool returns, give a short natural-language summary. The app renders the lab/test cards for you, so do NOT repeat every price and address as a long list — just summarise (e.g. "I found 3 labs offering a CBC, starting from 120 EGP. See the cards below.").
- If a tool returns no results, say so plainly and suggest broadening the search; never invent labs, prices, or availability.

Hard rules:
- You are NOT a doctor and you do NOT provide diagnoses, treatment plans, drug dosing, or interpretations of a specific person's results as medical fact. For anything that needs clinical judgement, advise the user to consult a licensed physician.
- For urgent or emergency symptoms (chest pain, difficulty breathing, severe bleeding, suicidal thoughts, etc.), tell the user to seek emergency care immediately.
- Never invent specific numeric results, prices, or lab availability you have not been given by a tool.
- Reply in the same language the user writes in (English or Arabic).
- Be concise and conversational. Respond only with the final answer — do not include your reasoning or meta-commentary.
```

The prompt is well-engineered for a medical context and merits discussion in the thesis:

1. **Scoping** — it confines the model to education + marketplace navigation.
2. **Agentic policy** — it tells the model *exactly when* to call each tool and forbids
   guessing, which is the behavioural contract the function-calling loop relies on.
3. **Anti-redundancy** — it offloads detailed rendering to the UI ("The app renders the
   lab/test cards for you"), keeping replies short and avoiding a wall of duplicated data.
4. **Anti-hallucination** — "never invent labs, prices, or availability" pairs with the
   real Prisma grounding to keep claims truthful.
5. **Medical safety** — explicit non-diagnosis and emergency-escalation rules, a critical
   guardrail for a health product.
6. **Bilingual** — mirror the user's language (English/Arabic), important for the Egyptian
   market.

### Streaming vs non-streaming

The assistant is **fully streaming end-to-end**. The backend uses
`generateContentStream` and forwards every Gemini chunk as a `delta` SSE event in real time;
the controller writes raw SSE frames (`data: <json>\n\n`). Both clients incrementally render
those deltas, so the user sees the reply type out word-by-word, and lab/test cards pop in
the moment a tool resolves (a separate `tool` event interleaved with the text deltas). The
final persisted message is only written after the stream completes.

By contrast, the **FAQ bot is non-streaming** — a single synchronous JSON response.

---

## The Guided FAQ Bot (Non-LLM)

The FAQ module (`apps/backend/src/faq/`) is a **deterministic, curated** assistant with
**no AI model** — its `ask` endpoint is even documented in Swagger as the *"Guided FAQ
answer endpoint (non-LLM)"* (`faq.controller.ts:25`). It exists to answer the most common
support questions cheaply and predictably, without burning Gemini tokens or risking
hallucination. Both modules are registered directly as controllers/providers in
`apps/backend/src/app.module.ts` (there are no separate `*.module.ts` files for chat/faq).

### Endpoints

`FaqController` (`faq.controller.ts`) exposes three public routes under `/faq`:

- **`GET /faq/intents`** — returns the four hard-coded *guided intents* (quick-topic
  buttons): `prep-fasting` ("Preparation & fasting"), `pricing-help` ("Pricing and cost"),
  `booking-help` ("Booking help"), `result-timing` ("Result turnaround"). Each has a `query`
  string that pre-fills a search (`faq.service.ts:7-28`).
- **`GET /faq/search?q=&category=&page=&pageSize=`** — paginated keyword search over the
  FAQ table (validated by `FaqSearchQueryDto`: optional `q`/`category`, `page` 1–50,
  `pageSize` 1–20).
- **`POST /faq/ask` { question }** — the "answer me" endpoint used by the chat widget
  (`FaqAskDto`: a string up to 300 chars).

Unlike the agentic `/chat/*` routes (which are guarded by `JwtAuthGuard` + `RolesGuard`
with `@Roles(Role.Patient)`), the FAQ controller has **no guards** — it is open/public help.

### Knowledge base and search logic

The knowledge base is the `FaqEntry` table (`schema.prisma:336`):
`{ id, question, answer, category?, tags[], is_active, created_at, updated_at }`. It is
populated by the seed script `apps/backend/prisma/seed.ts` (the `faqEntries` array at
`seed.ts:827`, written via `prisma.faqEntry.createMany` at `seed.ts:1538`). The six seeded
entries cover fasting/preparation, result turnaround, home collection booking, the "CPC"
bundle, thyroid-panel prep, and data privacy.

`FaqService.search` (`faq.service.ts:38`) builds a Prisma `where` that:
- always requires `is_active: true`;
- optionally filters by exact (case-insensitive) `category`;
- when `q` is present, matches `question contains q` **OR** `answer contains q` **OR**
  `tags hasSome <words>` (splitting the query on whitespace, keeping words longer than one
  char) — a simple, robust keyword/tag match;
- orders by `updated_at desc`, paginates (default page size 8), and returns
  `{ items, pagination: { page, pageSize, totalCount } }`.

`FaqService.ask` (`faq.service.ts:87`) is a thin wrapper: it runs `search` for the question
(top 3), returns the **single best match's answer** plus the `matched` list and an
`escalation` string (*"Need more help? Contact support at support@testly.local or call your
selected lab."*). If nothing matches, it returns a graceful fallback pointing to support.
There is no ranking beyond recency and no semantic understanding — it is intentionally
simple and explainable.

(Behaviour is locked down by unit tests in `faq.service.spec.ts` and
`faq.controller.spec.ts`: intents non-empty, paginated search, and the no-match escalation
path.)

---

## Client Rendering

### Web — agentic assistant (`apps/frontend/src/app/patient/assistant/page.tsx`)

The full-page Health Assistant is a client component. Its SSE plumbing lives in
`apps/frontend/src/lib/chatApi.ts` (`streamChatMessage`), which uses `fetch` with
`credentials: "include"` (the httpOnly JWT cookie), `Accept: text/event-stream`, reads the
`ReadableStream` via a `getReader()`, splits on the blank-line SSE delimiter (`\n\n`), and
`JSON.parse`s each `data:` payload into a typed `ChatStreamEvent`.

The page's `send()` handler optimistically appends a user bubble and an empty streaming
assistant bubble (with a unique `local-assistant-<timestamp>` id — the comment notes a fixed
id "would let later deltas also match the previous assistant bubble and rewrite it"), then
reacts to events:
- `meta` → store `conversationId` (so the next turn continues the thread);
- `delta` → append text to the matching assistant bubble;
- `tool` → push the `ToolResult` into that bubble's `tools` array;
- `done` → clear the `streaming` flag;
- `error` → throw, which surfaces a toast and drops the empty placeholder. A 401 redirects
  to `/login`.

Rendering (`MessageBubble` → `ToolResultCards` → `LabCard`/`TestCard`):
- While streaming with no text yet, a `TypingDots` animation shows.
- `ToolResultCards` switches on `tool.tool`: `find_labs` renders a stack of `LabCard`s,
  `search_tests` renders `TestCard`s; empty result sets render nothing.
- **`LabCard`** is a clickable card → `router.push('/labs/${lab.labId}')`, showing name,
  city/address, "from" price in EGP, a star rating with review count, a "Home collection"
  badge, and accreditation. **`TestCard`** → `router.push('/tests/<name>?category=<cat>')`,
  showing category, lab count, and min price. These deep links turn the assistant into an
  on-ramp to the booking funnel.
- An `EmptyState` offers three suggestion chips ("How do I prepare for a fasting blood
  test?", "What does a CBC test measure?", "What is HbA1c used for?") and a persistent
  disclaimer ("AI assistant — not a substitute for professional medical advice.").

### Web — guided FAQ widget (`apps/frontend/src/teslty/components/ChatBot.tsx`)

A floating bottom-right bubble mounted globally in `apps/frontend/src/components/AppShell.tsx`
(`<ChatBot isOpen={isChatOpen} ... />`). On open it calls `fetchFaqIntents()` (from
`apps/frontend/src/lib/faqApi.ts`) to render quick-topic buttons (with a hard-coded fallback
list if the call fails). Sending a message calls `askFaq(text)` → `POST /faq/ask`, and
appends the returned `answer` (with the `escalation` text joined on) as a bot bubble. It is
explicitly labelled **"Guided FAQ"** in its header, distinguishing it from the AI assistant.
This is a plain request/response widget — no streaming, no cards, no auth.

### Mobile — agentic assistant (`apps/mobile/lib/features/patient/assistant/`)

The Flutter app implements the **same agentic assistant** (the FAQ bot is web-only; no FAQ
usage exists under `apps/mobile/lib`). Its layers mirror the web contract:

- **`data/chat_models.dart`** — Freezed/`json_serializable` models that mirror the backend
  union exactly: `AssistantConversation`, `AssistantMessage` (with `tools`, `isStreaming`),
  `AssistantLabCard`, `AssistantTestCard`, and `ToolResult` (discriminated by the `tool`
  string, with `labs`/`tests` lists).
- **`data/chat_repository.dart`** — uses **Dio** with `responseType: ResponseType.stream`
  and `Accept: text/event-stream` to `POST /chat/messages` (2-minute receive timeout). It
  decodes the byte stream, splits on `\n\n`, concatenates `data:` lines, and `yield`s parsed
  `Map` events — the Dart analogue of the web SSE parser. It also exposes
  `listConversations` and `getMessages`.
- **`application/chat_notifier.dart`** — a Riverpod `Notifier<ChatState>` that drives the
  same optimistic-bubble pattern (unique `local-assistant-<micros>` id) and the same
  `meta`/`delta`/`tool`/`done`/`error` switch. `tool` events are parsed via
  `ToolResult.fromJson` and appended to the message's `tools`. It guards against streams
  that end without a terminal event (`onDone` finalises the placeholder).
- **`presentation/assistant_screen.dart`** — renders bubbles, a custom animated
  `_TypingIndicator`, and `_ToolResultCards` → `_LabCard`/`_TestCard`. The cards deep-link
  via `go_router` to `/patient/labs/<labId>` and
  `/patient/tests/<name>?category=<cat>` — the mobile equivalents of the web routes. The
  screen is brightness-aware (light/dark palette helpers) and fully localised
  (`AppLocalizations`: `assistantTitle`, suggestions, disclaimer, etc.), reinforcing the
  bilingual EN/AR design the system prompt also targets.

The takeaway: **web and mobile are interchangeable renderers of one server-defined SSE +
card contract.** All intelligence, tool execution, grounding, and persistence live in the
backend; the clients differ only in framework (React vs Flutter) and styling.

---

## Summary of Design Rationale (for the thesis)

- **Server-side agent loop over client-side** keeps secrets (API key, DB) safe, centralises
  guardrails, and lets two client platforms share one streaming contract.
- **Function calling grounded in real Prisma queries** makes the assistant trustworthy: it
  surfaces only active, approved labs and real catalog prices, and the prompt forbids
  inventing data — addressing the single biggest risk of an LLM in a medical/commercial
  product (hallucinated facts).
- **The two-payload tool result** (`result` for the UI, compact `modelPayload` for the
  model) cleanly separates presentation from reasoning and controls token cost.
- **Persisting tool cards in `ChatMessage.metadata`** means conversations are fully
  reproducible — text *and* structured cards survive a reload.
- **A separate non-LLM FAQ bot** handles the long tail of cheap, predictable support
  questions deterministically, reserving the (paid) Gemini agent for genuinely open-ended,
  catalog-aware help.
- **Bounded everything** — 20-turn history, 1500 output tokens, 4 tool rounds, 6 cards per
  tool — gives predictable latency and cost, appropriate for a graduation-project budget.
