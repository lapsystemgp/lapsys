import { useState } from 'react';
import { Search, TestTube, Calendar, Home, Star, Shield, Activity, User, LayoutDashboard, LogOut, Menu, X } from 'lucide-react';
import { MapPin, Clock } from 'lucide-react';
import { labs } from '../data/labs';
import type { Page, UserRole } from '../types';

interface LandingPageProps {
  onSearch: (query: string) => void;
  onNavigate: (page: Page) => void;
  userRole?: UserRole;
  onLogout?: () => void;
  onLabSelect?: (lab: any) => void;
}

export function LandingPage({ onSearch, onNavigate, userRole, onLogout, onLabSelect }: LandingPageProps) {
  const [searchInput, setSearchInput] = useState('');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchInput.trim()) {
      onSearch(searchInput);
    }
  };

  const featuredLabs = labs;

  return (
    <div className="min-h-screen">
      {/* Header */}
      <header className="bg-white shadow-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <TestTube className="w-6 h-6 sm:w-8 sm:h-8 text-blue-600" />
              <span className="text-lg sm:text-xl text-blue-600">TesTly</span>
            </div>
            
            {/* Desktop Navigation */}
            <nav className="hidden md:flex items-center gap-4 lg:gap-6">
              <a href="#features" className="text-gray-600 hover:text-gray-900 text-sm lg:text-base">Features</a>
              <a href="#how-it-works" className="text-gray-600 hover:text-gray-900 text-sm lg:text-base">How It Works</a>
              {userRole === 'patient' ? (
                <>
                  <button
                    onClick={() => onNavigate('user-dashboard')}
                    className="flex items-center gap-2 px-3 lg:px-4 py-2 text-gray-600 hover:text-gray-900 text-sm lg:text-base"
                  >
                    <LayoutDashboard className="w-4 h-4 lg:w-5 lg:h-5" />
                    Dashboard
                  </button>
                  <div className="flex items-center gap-2 px-4 py-3 bg-gray-100 rounded-lg">
                    <User className="w-4 h-4 text-gray-600" />
                    <span className="text-gray-900">Mazen Amir</span>
                  </div>
                  <button
                    onClick={onLogout}
                    className="flex items-center gap-2 text-gray-600 hover:text-gray-900"
                  >
                    <LogOut className="w-4 h-4 lg:w-5 lg:h-5" />
                  </button>
                </>
              ) : (
                <button
                  onClick={() => onNavigate('login')}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm lg:text-base"
                >
                  Sign In
                </button>
              )}
            </nav>

            {/* Mobile Menu Button */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 text-gray-600"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>

          {/* Mobile Navigation */}
          {mobileMenuOpen && (
            <nav className="md:hidden mt-4 pb-4 space-y-3 border-t border-gray-200 pt-4">
              <a href="#features" onClick={() => setMobileMenuOpen(false)} className="block text-gray-600 hover:text-gray-900 py-2">Features</a>
              <a href="#how-it-works" onClick={() => setMobileMenuOpen(false)} className="block text-gray-600 hover:text-gray-900 py-2">How It Works</a>
              {userRole === 'patient' ? (
                <>
                  <button
                    onClick={() => { onNavigate('user-dashboard'); setMobileMenuOpen(false); }}
                    className="w-full flex items-center gap-2 px-4 py-3 text-gray-600 hover:text-gray-900 bg-gray-50 rounded-lg"
                  >
                    <LayoutDashboard className="w-5 h-5" />
                    Dashboard
                  </button>
                  <div className="flex items-center gap-2 px-4 py-3 bg-gray-100 rounded-lg">
                    <User className="w-4 h-4 text-gray-600" />
                    <span className="text-gray-900">Mazen Amir</span>
                  </div>
                  <button
                    onClick={() => { onLogout?.(); setMobileMenuOpen(false); }}
                    className="w-full flex items-center gap-2 px-4 py-3 text-red-600 hover:text-red-700 bg-red-50 rounded-lg"
                  >
                    <LogOut className="w-5 h-5" />
                    Logout
                  </button>
                </>
              ) : (
                <button
                  onClick={() => { onNavigate('login'); setMobileMenuOpen(false); }}
                  className="w-full px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                  Sign In
                </button>
              )}
            </nav>
          )}
        </div>
      </header>

      {/* Hero Section */}
      <section className="bg-gradient-to-br from-blue-50 to-indigo-100 py-12 sm:py-16 lg:py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto">
            <h1 className="text-3xl sm:text-4xl lg:text-5xl text-gray-900 mb-4 sm:mb-6">
              Find the Best Medical Labs Near You
            </h1>
            <p className="text-base sm:text-lg lg:text-xl text-gray-600 mb-8 sm:mb-10">
              Compare prices, ratings, and book appointments instantly. Get your test results delivered digitally.
            </p>

            {/* Search Bar */}
            <form onSubmit={handleSubmit} className="max-w-2xl mx-auto">
              <div className="bg-white rounded-full shadow-lg flex items-center px-4 sm:px-6 py-3 sm:py-4">
                <Search className="w-5 h-5 sm:w-6 sm:h-6 text-gray-400 flex-shrink-0" />
                <input
                  type="text"
                  placeholder="Enter test name or symptoms"
                  className="flex-1 px-3 sm:px-4 outline-none text-sm sm:text-base"
                  value={searchInput}
                  onChange={(e) => setSearchInput(e.target.value)}
                />
                <button
                  type="submit"
                  className="px-4 sm:px-8 py-2 sm:py-3 bg-blue-600 text-white rounded-full hover:bg-blue-700 text-sm sm:text-base flex-shrink-0"
                >
                  Search
                </button>
              </div>
            </form>

            {/* Popular Searches */}
            <div className="mt-4 sm:mt-6 flex flex-wrap gap-2 sm:gap-3 justify-center">
              <span className="text-gray-600 text-sm sm:text-base">Popular:</span>
              {['CBC Test', 'Lipid Profile', 'Thyroid Panel', 'Diabetes Screening'].map((term) => (
                <button
                  key={term}
                  onClick={() => onSearch(term)}
                  className="px-3 sm:px-4 py-1.5 sm:py-2 bg-white rounded-full text-gray-700 hover:bg-gray-100 text-sm sm:text-base"
                >
                  {term}
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-12 sm:py-16 lg:py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-2xl sm:text-3xl text-center text-gray-900 mb-8 sm:mb-12">
            Why Choose TesTly?
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
            <FeatureCard
              icon={<Search className="w-8 h-8 sm:w-10 sm:h-10 text-blue-600" />}
              title="Compare Lab Prices"
              description="View and compare prices from multiple labs in your area instantly"
            />
            <FeatureCard
              icon={<Star className="w-8 h-8 sm:w-10 sm:h-10 text-blue-600" />}
              title="Verified Reviews"
              description="Read authentic reviews from real patients to make informed decisions"
            />
            <FeatureCard
              icon={<Home className="w-8 h-8 sm:w-10 sm:h-10 text-blue-600" />}
              title="Home Sample Collection"
              description="Book sample collection at home for your convenience"
            />
            <FeatureCard
              icon={<Calendar className="w-8 h-8 sm:w-10 sm:h-10 text-blue-600" />}
              title="Easy Booking"
              description="Schedule appointments in just a few clicks"
            />
            <FeatureCard
              icon={<Activity className="w-8 h-8 sm:w-10 sm:h-10 text-blue-600" />}
              title="Digital Results"
              description="Receive your test results as PDF directly in the app"
            />
            <FeatureCard
              icon={<Shield className="w-8 h-8 sm:w-10 sm:h-10 text-blue-600" />}
              title="Secure & Private"
              description="Your medical data is encrypted and protected with AES-256"
            />
          </div>
        </div>
      </section>

      {/* Featured Labs Section */}
      <section id="featured-labs" className="py-12 sm:py-16 lg:py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-8 sm:mb-12">
            <h2 className="text-2xl sm:text-3xl text-gray-900 mb-2 sm:mb-3">
              Our Featured Labs
            </h2>
            <p className="text-base sm:text-lg lg:text-xl text-gray-600 px-4">
              Click on any lab to view their complete test catalog and book appointments
            </p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
            {featuredLabs.map((lab) => (
              <button
                key={lab.id}
                onClick={() => onLabSelect?.(lab)}
                className="bg-white rounded-xl shadow-sm p-4 sm:p-6 hover:shadow-lg transition text-left group"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="w-12 h-12 sm:w-16 sm:h-16 bg-blue-50 rounded-xl flex items-center justify-center text-2xl sm:text-3xl group-hover:bg-blue-100 transition">
                    {lab.image}
                  </div>
                  {lab.homeCollection && (
                    <div className="flex items-center gap-1 px-2 py-1 bg-green-50 text-green-700 rounded text-xs">
                      <Home className="w-3 h-3" />
                      <span className="hidden sm:inline">Home</span>
                    </div>
                  )}
                </div>
                <h3 className="text-lg sm:text-xl text-gray-900 mb-2 group-hover:text-blue-600 transition">
                  {lab.name}
                </h3>
                <div className="flex items-center gap-2 mb-3 text-sm">
                  <div className="flex items-center gap-1">
                    <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                    <span className="text-gray-900">{lab.rating}</span>
                  </div>
                  <span className="text-gray-500">({lab.reviews})</span>
                </div>
                <div className="space-y-2 mb-4 text-gray-600 text-sm">
                  <div className="flex items-center gap-2">
                    <MapPin className="w-4 h-4 flex-shrink-0" />
                    <span className="truncate">{lab.distance} km away</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <TestTube className="w-4 h-4 flex-shrink-0" />
                    <span>{lab.testsAvailable} tests</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Clock className="w-4 h-4 flex-shrink-0" />
                    <span>{lab.turnaroundTime}</span>
                  </div>
                </div>
                <div className="pt-4 border-t border-gray-100 flex items-center justify-between">
                  <div>
                    <div className="text-gray-500 text-xs sm:text-sm">Starting from</div>
                    <div className="text-xl sm:text-2xl text-blue-600">EGP {lab.price}</div>
                  </div>
                  <div className="px-3 sm:px-4 py-2 bg-blue-600 text-white rounded-lg group-hover:bg-blue-700 transition text-sm">
                    View
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section id="how-it-works" className="py-12 sm:py-16 lg:py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-2xl sm:text-3xl text-center text-gray-900 mb-8 sm:mb-12">
            How It Works
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 sm:gap-8">
            <StepCard number="1" title="Search" description="Enter test name or symptoms" />
            <StepCard number="2" title="Compare" description="View labs, prices & ratings" />
            <StepCard number="3" title="Book" description="Schedule your appointment" />
            <StepCard number="4" title="Get Results" description="Receive digital PDF results" />
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-12 sm:py-16 lg:py-20 bg-blue-600">
        <div className="max-w-4xl mx-auto text-center px-4 sm:px-6">
          <h2 className="text-2xl sm:text-3xl lg:text-4xl text-white mb-4 sm:mb-6">
            Ready to Find Your Lab?
          </h2>
          <p className="text-base sm:text-lg lg:text-xl text-blue-100 mb-6 sm:mb-8">
            Join thousands of patients who trust TesTly for their medical testing needs
          </p>
          <button
            onClick={() => onNavigate('login')}
            className="px-6 sm:px-8 py-3 sm:py-4 bg-white text-blue-600 rounded-lg hover:bg-gray-100 text-base sm:text-lg"
          >
            Get Started Now
          </button>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-300 py-8 sm:py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 sm:gap-8">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <TestTube className="w-6 h-6 text-blue-400" />
                <span className="text-white">TesTly</span>
              </div>
              <p className="text-gray-400 text-sm">
                Your trusted platform for comparing medical labs and booking tests.
              </p>
            </div>
            <div>
              <h3 className="text-white mb-4">For Patients</h3>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="hover:text-white">Search Tests</a></li>
                <li><a href="#" className="hover:text-white">Book Appointment</a></li>
                <li><a href="#" className="hover:text-white">View Results</a></li>
              </ul>
            </div>
            <div>
              <h3 className="text-white mb-4">For Labs</h3>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="hover:text-white">Register Your Lab</a></li>
                <li><a href="#" className="hover:text-white">Dashboard</a></li>
                <li><a href="#" className="hover:text-white">Analytics</a></li>
              </ul>
            </div>
            <div>
              <h3 className="text-white mb-4">Support</h3>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="hover:text-white">Help Center</a></li>
                <li><a href="#" className="hover:text-white">Privacy Policy</a></li>
                <li><a href="#" className="hover:text-white">Terms of Service</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-6 sm:mt-8 pt-6 sm:pt-8 text-center text-gray-400 text-sm">
            <p>&copy; 2025 TesTly. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode; title: string; description: string }) {
  return (
    <div className="text-center p-4 sm:p-6 rounded-xl hover:bg-gray-50 transition">
      <div className="flex justify-center mb-3 sm:mb-4">{icon}</div>
      <h3 className="text-lg sm:text-xl text-gray-900 mb-2 sm:mb-3">{title}</h3>
      <p className="text-sm sm:text-base text-gray-600">{description}</p>
    </div>
  );
}

function StepCard({ number, title, description }: { number: string; title: string; description: string }) {
  return (
    <div className="text-center">
      <div className="w-12 h-12 sm:w-16 sm:h-16 bg-blue-600 text-white rounded-full flex items-center justify-center text-xl sm:text-2xl mx-auto mb-3 sm:mb-4">
        {number}
      </div>
      <h3 className="text-base sm:text-lg lg:text-xl text-gray-900 mb-1 sm:mb-2">{title}</h3>
      <p className="text-sm sm:text-base text-gray-600">{description}</p>
    </div>
  );
}
