"use client";

import { useState, useEffect } from 'react';
import { ArrowLeft, TestTube, Mail, Lock, User, Eye, EyeOff } from 'lucide-react';
import { API_BASE_URL } from '../../lib/api';
import { useSession } from '../../components/SessionProvider';
import { useToast } from '../../components/ToastProvider';

interface LoginPageProps {
  onLogin: (role: 'patient' | 'lab' | 'admin') => void;
  onBack: () => void;
  defaultMode?: 'login' | 'register';
  onAuthenticated?: (params: { role: 'patient' | 'lab' | 'admin'; lab_onboarding_status?: string | null }) => void;
  sessionExpired?: boolean;
}

export function LoginPage({ onLogin, onBack, defaultMode = 'login', onAuthenticated, sessionExpired }: LoginPageProps) {
  const toast = useToast();

  useEffect(() => {
    if (sessionExpired) {
      toast.error('Your session has expired. Please sign in again.');
    }
    // Only run on mount
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const [isSignup, setIsSignup] = useState(defaultMode === 'register');
  const [userType, setUserType] = useState<'patient' | 'lab' | 'admin'>('patient');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [labAddress, setLabAddress] = useState('');
  const [labPhone, setLabPhone] = useState('');
  const [labAccreditation, setLabAccreditation] = useState('');
  const [labTurnaroundTime, setLabTurnaroundTime] = useState('');
  const [labHomeCollection, setLabHomeCollection] = useState(true);
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const { refresh } = useSession();

  const normalizeEmail = (value: string) => value.trim().toLowerCase();

  const readRuntimeErrorMessage = (value: unknown) => {
    if (value instanceof Error) {
      return value.message.trim();
    }

    return String(value ?? '').trim();
  };

  const readErrorMessage = async (response: Response, fallback: string) => {
    try {
      const contentType = response.headers.get('content-type') ?? '';
      if (contentType.includes('application/json')) {
        const data = (await response.json()) as { message?: string | string[] };
        if (Array.isArray(data.message)) {
          return data.message.join(', ');
        }
        if (typeof data.message === 'string' && data.message.trim()) {
          return data.message;
        }
      }

      const text = (await response.text()).trim();
      return text || fallback;
    } catch {
      return fallback;
    }
  };

  const handleSubmit = async (e: { preventDefault(): void }) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (isSignup) {
        if (userType === 'patient') {
          const registerRes = await fetch(`${API_BASE_URL}/auth/register/patient`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({
              email: normalizeEmail(email),
              password,
              full_name: name || undefined,
            }),
          });

          if (!registerRes.ok) {
            const msg = await readErrorMessage(registerRes, 'Failed to register');
            throw new Error(msg || 'Failed to register');
          }
        } else {
          if (!labAddress.trim()) {
            throw new Error('Lab address is required');
          }
          if (!name.trim()) {
            throw new Error('Lab name is required');
          }

          const registerRes = await fetch(`${API_BASE_URL}/auth/register/lab`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({
              email: normalizeEmail(email),
              password,
              lab_name: name,
              address: labAddress,
              phone: labPhone || undefined,
              accreditation: labAccreditation.trim() || undefined,
              turnaround_time: labTurnaroundTime.trim() || undefined,
              home_collection: labHomeCollection,
            }),
          });

          if (!registerRes.ok) {
            const msg = await readErrorMessage(registerRes, 'Failed to register');
            throw new Error(msg || 'Failed to register');
          }
        }
      }

      const loginRes = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({
          email: normalizeEmail(email),
          password,
          selectedRole: userType,
        }),
      });

      if (!loginRes.ok) {
        const msg = await readErrorMessage(loginRes, 'Invalid credentials');
        throw new Error(msg || 'Invalid credentials');
      }

      const data = (await loginRes.json()) as {
        user?: { role?: string; lab_onboarding_status?: string | null };
      };

      const role =
        data.user?.role === 'LabStaff'
          ? 'lab'
          : data.user?.role === 'Admin'
            ? 'admin'
            : 'patient';
      const lab_onboarding_status = data.user?.lab_onboarding_status ?? null;

      await refresh();

      if (onAuthenticated) {
        onAuthenticated({ role, lab_onboarding_status });
      } else {
        onLogin(role);
      }
    } catch (err: unknown) {
      const rawMessage = readRuntimeErrorMessage(err);
      if (rawMessage.toLowerCase() === 'failed to fetch') {
        toast.error('Unable to reach the server. Please check that the backend is running.');
      } else {
        toast.error(rawMessage || 'Something went wrong');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full bg-gradient-to-br from-blue-50 to-indigo-50 relative">
      <button
        onClick={onBack}
        className="absolute top-6 left-5 flex items-center gap-2 text-gray-600 hover:text-gray-900 hover:-translate-x-0.5 transition-all duration-150"
      >
        <ArrowLeft className="w-5 h-5" />
        Back to Home
      </button>

      <div className="min-h-screen w-full flex items-start justify-center pt-14">
        <div className="animate-scale-in w-full max-w-md">
          <div className="bg-white rounded-2xl shadow-2xl border border-gray-100 p-6 sm:p-8">
            {/* Logo */}
            <div className="flex justify-center mb-4">
              <div className="flex items-center gap-2">
                <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center shadow-sm">
                  <TestTube className="w-6 h-6 text-white" />
                </div>
                <span className="text-xl font-bold text-gray-900">Tes<span className="text-blue-600">Tly</span></span>
              </div>
            </div>

            <h2 className="text-xl font-bold text-center text-gray-900 mb-1">
              {isSignup ? 'Create Account' : 'Welcome Back'}
            </h2>
            <p className="text-center text-gray-600 font-medium mb-5 text-sm">
              {isSignup ? 'Sign up to get started' : 'Sign in to your account'}
            </p>

            {/* User Type Selection */}
            <div className={`grid gap-1.5 mb-5 p-1 bg-gray-100 rounded-lg ${isSignup ? 'grid-cols-2' : 'grid-cols-3'}`}>
              <button
                onClick={() => setUserType('patient')}
                className={`py-2 px-4 rounded-md transition ${
                  userType === 'patient'
                    ? 'bg-white text-blue-600 shadow-sm font-semibold'
                    : 'text-gray-600 hover:text-gray-900 font-medium'
                }`}
              >
                Patient
              </button>
              <button
                onClick={() => setUserType('lab')}
                className={`py-2 px-4 rounded-md transition ${
                  userType === 'lab'
                    ? 'bg-white text-blue-600 shadow-sm font-semibold'
                    : 'text-gray-600 hover:text-gray-900 font-medium'
                }`}
              >
                Lab
              </button>
              {!isSignup && (
                <button
                  onClick={() => setUserType('admin')}
                  className={`py-2 px-4 rounded-md transition ${
                    userType === 'admin'
                      ? 'bg-white text-blue-600 shadow-sm font-semibold'
                      : 'text-gray-600 hover:text-gray-900 font-medium'
                  }`}
                >
                  Admin
                </button>
              )}
            </div>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-3">
              {isSignup && (
                <div>
                  <label className="block text-gray-700 font-medium mb-2">
                    {userType === 'lab' ? 'Lab Name' : 'Full Name'}
                  </label>
                  <div className="relative">
                    <User className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
                    <input
                      type="text"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-500"
                      placeholder={userType === 'lab' ? 'Enter lab name' : 'Enter your name'}
                      required={userType === 'lab'}
                    />
                  </div>
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <div>
                  <label className="block text-gray-700 font-medium mb-2">Lab Address</label>
                  <input
                    type="text"
                    value={labAddress}
                    onChange={(e) => setLabAddress(e.target.value)}
                    className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-500"
                    placeholder="Enter lab address"
                    required
                  />
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <div>
                  <label className="block text-gray-700 font-medium mb-2">Lab Phone (Optional)</label>
                  <input
                    type="tel"
                    value={labPhone}
                    onChange={(e) => setLabPhone(e.target.value)}
                    className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-500"
                    placeholder="+20 ..."
                  />
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <div>
                  <label className="block text-gray-700 font-medium mb-2">Accreditation (Optional)</label>
                  <input
                    type="text"
                    value={labAccreditation}
                    onChange={(e) => setLabAccreditation(e.target.value)}
                    className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-500"
                    placeholder="NABL, CAP, ISO..."
                  />
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <div>
                  <label className="block text-gray-700 font-medium mb-2">Turnaround Time (Optional)</label>
                  <input
                    type="text"
                    value={labTurnaroundTime}
                    onChange={(e) => setLabTurnaroundTime(e.target.value)}
                    className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-500"
                    placeholder="24 hours"
                  />
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <label className="flex items-center gap-3 rounded-lg border border-gray-200 px-4 py-3">
                  <input
                    type="checkbox"
                    checked={labHomeCollection}
                    onChange={(e) => setLabHomeCollection(e.target.checked)}
                    className="h-4 w-4 rounded text-blue-600"
                  />
                  <div>
                    <p className="text-gray-900">Enable home collection</p>
                    <p className="text-sm text-gray-500">You can still change availability later from the lab dashboard.</p>
                  </div>
                </label>
              )}

              <div>
                <label className="block text-gray-700 font-medium mb-2">Email Address</label>
                <div className="relative">
                  <Mail className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-500"
                    placeholder="Enter your email"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="block text-gray-700 font-medium mb-2">Password</label>
                <div className="relative">
                  <Lock className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full pl-10 pr-10 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-500"
                    placeholder="Enter your password"
                    minLength={8}
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((prev) => !prev)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    aria-label={showPassword ? 'Hide password' : 'Show password'}
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              {!isSignup && (
                <div className="flex items-center justify-between">
                  <div className="text-sm text-gray-500">
                    Password reset is not available yet.
                  </div>
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <p className="text-blue-800">
                    Your lab will be reviewed by our admin team before approval. You&apos;ll receive an email once your account is activated.
                  </p>
                  <p className="mt-2 text-sm text-blue-700">
                    Labs with phone, accreditation, turnaround time, tests, and active schedule slots are ready for faster activation.
                  </p>
                </div>
              )}

              <button
                type="submit"
                disabled={loading}
                className="w-full py-2.5 bg-blue-600 text-white font-bold rounded-xl shadow-sm hover:shadow-md hover:bg-blue-700 active:scale-[0.99] transition-all duration-150 disabled:opacity-60"
              >
                {loading ? 'Please wait…' : isSignup ? 'Create Account' : 'Sign In'}
              </button>
            </form>

            {/* Toggle Sign In / Sign Up */}
            <div className="mt-4 text-center">
              <p className="text-gray-600">
                {isSignup ? 'Already have an account?' : "Don't have an account?"}{' '}
                <button
                  onClick={() => {
                    setIsSignup((prev) => {
                      const next = !prev;
                      if (next && userType === 'admin') {
                        setUserType('patient');
                      }
                      return next;
                    });
                  }}
                  className="text-blue-600 hover:text-blue-700 font-semibold"
                >
                  {isSignup ? 'Sign In' : 'Sign Up'}
                </button>
              </p>
            </div>
          </div>

          {/* Security Badge */}
          <div className="mt-4 text-center text-gray-600">
            <p className="flex items-center justify-center gap-2 font-medium">
              <Lock className="w-4 h-4" />
              Secured with AES-256 encryption
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
