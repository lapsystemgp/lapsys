'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

interface User {
  id: string;
  email: string;
}

export default function HomePage() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const res = await fetch('http://localhost:3001/auth/profile', {
          credentials: 'include', // Important for HttpOnly cookies
        });
        if (res.ok) {
          const data = await res.json();
          setUser(data);
        }
      } catch (err) {
        console.error('Failed to fetch profile:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-neutral-950 text-white flex items-center justify-center p-8">
        <div className="text-xl text-neutral-400 animate-pulse">Loading...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-neutral-950 text-white flex flex-col items-center justify-center p-8">
      <main className="max-w-4xl w-full text-center space-y-8">
        <h1 className="text-5xl font-extrabold tracking-tight bg-gradient-to-r from-blue-400 to-purple-600 bg-clip-text text-transparent">
          {user ? `Welcome ${user.email}` : 'Welcome to the lap system'}
        </h1>
        <p className="text-xl text-neutral-400">
          {user 
            ? 'You are successfully logged into the system. Explore your profile or protected content.'
            : 'A secure, high-performance authentication system built with Next.js, NestJS, and Prisma.'}
        </p>
        
        <div className="flex flex-wrap justify-center gap-4">
          {user ? (
            <button
              onClick={() => {
                // To logout, we'd ideally hit a logout endpoint that clears the cookie
                // For now, redirecting to login to re-auth
                window.location.href = '/login';
              }}
              className="px-8 py-3 bg-white text-black font-semibold rounded-lg hover:bg-neutral-200 transition-colors"
            >
              Sign Out
            </button>
          ) : (
            <>
              <Link 
                href="/login"
                className="px-8 py-3 bg-white text-black font-semibold rounded-lg hover:bg-neutral-200 transition-colors"
              >
                Sign In
              </Link>
              <Link 
                href="/register"
                className="px-8 py-3 bg-transparent border border-neutral-700 text-white font-semibold rounded-lg hover:bg-neutral-900 transition-colors"
              >
                Create Account
              </Link>
            </>
          )}
        </div>
      </main>
      
      <footer className="mt-16 text-neutral-500 text-sm">
        Built with Google Deepmind Advanced Agentic Coding
      </footer>
    </div>
  );
}
