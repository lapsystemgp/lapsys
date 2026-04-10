export type Page =
  | 'landing'
  | 'labs'
  | 'lab-details'
  | 'booking'
  | 'user-dashboard'
  | 'lab-dashboard'
  | 'admin-dashboard'
  | 'login';

export type UserRole = 'patient' | 'lab' | 'admin' | null;
