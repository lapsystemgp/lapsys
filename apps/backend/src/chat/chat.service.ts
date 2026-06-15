import {
  Injectable,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { GoogleGenAI } from '@google/genai';
import { ChatRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

const MODEL = 'gemini-2.5-flash';
const MAX_TOKENS = 1500;
/** Cap how much history we send to the model (most recent turns). */
const HISTORY_LIMIT = 20;

const SYSTEM_PROMPT = `You are the TesTly Health Assistant, an in-app AI helper for a medical lab-testing marketplace.

Your role:
- Explain lab tests, what biomarkers/analytes mean, normal ranges in general terms, and how to prepare for a test (e.g. fasting).
- Help users understand the purpose of common panels (CBC, lipid profile, thyroid, HbA1c, etc.).
- Offer general, educational wellness guidance.
- When relevant, suggest the user book the appropriate test through the TesTly app or discuss results with the lab.

Hard rules:
- You are NOT a doctor and you do NOT provide diagnoses, treatment plans, drug dosing, or interpretations of a specific person's results as medical fact. For anything that needs clinical judgement, advise the user to consult a licensed physician.
- For urgent or emergency symptoms (chest pain, difficulty breathing, severe bleeding, suicidal thoughts, etc.), tell the user to seek emergency care immediately.
- Never invent specific numeric results, prices, or lab availability you have not been given.
- Reply in the same language the user writes in (English or Arabic).
- Be concise and conversational. Respond only with the final answer — do not include your reasoning or meta-commentary.`;

export interface ConversationSummary {
  id: string;
  title: string | null;
  updatedAt: string;
}

export interface ChatMessageDto {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  createdAt: string;
}

/** Events emitted over the SSE stream, serialized as `data: <json>\n\n`. */
export type StreamEvent =
  | { type: 'meta'; conversationId: string }
  | { type: 'delta'; text: string }
  | { type: 'done'; messageId: string }
  | { type: 'error'; message: string };

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
   * Streams an assistant reply. Persists the user message immediately, streams
   * the model output via `onEvent`, then persists the assistant message.
   * Returns nothing — all output flows through `onEvent`.
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
    const contents = recent.map((m) => ({
      role: m.role === ChatRole.Assistant ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));

    let answer = '';
    const stream = await this.getClient().models.generateContentStream({
      model: MODEL,
      contents,
      config: {
        systemInstruction: SYSTEM_PROMPT,
        maxOutputTokens: MAX_TOKENS,
        // Skip the model's internal "thinking" pass for snappier chat replies.
        thinkingConfig: { thinkingBudget: 0 },
      },
    });
    for await (const chunk of stream) {
      const delta = chunk.text;
      if (delta) {
        answer += delta;
        onEvent({ type: 'delta', text: delta });
      }
    }

    const saved = await this.prisma.chatMessage.create({
      data: {
        conversation_id: conversation.id,
        role: ChatRole.Assistant,
        content: answer,
      },
    });
    await this.prisma.conversation.update({
      where: { id: conversation.id },
      data: { updated_at: new Date() },
    });

    onEvent({ type: 'done', messageId: saved.id });
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
  created_at: Date;
}): ChatMessageDto {
  return {
    id: m.id,
    role: m.role === ChatRole.Assistant ? 'assistant' : 'user',
    content: m.content,
    createdAt: m.created_at.toISOString(),
  };
}

function deriveTitle(text: string): string {
  const trimmed = text.trim().replace(/\s+/g, ' ');
  return trimmed.length > 60 ? `${trimmed.slice(0, 57)}...` : trimmed;
}
