import { useState } from 'react';
import { MessageCircle, X, Send, Bot } from 'lucide-react';

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
      text: "Hi! I'm your TesTly assistant. I can help you with questions about tests, preparation requirements, and booking appointments. How can I help you today?",
      sender: 'bot',
      timestamp: new Date()
    }
  ]);
  const [inputText, setInputText] = useState('');

  const quickQuestions = [
    'Do I need to fast for a CBC test?',
    'What is included in a lipid profile?',
    'How long does it take to get results?',
    'Can I book a home collection?'
  ];

  const handleSendMessage = (text?: string) => {
    const messageText = text || inputText;
    if (!messageText.trim()) return;

    // Add user message
    const userMessage: Message = {
      id: messages.length + 1,
      text: messageText,
      sender: 'user',
      timestamp: new Date()
    };

    setMessages([...messages, userMessage]);
    setInputText('');

    // Simulate bot response
    setTimeout(() => {
      const botResponse = getBotResponse(messageText);
      const botMessage: Message = {
        id: messages.length + 2,
        text: botResponse,
        sender: 'bot',
        timestamp: new Date()
      };
      setMessages(prev => [...prev, botMessage]);
    }, 1000);
  };

  const getBotResponse = (userMessage: string): string => {
    const lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.includes('fast') || lowerMessage.includes('fasting')) {
      return "For most blood tests like lipid profile and blood sugar, fasting for 8-12 hours is recommended. However, CBC and thyroid tests typically don't require fasting. Always confirm with your specific lab's requirements.";
    }
    if (lowerMessage.includes('lipid') || lowerMessage.includes('cholesterol')) {
      return "A lipid profile includes tests for Total Cholesterol, LDL (bad cholesterol), HDL (good cholesterol), and Triglycerides. It helps assess your risk of heart disease. Fasting for 9-12 hours is required before the test.";
    }
    if (lowerMessage.includes('result') || lowerMessage.includes('how long')) {
      return "Most labs provide results within 24-48 hours. Some tests may take longer depending on complexity. You'll receive your results as a PDF in your dashboard and via email. Premium labs offer faster turnaround times (6-12 hours).";
    }
    if (lowerMessage.includes('home') || lowerMessage.includes('collection')) {
      return "Yes! Many labs offer home sample collection. When searching for tests, you can filter for labs that provide this service. Home collection typically costs an additional EGP 100-200. A trained phlebotomist will come to your address at your scheduled time.";
    }
    if (lowerMessage.includes('cbc') || lowerMessage.includes('complete blood count')) {
      return "A CBC (Complete Blood Count) measures red blood cells, white blood cells, hemoglobin, and platelets. It helps detect anemia, infections, and blood disorders. No fasting is required, and results are usually available within 24 hours.";
    }
    if (lowerMessage.includes('price') || lowerMessage.includes('cost')) {
      return "Test prices vary by lab and location. You can compare prices from multiple labs using our search feature. Generally, CBC costs EGP 350-500, Lipid Profile EGP 500-700, and Thyroid Panel EGP 400-600. Use filters to find the best price!";
    }
    if (lowerMessage.includes('book') || lowerMessage.includes('appointment')) {
      return "To book an appointment: 1) Search for your test, 2) Compare labs and select one, 3) Choose your preferred date and time, 4) Select lab visit or home collection, 5) Confirm your booking. You'll receive confirmation via email.";
    }
    if (lowerMessage.includes('thyroid')) {
      return "A thyroid panel typically includes TSH, T3, and T4 tests. It helps diagnose thyroid disorders. No fasting is required, but it's best to take the test in the morning. Results are usually available within 24-48 hours.";
    }
    if (lowerMessage.includes('diabetes') || lowerMessage.includes('sugar')) {
      return "Common diabetes tests include Fasting Blood Sugar (FBS), HbA1c, and Glucose Tolerance Test (GTT). FBS requires 8-12 hours fasting. HbA1c shows average blood sugar over 3 months and doesn't require fasting.";
    }

    return "I'd be happy to help! You can ask me about test preparations, what's included in specific tests, pricing, booking appointments, or home collection services. You can also search for tests directly on our platform to compare labs and prices.";
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
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-indigo-600 text-white p-4 rounded-t-2xl flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
            <Bot className="w-6 h-6" />
          </div>
          <div>
            <div>TesTly Assistant</div>
            <div className="text-blue-100">Online</div>
          </div>
        </div>
        <button 
          onClick={onToggle} 
          className="hover:bg-white/20 p-2 rounded-lg transition-colors"
          aria-label="Close chat"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${message.sender === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[80%] rounded-2xl px-4 py-3 ${
                message.sender === 'user'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-900'
              }`}
            >
              {message.text}
            </div>
          </div>
        ))}
      </div>

      {/* Quick Questions */}
      {messages.length === 1 && (
        <div className="px-4 pb-2">
          <p className="text-gray-600 mb-2">Quick questions:</p>
          <div className="space-y-2">
            {quickQuestions.map((question, index) => (
              <button
                key={index}
                onClick={() => handleSendMessage(question)}
                className="w-full text-left px-3 py-2 bg-gray-50 hover:bg-gray-100 rounded-lg text-gray-700 transition"
              >
                {question}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Input */}
      <div className="p-4 border-t border-gray-200">
        <div className="flex gap-2">
          <input
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
            placeholder="Type your question..."
            className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            onClick={() => handleSendMessage()}
            className="px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}
