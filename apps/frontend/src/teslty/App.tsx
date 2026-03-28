import { useState } from 'react';
import { LandingPage } from './components/LandingPage';
import { LabComparison } from './components/LabComparison';
import { LabDetailsPage } from './components/LabDetailsPage';
import { BookingPage } from './components/BookingPage';
import { UserDashboard } from './components/UserDashboard';
import { LabDashboard } from './components/LabDashboard';
import { LoginPage } from './components/LoginPage';
import { ChatBot } from './components/ChatBot';
import type { Page, UserRole } from './types';
import type { PublicLabCard, PublicTestResponse } from '../lib/publicApi';

export default function App() {
  const [currentPage, setCurrentPage] = useState<Page>('landing');
  const [userRole, setUserRole] = useState<UserRole>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedLab, setSelectedLab] = useState<PublicLabCard | null>(null);
  const [selectedTest, setSelectedTest] = useState<PublicTestResponse | null>(null);
  const [isChatOpen, setIsChatOpen] = useState(false);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setCurrentPage('labs');
  };

  const handleLabSelect = (lab: PublicLabCard) => {
    setSelectedLab(lab);
    setCurrentPage('lab-details');
  };

  const handleLogin = (role: UserRole) => {
    setUserRole(role);
    if (role === 'patient') {
      setCurrentPage('landing');
    } else if (role === 'lab') {
      setCurrentPage('lab-dashboard');
    }
  };

  const handleLogout = () => {
    setUserRole(null);
    setCurrentPage('landing');
  };

  const handleBookFromLabDetails = (
    lab: PublicLabCard,
    test: {
      id: string;
      name: string;
      category: string;
      priceEgp: number;
      description: string | null;
      preparation: string | null;
      turnaroundTime: string | null;
      parametersCount: number | null;
    },
  ) => {
    setSelectedLab(lab);
    setSelectedTest({
      id: test.id,
      name: test.name,
      category: test.category,
      priceEgp: test.priceEgp,
      description: test.description,
      preparation: test.preparation,
      turnaroundTime: test.turnaroundTime,
      parametersCount: test.parametersCount,
      lab: {
        id: lab.id,
        name: lab.name,
        address: lab.address,
        homeCollection: lab.homeCollection,
        accreditation: lab.accreditation,
        turnaroundTime: lab.turnaroundTime,
      },
    });
    setCurrentPage('booking');
  };

  const renderPage = () => {
    switch (currentPage) {
      case 'landing':
        return <LandingPage onSearch={handleSearch} onNavigate={setCurrentPage} userRole={userRole} onLogout={handleLogout} onLabSelect={handleLabSelect} />;
      case 'labs':
        return <LabComparison searchQuery={searchQuery} onLabSelect={handleLabSelect} onBack={() => setCurrentPage('landing')} />;
      case 'lab-details':
        return (
          <LabDetailsPage
            lab={selectedLab}
            tests={[]}
            timeSlots={[]}
            onBack={() => setCurrentPage('landing')}
            onBookTest={handleBookFromLabDetails}
          />
        );
      case 'booking':
        return (
          <BookingPage
            lab={selectedLab}
            test={selectedTest}
            slots={[]}
            onBack={() => setCurrentPage('lab-details')}
            onComplete={() => setCurrentPage('user-dashboard')}
            onSubmit={async () => {}}
          />
        );
      case 'user-dashboard':
        return <UserDashboard onNavigate={setCurrentPage} onLogout={handleLogout} />;
      case 'lab-dashboard':
        return <LabDashboard onLogout={handleLogout} />;
      case 'login':
        return <LoginPage onLogin={handleLogin} onBack={() => setCurrentPage('landing')} />;
      default:
        return <LandingPage onSearch={handleSearch} onNavigate={setCurrentPage} userRole={userRole} onLogout={handleLogout} onLabSelect={handleLabSelect} />;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {renderPage()}
      <ChatBot isOpen={isChatOpen} onToggle={() => setIsChatOpen(!isChatOpen)} />
    </div>
  );
}
