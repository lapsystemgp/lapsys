'use client';

import { useRouter } from 'next/navigation';
import { LandingPage } from '../teslty/components/LandingPage';
import type { Page, UserRole } from '../teslty/types';

export default function HomePage() {
  const router = useRouter();
  const userRole: UserRole = null;

  const handleNavigate = (page: Page) => {
    switch (page) {
      case 'landing':
        router.push('/');
        break;
      case 'labs':
        router.push('/labs');
        break;
      case 'lab-details':
        router.push('/labs/1');
        break;
      case 'booking':
        router.push('/booking');
        break;
      case 'user-dashboard':
        router.push('/patient/dashboard');
        break;
      case 'lab-dashboard':
        router.push('/lab/dashboard');
        break;
      case 'login':
        router.push('/login');
        break;
      default:
        router.push('/');
    }
  };

  return (
    <LandingPage
      onSearch={(query) => router.push(`/labs?q=${encodeURIComponent(query)}`)}
      onNavigate={handleNavigate}
      userRole={userRole}
      onLogout={() => router.push('/login')}
      onLabSelect={(lab) => router.push(`/labs/${lab.id}`)}
    />
  );
}
