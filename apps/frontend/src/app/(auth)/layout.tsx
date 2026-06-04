import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Sign In',
};

export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return <div className="min-h-screen w-full bg-white">{children}</div>;
}
