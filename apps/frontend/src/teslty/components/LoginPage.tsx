import { useState } from 'react';
import { ArrowLeft, TestTube, Mail, Lock, User } from 'lucide-react';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from './ui/dialog';
import { Label } from './ui/label';
import { Input } from './ui/input';

interface LoginPageProps {
  onLogin: (role: 'patient' | 'lab') => void;
  onBack: () => void;
}

export function LoginPage({ onLogin, onBack }: LoginPageProps) {
  const [isSignup, setIsSignup] = useState(false);
  const [userType, setUserType] = useState<'patient' | 'lab'>('patient');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [isForgotPasswordOpen, setIsForgotPasswordOpen] = useState(false);
  const [resetEmail, setResetEmail] = useState('');
  const [resetSent, setResetSent] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Sign in directly without validation - fields are optional
    onLogin(userType);
  };

  const handleForgotPassword = (e: React.FormEvent) => {
    e.preventDefault();
    // Simulate sending a reset email
    setResetSent(true);
    setTimeout(() => {
      setIsForgotPasswordOpen(false);
      setResetSent(false);
      setResetEmail('');
    }, 2000);
  };

  const handleDialogClose = (open: boolean) => {
    setIsForgotPasswordOpen(open);
    if (!open) {
      setResetSent(false);
      setResetEmail('');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-8">
        <button onClick={onBack} className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-6">
          <ArrowLeft className="w-5 h-5" />
          Back to Home
        </button>

        <div className="max-w-md mx-auto">
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
                    />
                  </div>
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
                  />
                </div>
              </div>

              {!isSignup && (
                <div className="flex items-center justify-between">
                  <label className="flex items-center gap-2">
                    <input type="checkbox" className="w-4 h-4 text-blue-600 rounded" />
                    <span className="text-gray-600">Remember me</span>
                  </label>
                  <button 
                    type="button"
                    onClick={() => setIsForgotPasswordOpen(true)}
                    className="text-blue-600 hover:text-blue-700"
                  >
                    Forgot password?
                  </button>
                </div>
              )}

              {isSignup && userType === 'lab' && (
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <p className="text-blue-800">
                    Your lab will be reviewed by our admin team before approval. You'll receive an email once your account is activated.
                  </p>
                </div>
              )}

              <button
                type="submit"
                className="w-full py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
              >
                {isSignup ? 'Create Account' : 'Sign In'}
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

            {/* Demo Credentials */}
            <div className="mt-6 p-4 bg-gray-50 rounded-lg">
              <p className="text-gray-700 mb-2">Demo Mode:</p>
              <div className="space-y-1 text-gray-600">
                <p>Just click "Sign In" to continue - no credentials needed!</p>
              </div>
            </div>
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

      {/* Forgot Password Dialog */}
      <Dialog open={isForgotPasswordOpen} onOpenChange={handleDialogClose}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>Forgot password</DialogTitle>
            <DialogDescription>
              {resetSent 
                ? 'Check your email for password reset instructions'
                : "Enter your email below and we'll send you a password reset link"
              }
            </DialogDescription>
          </DialogHeader>
          {!resetSent && (
            <>
              <div className="mt-4">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  className="mt-2"
                  value={resetEmail}
                  onChange={(e) => setResetEmail(e.target.value)}
                  placeholder="Enter your email"
                  required
                />
              </div>
              <DialogFooter>
                <button
                  type="button"
                  className="text-sm text-gray-500 hover:text-gray-900"
                  onClick={() => handleDialogClose(false)}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={!resetEmail}
                  className="py-2 px-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                  onClick={handleForgotPassword}
                >
                  Send Reset
                </button>
              </DialogFooter>
            </>
          )}
          {resetSent && (
            <div className="py-4">
              <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                <p className="text-green-800 text-center">
                  Password reset email sent successfully! Check your inbox.
                </p>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
