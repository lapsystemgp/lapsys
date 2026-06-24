import {
  Injectable,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import {
  GoogleGenAI,
  Type,
  type Content,
  type FunctionDeclaration,
  type Part,
} from '@google/genai';
import { ChatRole, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { fuzzyFindLabTestsForChat, fuzzySearchTests, tokenize } from '../common/utils/search.utils';

const MODEL = 'gemini-2.5-flash';
const MAX_TOKENS = 1500;
/** Cap how much history we send to the model (most recent turns). */
const HISTORY_LIMIT = 20;
/** Safety bound on the function-calling loop so a misbehaving model can't spin. */
const MAX_TOOL_ROUNDS = 4;
/** How many lab/test cards a single tool call may return. */
const TOOL_RESULT_LIMIT = 6;

const SYSTEM_PROMPT = `You are the TesTly Health Assistant, an in-app AI helper for a medical lab-testing marketplace.

Your role:
- Explain lab tests, what biomarkers/analytes mean, normal ranges in general terms, and how to prepare for a test (e.g. fasting).
- Help users understand the purpose of common panels (CBC, lipid profile, thyroid, HbA1c, etc.).
- Offer general, educational wellness guidance.
- Help users find where to book tests and at what price using the tools available to you.

Agentic behaviour — use your tools, do not guess:
- When the user asks where to get a test, which lab to use, the nearest/cheapest place for a test, or about availability, call \`find_labs\` to look up real labs from the catalog.
- When the user asks what a test costs, which tests exist, or to compare tests, call \`search_tests\`.
- Pass the test name (e.g. "CBC", "lipid profile") as the query. Pass a city only if the user named one.
- After a tool returns, give a short natural-language summary. The app renders the lab/test cards for you, so do NOT repeat every price and address as a long list — just summarise (e.g. "I found 3 labs offering a CBC, starting from 120 EGP. See the cards below.").
- If a tool returns no results, say so plainly and suggest broadening the search; never invent labs, prices, or availability.

Hard rules:
- You are NOT a doctor and you do NOT provide diagnoses, treatment plans, drug dosing, or interpretations of a specific person's results as medical fact. For anything that needs clinical judgement, advise the user to consult a licensed physician.
- For urgent or emergency symptoms (chest pain, difficulty breathing, severe bleeding, suicidal thoughts, etc.), tell the user to seek emergency care immediately.
- Never invent specific numeric results, prices, or lab availability you have not been given by a tool.
- Reply in the same language the user writes in (English or Arabic).
- Be concise and conversational. Respond only with the final answer — do not include your reasoning or meta-commentary.`;

export interface ConversationSummary {
  id: string;
  title: string | null;
  updatedAt: string;
}

/** A lab surfaced by the `find_labs` tool, shaped for the chat UI. */
export interface AssistantLabCard {
  labId: string;
  labTestId: string | null;
  name: string;
  address: string;
  city: string | null;
  priceEgp: number | null;
  rating: number | null;
  reviews: number;
  homeCollection: boolean;
  accreditation: string | null;
  turnaroundTime: string | null;
}

/** An aggregated test surfaced by the `search_tests` tool. */
export interface AssistantTestCard {
  name: string;
  category: string;
  minPriceEgp: number | null;
  labCount: number;
}

/** Structured agentic output attached to an assistant message. */
export type ToolResult =
  | { tool: 'find_labs'; query: string; labs: AssistantLabCard[] }
  | { tool: 'search_tests'; query: string; tests: AssistantTestCard[] };

export interface ChatMessageDto {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  tools?: ToolResult[];
  createdAt: string;
}

/** Events emitted over the SSE stream, serialized as `data: <json>\n\n`. */
export type StreamEvent =
  | { type: 'meta'; conversationId: string }
  | { type: 'delta'; text: string }
  | { type: 'tool'; result: ToolResult }
  | { type: 'done'; messageId: string }
  | { type: 'error'; message: string };

/** Tools the model can call. Schemas are intentionally minimal for reliability. */
const TOOL_DECLARATIONS: FunctionDeclaration[] = [
  {
    name: 'find_labs',
    description:
      'Find real labs that offer a given test, with price, address and rating. Use when the user asks where to get a test, the nearest/cheapest lab, or about availability.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        query: {
          type: Type.STRING,
          description:
            'The test or panel to search for, e.g. "CBC", "lipid profile", "vitamin D".',
        },
        city: {
          type: Type.STRING,
          description:
            'Optional city to limit the search to, only if the user named one.',
        },
      },
      required: ['query'],
    },
  },
  {
    name: 'search_tests',
    description:
      'Look up tests in the catalog with their lowest price and how many labs offer them. Use when the user asks what a test costs, what tests exist, or to compare tests.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        query: {
          type: Type.STRING,
          description:
            'The test name or keyword to search for, e.g. "thyroid", "HbA1c".',
        },
      },
      required: ['query'],
    },
  },
];

@Injectable()
export class ChatService {
  private client: GoogleGenAI | null = null;

  constructor(private readonly prisma: PrismaService) {}

  private getClient(): GoogleGenAI {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new ServiceUnavailableException(
        'AI assistant is not configured. Set GEMINI_API_KEY.',
      );
    }
    if (!this.client) {
      this.client = new GoogleGenAI({ apiKey });
    }
    return this.client;
  }

  async listConversations(userId: string): Promise<ConversationSummary[]> {
    const rows = await this.prisma.conversation.findMany({
      where: { user_id: userId },
      orderBy: { updated_at: 'desc' },
      select: { id: true, title: true, updated_at: true },
    });
    return rows.map((c) => ({
      id: c.id,
      title: c.title,
      updatedAt: c.updated_at.toISOString(),
    }));
  }

  async getMessages(
    userId: string,
    conversationId: string,
  ): Promise<ChatMessageDto[]> {
    await this.assertOwnership(userId, conversationId);
    const rows = await this.prisma.chatMessage.findMany({
      where: { conversation_id: conversationId },
      orderBy: { created_at: 'asc' },
    });
    return rows.map(toMessageDto);
  }

  /**
   * Streams an assistant reply. Persists the user message immediately, runs a
   * function-calling loop (emitting `tool` events with structured cards as the
   * model looks up labs/tests), streams the model text via `onEvent`, then
   * persists the assistant message with any tool results attached.
   */
  async streamReply(
    userId: string,
    text: string,
    conversationId: string | undefined,
    onEvent: (event: StreamEvent) => void,
  ): Promise<void> {
    // Resolve / create the conversation up front so the client always gets an id.
    const conversation = conversationId
      ? await this.assertOwnership(userId, conversationId)
      : await this.prisma.conversation.create({
          data: { user_id: userId, title: deriveTitle(text) },
        });

    onEvent({ type: 'meta', conversationId: conversation.id });

    await this.prisma.chatMessage.create({
      data: {
        conversation_id: conversation.id,
        role: ChatRole.User,
        content: text,
      },
    });

    const history = await this.prisma.chatMessage.findMany({
      where: { conversation_id: conversation.id },
      orderBy: { created_at: 'asc' },
    });
    const recent = history.slice(-HISTORY_LIMIT);
    // Gemini uses 'user' / 'model' roles in its content list.
    const contents: Content[] = recent.map((m) => ({
      role: m.role === ChatRole.Assistant ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));

    const client = this.getClient();
    const toolResults: ToolResult[] = [];
    let answer = '';

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
        if (delta) {
          answer += delta;
          onEvent({ type: 'delta', text: delta });
        }
        for (const fc of chunk.functionCalls ?? []) {
          if (fc.name) {
            calls.push({ name: fc.name, args: fc.args ?? {} });
          }
        }
      }

      // No tool calls this round → the model produced its final answer.
      if (calls.length === 0) break;

      // Record the model's tool-call turn so the follow-up call has context.
      contents.push({
        role: 'model',
        parts: calls.map((c) => ({
          functionCall: { name: c.name, args: c.args },
        })),
      });

      const responseParts: Part[] = [];
      for (const call of calls) {
        const { result, modelPayload } = await this.runTool(call.name, call.args);
        if (result) {
          toolResults.push(result);
          onEvent({ type: 'tool', result });
        }
        responseParts.push({
          functionResponse: { name: call.name, response: modelPayload },
        });
      }
      contents.push({ role: 'user', parts: responseParts });
    }

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
    await this.prisma.conversation.update({
      where: { id: conversation.id },
      data: { updated_at: new Date() },
    });

    onEvent({ type: 'done', messageId: saved.id });
  }

  /**
   * Executes a tool call. Returns `result` (structured cards for the UI, or null
   * when there's nothing to render) and `modelPayload` (a compact object the
   * model reads to compose its reply).
   */
  private async runTool(
    name: string,
    args: Record<string, unknown>,
  ): Promise<{ result: ToolResult | null; modelPayload: Record<string, unknown> }> {
    const query = typeof args.query === 'string' ? args.query.trim() : '';
    if (!query) {
      return { result: null, modelPayload: { error: 'query is required' } };
    }

    if (name === 'find_labs') {
      const city = typeof args.city === 'string' ? args.city.trim() : undefined;
      const labs = await this.findLabs(query, city);
      const result: ToolResult = { tool: 'find_labs', query, labs };
      return {
        result,
        modelPayload: {
          count: labs.length,
          labs: labs.map((l) => ({
            name: l.name,
            priceEgp: l.priceEgp,
            city: l.city,
            rating: l.rating,
            homeCollection: l.homeCollection,
          })),
        },
      };
    }

    if (name === 'search_tests') {
      const tests = await this.searchTests(query);
      const result: ToolResult = { tool: 'search_tests', query, tests };
      return { result, modelPayload: { count: tests.length, tests } };
    }

    return { result: null, modelPayload: { error: `Unknown tool: ${name}` } };
  }

  /** Active labs offering a test matching `query`, cheapest matching test per lab. */
  private async findLabs(query: string, city?: string): Promise<AssistantLabCard[]> {
    const tokens = tokenize(query);
    if (tokens.length === 0) return [];

    // Step 1: fuzzy-find matching test rows (lab_id, test_id, price).
    const matchingRows = await fuzzyFindLabTestsForChat(this.prisma, tokens, city);
    if (matchingRows.length === 0) return [];

    const testIds = matchingRows.map((r) => r.test_id);

    // Step 2: enrich with full lab profile via typed Prisma query.
    const tests = await this.prisma.labTest.findMany({
      where: { id: { in: testIds } },
      orderBy: { price_egp: 'asc' },
      select: {
        id: true,
        price_egp: true,
        turnaround_time: true,
        lab_profile: {
          select: {
            id: true,
            lab_name: true,
            address: true,
            city: true,
            rating_average: true,
            review_count: true,
            home_collection: true,
            accreditation: true,
            turnaround_time: true,
          },
        },
      },
    });

    // Keep only the cheapest matching test per lab (rows are price-ascending).
    const byLab = new Map<string, AssistantLabCard>();
    for (const t of tests) {
      const lab = t.lab_profile;
      if (byLab.has(lab.id)) continue;
      byLab.set(lab.id, {
        labId: lab.id,
        labTestId: t.id,
        name: lab.lab_name,
        address: lab.address,
        city: lab.city ?? null,
        priceEgp: t.price_egp,
        rating: lab.rating_average ?? null,
        reviews: lab.review_count ?? 0,
        homeCollection: lab.home_collection,
        accreditation: lab.accreditation ?? null,
        turnaroundTime: t.turnaround_time ?? lab.turnaround_time ?? null,
      });
    }

    return [...byLab.values()]
      .sort((a, b) => {
        const ar = a.rating ?? -1;
        const br = b.rating ?? -1;
        if (br !== ar) return br - ar;
        return (a.priceEgp ?? Infinity) - (b.priceEgp ?? Infinity);
      })
      .slice(0, TOOL_RESULT_LIMIT);
  }

  /** Aggregated catalog tests matching `query`, with min price and lab count. */
  private async searchTests(query: string): Promise<AssistantTestCard[]> {
    const tokens = tokenize(query);
    if (tokens.length === 0) return [];
    const rows = await fuzzySearchTests(this.prisma, tokens);
    return rows.slice(0, TOOL_RESULT_LIMIT).map((r) => ({
      name: r.name,
      category: r.category,
      minPriceEgp: r.minPriceEgp,
      labCount: r.labCount,
    }));
  }

  private async assertOwnership(userId: string, conversationId: string) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
    });
    if (!conversation || conversation.user_id !== userId) {
      throw new NotFoundException('Conversation not found');
    }
    return conversation;
  }
}

function toMessageDto(m: {
  id: string;
  role: ChatRole;
  content: string;
  metadata: Prisma.JsonValue | null;
  created_at: Date;
}): ChatMessageDto {
  const tools = extractTools(m.metadata);
  return {
    id: m.id,
    role: m.role === ChatRole.Assistant ? 'assistant' : 'user',
    content: m.content,
    ...(tools ? { tools } : {}),
    createdAt: m.created_at.toISOString(),
  };
}

function extractTools(metadata: Prisma.JsonValue | null): ToolResult[] | undefined {
  if (
    metadata &&
    typeof metadata === 'object' &&
    !Array.isArray(metadata) &&
    Array.isArray((metadata as Record<string, unknown>).tools)
  ) {
    return (metadata as unknown as { tools: ToolResult[] }).tools;
  }
  return undefined;
}


function deriveTitle(text: string): string {
  const trimmed = text.trim().replace(/\s+/g, ' ');
  return trimmed.length > 60 ? `${trimmed.slice(0, 57)}...` : trimmed;
}
