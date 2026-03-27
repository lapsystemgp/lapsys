import { useState } from 'react';
import { TestTube, Calendar, FileText, Star, LogOut, User, Download, Eye } from 'lucide-react';
import type { Page } from '../types';

interface UserDashboardProps {
  onNavigate: (page: Page) => void;
  onLogout: () => void;
  currentUserLabel?: string;
  currentUserEmail?: string;
}

export function UserDashboard({ onNavigate, onLogout, currentUserLabel, currentUserEmail }: UserDashboardProps) {
  const [activeTab, setActiveTab] = useState<'bookings' | 'results' | 'profile'>('bookings');

  const upcomingBookings = [
    {
      id: 1,
      labName: 'Alaf labs',
      testName: 'Complete Blood Count (CBC)',
      date: '2025-12-07',
      time: '10:00 AM',
      status: 'Confirmed',
      price: 'EGP 450',
      homeCollection: true,
      address: '12 Nile Corniche, Downtown Cairo'
    },
    {
      id: 2,
      labName: 'Al mokhtabar',
      testName: 'Lipid Profile',
      date: '2025-12-10',
      time: '2:00 PM',
      status: 'Pending',
      price: 'EGP 380',
      homeCollection: false,
      address: '45 Tahrir Street, Garden City, Cairo'
    }
  ];

  const testResults = [
    {
      id: 1,
      testName: 'Thyroid Panel (TSH, T3, T4)',
      labName: 'Daman labs',
      date: '2025-11-28',
      status: 'Available',
      pdfUrl: '#',
      rating: 0
    },
    {
      id: 2,
      testName: 'Diabetes Screening (HbA1c)',
      labName: 'Alaf labs',
      date: '2025-11-15',
      status: 'Available',
      pdfUrl: '#',
      rating: 0
    }
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <TestTube className="w-8 h-8 text-blue-600" />
            <span className="text-xl text-blue-600">TesTly</span>
          </div>
          <div className="flex items-center gap-4">
            <button
              onClick={() => onNavigate('landing')}
              className="px-4 py-2 text-gray-600 hover:text-gray-900"
            >
              Search Tests
            </button>
            <div className="flex items-center gap-2 px-4 py-2 bg-gray-100 rounded-lg">
              <User className="w-5 h-5 text-gray-600" />
              <span className="text-gray-900">{currentUserLabel || 'Account'}</span>
            </div>
            <button
              onClick={onLogout}
              className="flex items-center gap-2 px-4 py-2 text-gray-600 hover:text-gray-900"
            >
              <LogOut className="w-5 h-5" />
              Logout
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h1 className="text-3xl text-gray-900 mb-8">My Dashboard</h1>

        {/* Tabs */}
        <div className="bg-white rounded-xl shadow-sm mb-6">
          <div className="border-b border-gray-200">
            <nav className="flex gap-8 px-6">
              <button
                onClick={() => setActiveTab('bookings')}
                className={`py-4 border-b-2 transition ${
                  activeTab === 'bookings'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Calendar className="w-5 h-5" />
                  My Bookings
                </div>
              </button>
              <button
                onClick={() => setActiveTab('results')}
                className={`py-4 border-b-2 transition ${
                  activeTab === 'results'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <div className="flex items-center gap-2">
                  <FileText className="w-5 h-5" />
                  Test Results
                </div>
              </button>
              <button
                onClick={() => setActiveTab('profile')}
                className={`py-4 border-b-2 transition ${
                  activeTab === 'profile'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <div className="flex items-center gap-2">
                  <User className="w-5 h-5" />
                  Profile
                </div>
              </button>
            </nav>
          </div>

          {/* Tab Content */}
          <div className="p-6">
            {activeTab === 'bookings' && (
              <div className="space-y-4">
                {upcomingBookings.map((booking) => (
                  <div key={booking.id} className="border border-gray-200 rounded-lg p-6">
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <h3 className="text-lg text-gray-900 mb-1">{booking.testName}</h3>
                        <p className="text-gray-600">{booking.labName}</p>
                      </div>
                      <span
                        className={`px-3 py-1 rounded-full ${
                          booking.status === 'Confirmed'
                            ? 'bg-green-100 text-green-700'
                            : 'bg-yellow-100 text-yellow-700'
                        }`}
                      >
                        {booking.status}
                      </span>
                    </div>
                    <div className="grid grid-cols-4 gap-4 text-gray-600">
                      <div>
                        <div className="text-gray-500 mb-1">Date</div>
                        <div className="flex items-center gap-1">
                          <Calendar className="w-4 h-4" />
                          {booking.date}
                        </div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Time</div>
                        <div>{booking.time}</div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Type</div>
                        <div>{booking.homeCollection ? 'Home Collection' : 'Lab Visit'}</div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Amount</div>
                        <div className="text-blue-600">{booking.price}</div>
                      </div>
                    </div>
                    {booking.homeCollection && (
                      <div className="mt-4">
                        <div className="text-gray-500 mb-1">Address</div>
                        <div className="text-gray-600">{booking.address}</div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}

            {activeTab === 'results' && (
              <div className="space-y-4">
                {testResults.map((result) => (
                  <div key={result.id} className="border border-gray-200 rounded-lg p-6">
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <h3 className="text-lg text-gray-900 mb-1">{result.testName}</h3>
                        <p className="text-gray-600">{result.labName}</p>
                        <p className="text-gray-500">Test Date: {result.date}</p>
                      </div>
                      <div className="flex gap-2">
                        <button className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                          <Eye className="w-4 h-4" />
                          View
                        </button>
                        <button className="flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
                          <Download className="w-4 h-4" />
                          Download PDF
                        </button>
                      </div>
                    </div>
                    {result.rating === 0 ? (
                      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                        <p className="text-yellow-800 mb-3">How was your experience?</p>
                        <div className="flex items-center gap-2">
                          {[1, 2, 3, 4, 5].map((rating) => (
                            <button key={rating} className="hover:scale-110 transition">
                              <Star className="w-6 h-6 text-gray-300 hover:text-yellow-400" />
                            </button>
                          ))}
                        </div>
                      </div>
                    ) : (
                      <div className="flex items-center gap-1">
                        <span className="text-gray-600">Your rating:</span>
                        {[...Array(result.rating)].map((_, i) => (
                          <Star key={i} className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                        ))}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}

            {activeTab === 'profile' && (
              <div className="max-w-2xl">
                <div className="space-y-6">
                  <div>
                    <label className="block text-gray-700 mb-2">Full Name</label>
                    <input
                      type="text"
                      defaultValue={currentUserLabel || ''}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-gray-700 mb-2">Email</label>
                    <input
                      type="email"
                      defaultValue={currentUserEmail || ''}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-gray-700 mb-2">Phone</label>
                    <input
                      type="tel"
                      defaultValue="+20 10 1234 5678"
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg"
                    />
                  </div>
                  <div>
                    <label className="block text-gray-700 mb-2">Address</label>
                    <textarea
                      defaultValue="15 Ahmed Orabi Street, Apartment 4B, Mohandessin, Giza, Egypt"
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg"
                      rows={3}
                    />
                  </div>
                  <div className="flex items-center justify-between p-4 bg-blue-50 rounded-lg">
                    <div>
                      <div className="text-gray-900 mb-1">Two-Factor Authentication</div>
                      <div className="text-gray-600">Add an extra layer of security</div>
                    </div>
                    <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                      Enable 2FA
                    </button>
                  </div>
                  <button className="w-full py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                    Save Changes
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
