import { useState } from 'react';
import { ArrowLeft, TestTube, Mail, Lock, User } from 'lucide-react';
import { API_BASE_URL } from '../../lib/api';
import { useSession } from '../../components/SessionProvider';

interface LoginPageProps {
  onLogin: (role: 'patient' | 'lab') => void;
  onBack: () => void;
  defaultMode?: 'login' | 'register';
  onAuthenticated?: (params: { role: 'patient' | 'lab'; lab_onboarding_status?: string | null }) => void;
}

export function LoginPage({ onLogin, onBack, defaultMode = 'login', onAuthenticated }: LoginPageProps) {
  const showDemoCredentials =
    process.env.NEXT_PUBLIC_SHOW_DEMO_CREDENTIALS === 'true' ||
    (process.env.NODE_ENV !== 'production' &&
      process.env.NEXT_PUBLIC_SHOW_DEMO_CREDENTIALS !== 'false');

  const [isSignup, setIsSignup] = useState(defaultMode === 'register');
  const [userType, setUserType] = useState<'patient' | 'lab'>('patient');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [labAddress, setLabAddress] = useState('');
  const [labPhone, setLabPhone] = useState('');
  const [error, setError] = useState<string | null>(null);
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
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

      const role = data.user?.role === 'LabStaff' ? 'lab' : 'patient';
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
        setError('Unable to reach the server. Please check that backend is running.');
      } else {
        setError(rawMessage || 'Something went wrong');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full bg-gradient-to-br from-blue-50 to-indigo-100 relative">
      <button
        onClick={onBack}
        className="absolute top-8 left-5 flex items-center gap-2 text-gray-600 hover:text-gray-900"
      >
        <ArrowLeft className="w-5 h-5" />
        Back to Home
      </button>

      <div className="min-h-screen w-full flex items-start justify-center pt-20">
        <div className="w-full max-w-md">
          <div className="bg-white rounded-2xl shadow-xl p-8">
            {/* Logo */}
            <div className="flex justify-center mb-6">
              <div className="flex items-center gap-2">
                <TestTube className="w-10 h-10 text-blue-600" />
                <span className="text-2xl text-blue-600">TesTly</span>
              </div>
            </div>

            <h2 className="text-2xl text-center text-gray-900 mb-2">
              {isSignup ? 'Create Account' : 'Welcome Back'}
            </h2>
            <p className="text-center text-gray-600 mb-8">
              {isSignup ? 'Sign up to get started' : 'Sign in to your account'}
            </p>

            {/* User Type Selection */}
            <div className="grid grid-cols-2 gap-2 mb-6 p-1 bg-gray-100 rounded-lg">
              <button
                onClick={() => setUserType('patient')}
                className={`py-2 px-4 rounded-md transition ${
                  userType === 'patient'
                    ? 'bg-white text-blue-600 shadow-sm'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                Patient
              </button>
              <button
                onClick={() => setUserType('lab')}
                className={`py-2 px-4 rounded-md transition ${
                  userType === 'lab'
                    ? 'bg-white text-blue-600 shadow-sm'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                Lab
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-4">
              {isSignup && (
                <div>
                  <label className="block text-gray-700 mb-2">
                    {userType === 'lab' ? 'Lab Name' : 'Full Name'}
                  </label>
                  <div className="relative">
                    <User className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
                    <input
                      type="text"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder={userType === 'lab' ? 'Enter lab name' : 'Enter your name'}
                      required={userType === 'lab'}
                    />
                  </div>
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <div>
                  <label className="block text-gray-700 mb-2">Lab Address</label>
                  <input
                    type="text"
                    value={labAddress}
                    onChange={(e) => setLabAddress(e.target.value)}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter lab address"
                    required
                  />
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <div>
                  <label className="block text-gray-700 mb-2">Lab Phone (Optional)</label>
                  <input
                    type="tel"
                    value={labPhone}
                    onChange={(e) => setLabPhone(e.target.value)}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="+20 ..."
                  />
                </div>
              )}

              <div>
                <label className="block text-gray-700 mb-2">Email Address</label>
                <div className="relative">
                  <Mail className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter your email"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="block text-gray-700 mb-2">Password</label>
                <div className="relative">
                  <Lock className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter your password"
                    minLength={8}
                    required
                  />
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
                </div>
              )}

              {error && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <p className="text-red-800">{error}</p>
                </div>
              )}

              <button
                type="submit"
                disabled={loading}
                className="w-full py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
              >
                {loading ? 'Please wait…' : isSignup ? 'Create Account' : 'Sign In'}
              </button>
            </form>

            {/* Toggle Sign In / Sign Up */}
            <div className="mt-6 text-center">
              <p className="text-gray-600">
                {isSignup ? 'Already have an account?' : "Don't have an account?"}{' '}
                <button
                  onClick={() => setIsSignup(!isSignup)}
                  className="text-blue-600 hover:text-blue-700"
                >
                  {isSignup ? 'Sign In' : 'Sign Up'}
                </button>
              </p>
            </div>

            {/* Demo Credentials (dev/demo only) */}
            {showDemoCredentials && (
              <div className="mt-6 p-4 bg-gray-50 rounded-lg">
                <p className="text-gray-700 mb-2">Demo Credentials:</p>
                <div className="space-y-1 text-gray-600">
                  <p>Patient: `patient@testly.com` / `password123`</p>
                  <p>Lab: `alaflabs@testly.com` / `password123`</p>
                  <p>Lab (Pending): `pendinglab@testly.com` / `password123`</p>
                </div>
              </div>
            )}
          </div>

          {/* Security Badge */}
          <div className="mt-6 text-center text-gray-600">
            <p className="flex items-center justify-center gap-2">
              <Lock className="w-4 h-4" />
              Secured with AES-256 encryption
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
