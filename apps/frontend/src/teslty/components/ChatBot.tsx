import { useCallback, useRef, useState } from 'react';
import { MessageCircle, X, Send, Bot, Plus } from 'lucide-react';
import { streamChatMessage, type AssistantMessage } from '../../lib/chatApi';

interface ChatBotProps {
  isOpen: boolean;
  onToggle: () => void;
}

type UiMessage = AssistantMessage & { streaming?: boolean };

const SUGGESTIONS = [
  'How do I prepare for a fasting blood test?',
  'What does a CBC test measure?',
  'What is HbA1c used for?',
];

export function ChatBot({ isOpen, onToggle }: ChatBotProps) {
  const [messages, setMessages] = useState<UiMessage[]>([]);
  const [inputText, setInputText] = useState('');
  const [isStreaming, setIsStreaming] = useState(false);
  const [conversationId, setConversationId] = useState<string | undefined>();
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const startNewChat = useCallback(() => {
    if (isStreaming) return;
    setMessages([]);
    setConversationId(undefined);
  }, [isStreaming]);

  const handleSend = useCallback(
    async (raw?: string) => {
      const text = (raw ?? inputText).trim();
      if (!text || isStreaming) return;

      setInputText('');
      setIsStreaming(true);

      const stamp = Date.now();
      const userMsg: UiMessage = { id: `u-${stamp}`, role: 'user', content: text };
      const assistantId = `a-${stamp}`;

      setMessages((prev) => [
        ...prev,
        userMsg,
        { id: assistantId, role: 'assistant', content: '', streaming: true },
      ]);
      setTimeout(scrollToBottom, 50);

      try {
        await streamChatMessage({ text, conversationId }, (event) => {
          switch (event.type) {
            case 'meta':
              setConversationId(event.conversationId);
              break;
            case 'delta':
              setMessages((prev) =>
                prev.map((m) =>
                  m.id === assistantId ? { ...m, content: m.content + event.text } : m,
                ),
              );
              setTimeout(scrollToBottom, 50);
              break;
            case 'done':
              setMessages((prev) =>
                prev.map((m) => (m.id === assistantId ? { ...m, streaming: false } : m)),
              );
              break;
            case 'error':
              throw new Error(event.message);
          }
        });
        setMessages((prev) =>
          prev.map((m) => (m.id === assistantId ? { ...m, streaming: false } : m)),
        );
      } catch {
        setMessages((prev) =>
          prev.map((m) =>
            m.id === assistantId
              ? { ...m, content: "I couldn't reach the assistant. Please try again.", streaming: false }
              : m,
          ),
        );
      } finally {
        setIsStreaming(false);
      }
    },
    [inputText, isStreaming, conversationId],
  );

  if (!isOpen) {
    return (
      <button
        onClick={onToggle}
        className="fixed bottom-6 right-6 w-14 h-14 bg-blue-600 text-white rounded-full shadow-lg hover:bg-blue-700 flex items-center justify-center z-50"
        aria-label="Open AI assistant"
      >
        <MessageCircle className="w-6 h-6" />
      </button>
    );
  }

  return (
    <div className="fixed bottom-6 right-6 w-96 h-[600px] bg-white rounded-2xl shadow-2xl flex flex-col z-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-indigo-600 text-white p-4 rounded-t-2xl flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
            <Bot className="w-6 h-6" />
          </div>
          <div>
            <div className="font-semibold">TesTly Assistant</div>
            <div className="text-blue-100 text-xs">AI Assistant</div>
          </div>
        </div>
        <div className="flex items-center gap-1">
          <button
            onClick={startNewChat}
            disabled={isStreaming || messages.length === 0}
            className="hover:bg-white/20 p-2 rounded-lg transition-colors disabled:opacity-40"
            aria-label="New chat"
            title="New chat"
          >
            <Plus className="w-4 h-4" />
          </button>
          <button
            onClick={onToggle}
            className="hover:bg-white/20 p-2 rounded-lg transition-colors"
            aria-label="Close chat"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {messages.length === 0 ? (
          <div className="h-full flex flex-col items-center justify-center text-center gap-4 py-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center">
              <Bot className="w-6 h-6" />
            </div>
            <div>
              <p className="font-semibold text-gray-900 text-sm">Hi! I&apos;m your AI assistant</p>
              <p className="text-xs text-gray-500 mt-1">Ask about tests, preparation, or your health.</p>
            </div>
            <div className="w-full space-y-2">
              {SUGGESTIONS.map((s) => (
                <button
                  key={s}
                  onClick={() => handleSend(s)}
                  className="w-full text-left px-3 py-2 bg-gray-50 hover:bg-blue-50 hover:border-blue-200 border border-gray-200 rounded-xl text-gray-700 text-xs transition-colors"
                >
                  {s}
                </button>
              ))}
            </div>
          </div>
        ) : (
          messages.map((m) => {
            const isUser = m.role === 'user';
            const showTyping = m.streaming && m.content.length === 0;
            return (
              <div key={m.id} className={`flex ${isUser ? 'justify-end' : 'justify-start'}`}>
                <div
                  className={`max-w-[82%] rounded-2xl px-4 py-2.5 text-sm leading-relaxed whitespace-pre-wrap ${
                    isUser
                      ? 'bg-blue-600 text-white rounded-br-sm'
                      : 'bg-gray-100 text-gray-900 rounded-bl-sm'
                  }`}
                >
                  {showTyping ? (
                    <span className="inline-flex items-center gap-1 py-1">
                      {[0, 150, 300].map((d) => (
                        <span
                          key={d}
                          className="w-1.5 h-1.5 rounded-full bg-gray-400 animate-bounce"
                          style={{ animationDelay: `${d}ms` }}
                        />
                      ))}
                    </span>
                  ) : (
                    m.content
                  )}
                </div>
              </div>
            );
          })
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t border-gray-200">
        <div className="flex gap-2">
          <input
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && !e.shiftKey && handleSend()}
            placeholder="Ask about a test or your health…"
            className="flex-1 px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
          />
          <button
            onClick={() => handleSend()}
            disabled={isStreaming || inputText.trim().length === 0}
            className="px-4 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 disabled:opacity-50 transition-colors"
            aria-label="Send"
          >
            <Send className="w-4 h-4" />
          </button>
        </div>
        <p className="mt-2 text-center text-[10px] text-gray-400">
          AI assistant — not a substitute for professional medical advice.
        </p>
      </div>
    </div>
  );
}
