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

export default function App() {
  const [currentPage, setCurrentPage] = useState<Page>('landing');
  const [userRole, setUserRole] = useState<UserRole>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedLab, setSelectedLab] = useState<any>(null);
  const [selectedTest, setSelectedTest] = useState<any>(null);
  const [isChatOpen, setIsChatOpen] = useState(false);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setCurrentPage('labs');
  };

  const handleLabSelect = (lab: any) => {
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

  const handleBookFromLabDetails = (lab: any, test: any) => {
    setSelectedLab(lab);
    setSelectedTest(test);
    setCurrentPage('booking');
  };

  const renderPage = () => {
    switch (currentPage) {
      case 'landing':
        return <LandingPage onSearch={handleSearch} onNavigate={setCurrentPage} userRole={userRole} onLogout={handleLogout} onLabSelect={handleLabSelect} />;
      case 'labs':
        return <LabComparison searchQuery={searchQuery} onLabSelect={handleLabSelect} onBack={() => setCurrentPage('landing')} />;
      case 'lab-details':
        return <LabDetailsPage lab={selectedLab} onBack={() => setCurrentPage('landing')} onBookTest={handleBookFromLabDetails} />;
      case 'booking':
        return <BookingPage lab={selectedLab} test={selectedTest} onBack={() => setCurrentPage('lab-details')} onComplete={() => setCurrentPage('user-dashboard')} />;
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
