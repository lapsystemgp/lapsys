import { useEffect, useState } from 'react';
import { MessageCircle, X, Send, Bot } from 'lucide-react';
import { askFaq, fetchFaqIntents, type FaqIntent } from '../../lib/faqApi';

interface ChatBotProps {
  isOpen: boolean;
  onToggle: () => void;
}

interface Message {
  id: number;
  text: string;
  sender: 'user' | 'bot';
  timestamp: Date;
}

export function ChatBot({ isOpen, onToggle }: ChatBotProps) {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: 1,
      text: "Hi! I'm your TesTly guided assistant. Ask about preparation, booking, pricing, or results.",
      sender: 'bot',
      timestamp: new Date(),
    },
  ]);
  const [inputText, setInputText] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [quickIntents, setQuickIntents] = useState<FaqIntent[]>([]);

  useEffect(() => {
    fetchFaqIntents()
      .then((response) => setQuickIntents(response.items))
      .catch(() => {
        setQuickIntents([
          { id: 'fallback-1', label: 'Preparation & fasting', query: 'fasting preparation' },
          { id: 'fallback-2', label: 'Booking help', query: 'booking home collection' },
          { id: 'fallback-3', label: 'Result turnaround', query: 'results turnaround' },
        ]);
      });
  }, []);

  const handleSendMessage = async (text?: string) => {
    const messageText = (text || inputText).trim();
    if (!messageText || isSending) return;

    const userMessage: Message = {
      id: messages.length + 1,
      text: messageText,
      sender: 'user',
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInputText('');
    setIsSending(true);

    try {
      const response = await askFaq(messageText);
      const answer = response.escalation ? `${response.answer}\n\n${response.escalation}` : response.answer;
      const botMessage: Message = {
        id: userMessage.id + 1,
        text: answer,
        sender: 'bot',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, botMessage]);
    } catch {
      const botMessage: Message = {
        id: userMessage.id + 1,
        text: 'I could not reach FAQ service right now. Please try again or contact support@testly.local.',
        sender: 'bot',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, botMessage]);
    } finally {
      setIsSending(false);
    }
  };

  if (!isOpen) {
    return (
      <button
        onClick={onToggle}
        className="fixed bottom-6 right-6 w-14 h-14 bg-blue-600 text-white rounded-full shadow-lg hover:bg-blue-700 flex items-center justify-center z-50"
      >
        <MessageCircle className="w-6 h-6" />
      </button>
    );
  }

  return (
    <div className="fixed bottom-6 right-6 w-96 h-[600px] bg-white rounded-2xl shadow-2xl flex flex-col z-50">
      <div className="bg-gradient-to-r from-blue-600 to-indigo-600 text-white p-4 rounded-t-2xl flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
            <Bot className="w-6 h-6" />
          </div>
          <div>
            <div>TesTly Assistant</div>
            <div className="text-blue-100">Guided FAQ</div>
          </div>
        </div>
        <button onClick={onToggle} className="hover:bg-white/20 p-2 rounded-lg transition-colors" aria-label="Close chat">
          <X className="w-5 h-5" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((message) => (
          <div key={message.id} className={`flex ${message.sender === 'user' ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-[80%] rounded-2xl px-4 py-3 whitespace-pre-line ${message.sender === 'user' ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-900'}`}>
              {message.text}
            </div>
          </div>
        ))}
      </div>

      {messages.length === 1 && (
        <div className="px-4 pb-2">
          <p className="text-gray-600 mb-2">Quick topics:</p>
          <div className="space-y-2">
            {quickIntents.map((intent) => (
              <button
                key={intent.id}
                onClick={() => handleSendMessage(intent.query)}
                className="w-full text-left px-3 py-2 bg-gray-50 hover:bg-gray-100 rounded-lg text-gray-700 transition"
              >
                {intent.label}
              </button>
            ))}
          </div>
        </div>
      )}

      <div className="p-4 border-t border-gray-200">
        <div className="flex gap-2">
          <input
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSendMessage()}
            placeholder="Type your question..."
            className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            onClick={() => handleSendMessage()}
            disabled={isSending}
            className="px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-60"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}