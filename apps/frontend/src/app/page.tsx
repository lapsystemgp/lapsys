'use client';

import { useRouter } from 'next/navigation';
import { LandingPage } from '../teslty/components/LandingPage';
import type { Page, UserRole } from '../teslty/types';
import { useSession } from '../components/SessionProvider';

export default function HomePage() {
  const router = useRouter();
  const { user, logout } = useSession();

  const userRole: UserRole =
    user?.role === 'Patient'
      ? 'patient'
      : user?.role === 'LabStaff'
        ? 'lab'
        : user?.role === 'Admin'
          ? 'admin'
          : null;

  const userLabel =
    userRole === 'lab'
      ? user?.lab_profile?.lab_name || user?.email
      : userRole === 'admin'
        ? user?.email
      : user?.patient_profile?.full_name || user?.email;

  const handleLogout = async () => {
    await logout();
    router.push('/login');
  };

  const handleNavigate = (page: Page) => {
    switch (page) {
      case 'landing':
        router.push('/');
        break;
      case 'labs':
        router.push('/labs');
        break;
      case 'lab-details':
        router.push('/labs');
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
      case 'admin-dashboard':
        router.push('/admin/dashboard');
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
      onSearch={(query) => router.push(`/labs?q=${encodeURIComponent(query.trim())}`)}
      onNavigate={handleNavigate}
      userRole={userRole}
      currentUserLabel={userLabel}
      onLogout={handleLogout}
      onLabSelect={(lab) => router.push(`/labs/${lab.id}`)}
    />
  );
}
