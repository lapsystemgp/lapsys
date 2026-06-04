'use client';

import { useEffect, useState } from 'react';
import {
  Search, TestTube, Calendar, Home, Star, Shield, Activity,
  User, LayoutDashboard, LogOut, Menu, X, Award, CheckCircle2,
  ArrowRight, ChevronRight, FlaskConical,
} from 'lucide-react';
import { MapPin, Clock } from 'lucide-react';
import type { Page, UserRole } from '../types';
import { fetchPublicLabs, type PublicLabCard } from '../../lib/publicApi';

interface LandingPageProps {
  onSearch: (query: string, sort?: 'price' | 'rating' | 'distance', city?: string) => void;
  onNavigate: (page: Page) => void;
  userRole?: UserRole;
  currentUserLabel?: string;
  onLogout?: () => void;
  onLabSelect?: (lab: PublicLabCard) => void;
}

export function LandingPage({ onSearch, onNavigate, userRole, currentUserLabel, onLogout, onLabSelect }: LandingPageProps) {
  const [searchInput, setSearchInput] = useState('');
  const [cityInput, setCityInput] = useState('');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [featuredLabs, setFeaturedLabs] = useState<PublicLabCard[]>([]);
  const [searchFocused, setSearchFocused] = useState(false);

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSearch(searchInput, undefined, cityInput.trim() || undefined);
  };

  useEffect(() => {
    let isMounted = true;
    fetchPublicLabs({ sort: 'rating', pageSize: 6 })
      .then((res) => {
        if (!isMounted) return;
        setFeaturedLabs(res.items);
      })
      .catch(() => {});
    return () => { isMounted = false; };
  }, []);

  return (
    <div className="min-h-screen">
      {/* Header */}
      <header className="bg-white/95 backdrop-blur-sm shadow-sm sticky top-0 z-50 border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3.5">
          <div className="flex items-center justify-between">
            <button
              className="flex items-center gap-2.5"
              onClick={() => onNavigate('landing')}
            >
              <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center shadow-sm">
                <TestTube className="w-5 h-5 text-white" />
              </div>
              <span className="text-xl font-bold text-gray-900">
                Tes<span className="text-blue-600">Tly</span>
              </span>
            </button>

            {/* Desktop Navigation */}
            <nav className="hidden md:flex items-center gap-1">
              <a
                href="#features"
                className="px-3 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-lg transition-all"
              >
                Features
              </a>
              <a
                href="#how-it-works"
                className="px-3 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-lg transition-all"
              >
                How It Works
              </a>
              {userRole ? (
                <>
                  <button
                    onClick={() =>
                      onNavigate(
                        userRole === 'lab'
                          ? 'lab-dashboard'
                          : userRole === 'admin'
                            ? 'admin-dashboard'
                            : 'user-dashboard',
                      )
                    }
                    className="flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-lg transition-all"
                  >
                    <LayoutDashboard className="w-4 h-4" />
                    Dashboard
                  </button>
                  <div className="flex items-center gap-2 px-3 py-2 bg-gray-100 rounded-lg">
                    <div className="w-6 h-6 bg-blue-600 rounded-full flex items-center justify-center">
                      <User className="w-3.5 h-3.5 text-white" />
                    </div>
                    <span className="text-sm font-medium text-gray-900">
                      {currentUserLabel || 'Account'}
                    </span>
                  </div>
                  <button
                    onClick={onLogout}
                    className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-50 rounded-lg transition-all"
                  >
                    <LogOut className="w-4 h-4" />
                  </button>
                </>
              ) : (
                <button
                  onClick={() => onNavigate('login')}
                  className="ml-2 px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700 transition-all shadow-sm hover:shadow-md"
                >
                  Sign In
                </button>
              )}
            </nav>

            {/* Mobile Menu Button */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 text-gray-600 hover:bg-gray-50 rounded-lg transition-colors"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>

          {/* Mobile Navigation */}
          {mobileMenuOpen && (
            <nav className="md:hidden mt-3 pb-3 space-y-1 border-t border-gray-100 pt-3">
              <a
                href="#features"
                onClick={() => setMobileMenuOpen(false)}
                className="block px-3 py-2.5 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-lg font-medium"
              >
                Features
              </a>
              <a
                href="#how-it-works"
                onClick={() => setMobileMenuOpen(false)}
                className="block px-3 py-2.5 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-lg font-medium"
              >
                How It Works
              </a>
              {userRole ? (
                <>
                  <button
                    onClick={() => {
                      onNavigate(
                        userRole === 'lab'
                          ? 'lab-dashboard'
                          : userRole === 'admin'
                            ? 'admin-dashboard'
                            : 'user-dashboard',
                      );
                      setMobileMenuOpen(false);
                    }}
                    className="w-full flex items-center gap-2 px-3 py-2.5 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-lg font-medium"
                  >
                    <LayoutDashboard className="w-5 h-5" />
                    Dashboard
                  </button>
                  <div className="flex items-center gap-2 px-3 py-2.5 bg-gray-100 rounded-lg">
                    <div className="w-6 h-6 bg-blue-600 rounded-full flex items-center justify-center">
                      <User className="w-3.5 h-3.5 text-white" />
                    </div>
                    <span className="text-sm font-medium text-gray-900">
                      {currentUserLabel || 'Account'}
                    </span>
                  </div>
                  <button
                    onClick={() => { onLogout?.(); setMobileMenuOpen(false); }}
                    className="w-full flex items-center gap-2 px-3 py-2.5 text-red-600 hover:text-red-700 bg-red-50 rounded-lg font-medium"
                  >
                    <LogOut className="w-5 h-5" />
                    Logout
                  </button>
                </>
              ) : (
                <button
                  onClick={() => { onNavigate('login'); setMobileMenuOpen(false); }}
                  className="w-full px-4 py-2.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-semibold"
                >
                  Sign In
                </button>
              )}
            </nav>
          )}
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-blue-50 via-white to-indigo-50 py-12 sm:py-16 lg:py-24 overflow-hidden">
        {/* Decorative blobs */}
        <div className="absolute top-0 right-0 w-96 h-96 bg-blue-100 rounded-full opacity-50 blur-3xl -translate-y-1/3 translate-x-1/4 pointer-events-none" />
        <div className="absolute bottom-0 left-0 w-72 h-72 bg-indigo-100 rounded-full opacity-40 blur-3xl translate-y-1/3 -translate-x-1/4 pointer-events-none" />
        <div className="absolute top-1/2 left-1/3 w-48 h-48 bg-blue-50 rounded-full opacity-60 blur-2xl pointer-events-none" />

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto">
            {/* Trust badge */}
            <div className="animate-fade-in inline-flex items-center gap-2 px-4 py-1.5 bg-white border border-blue-100 text-blue-700 rounded-full text-sm font-semibold shadow-sm mb-6">
              <span className="w-2 h-2 bg-blue-500 rounded-full" />
              Egypt&apos;s Trusted Medical Lab Platform
            </div>

            <h1 className="animate-slide-up text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 mb-4 leading-tight tracking-tight">
              Find the Best{' '}
              <span className="text-blue-600">Medical Labs</span>
              <br className="hidden sm:block" /> Near You
            </h1>
            <p className="animate-slide-up animation-delay-150 text-lg sm:text-xl text-gray-500 mb-8 leading-relaxed">
              Compare prices, ratings, and book appointments instantly.
              <br className="hidden sm:block" />
              Get your test results delivered digitally.
            </p>

            {/* Search Bar */}
            <form onSubmit={handleSubmit} className="animate-slide-up animation-delay-300 max-w-2xl mx-auto">
              <div
                className={`bg-white rounded-2xl flex flex-col sm:flex-row gap-0 transition-all duration-300 ${
                  searchFocused ? 'shadow-2xl ring-2 ring-blue-100' : 'shadow-xl'
                }`}
              >
                <div className="flex items-center flex-1 px-4 py-3.5 sm:py-4">
                  <Search className="w-5 h-5 text-blue-400 flex-shrink-0" />
                  <input
                    type="text"
                    placeholder="Test name or symptoms..."
                    className="flex-1 px-3 outline-none text-sm sm:text-base bg-transparent text-gray-900 placeholder-gray-400 font-medium"
                    value={searchInput}
                    onChange={(e) => setSearchInput(e.target.value)}
                    onFocus={() => setSearchFocused(true)}
                    onBlur={() => setSearchFocused(false)}
                  />
                </div>
                <div className="flex items-center sm:w-44 px-4 py-3.5 sm:py-4 border-t sm:border-t-0 sm:border-l border-gray-100">
                  <MapPin className="w-5 h-5 text-gray-400 flex-shrink-0" />
                  <input
                    type="text"
                    placeholder="City (optional)"
                    className="flex-1 px-3 outline-none text-sm sm:text-base bg-transparent text-gray-900 placeholder-gray-400"
                    value={cityInput}
                    onChange={(e) => setCityInput(e.target.value)}
                  />
                </div>
                <div className="px-3 py-2.5 flex items-center">
                  <button
                    type="submit"
                    className="w-full sm:w-auto px-6 py-2.5 bg-blue-600 text-white rounded-xl hover:bg-blue-700 text-sm sm:text-base font-semibold transition-all shadow-sm hover:shadow-md active:scale-95"
                  >
                    Search
                  </button>
                </div>
              </div>
            </form>

            {/* Popular Searches */}
            <div className="animate-slide-up animation-delay-400 mt-5 flex flex-wrap gap-2 sm:gap-3 justify-center">
              <span className="text-gray-400 text-sm font-medium self-center">Popular:</span>
              {['CBC', 'Lipid Profile', 'Thyroid Panel', 'HbA1c'].map((term) => (
                <button
                  key={term}
                  onClick={() => onSearch(term)}
                  className="px-3 sm:px-4 py-1.5 bg-white border border-gray-200 rounded-full text-gray-700 hover:border-blue-300 hover:text-blue-600 hover:bg-blue-50 text-sm font-medium transition-all shadow-sm"
                >
                  {term}
                </button>
              ))}
            </div>

            {/* Browse by criteria */}
            <div className="animate-slide-up animation-delay-500 mt-3 flex flex-wrap gap-2 sm:gap-3 justify-center">
              <span className="text-gray-400 text-sm font-medium self-center">Browse by:</span>
              <button
                onClick={() => onSearch('', 'distance')}
                className="flex items-center gap-1.5 px-3 sm:px-4 py-1.5 bg-white border border-blue-100 rounded-full text-blue-600 hover:bg-blue-600 hover:text-white hover:border-blue-600 text-sm font-medium transition-all"
              >
                <MapPin className="w-3.5 h-3.5" />
                Nearest
              </button>
              <button
                onClick={() => onSearch('', 'price')}
                className="flex items-center gap-1.5 px-3 sm:px-4 py-1.5 bg-white border border-blue-100 rounded-full text-blue-600 hover:bg-blue-600 hover:text-white hover:border-blue-600 text-sm font-medium transition-all"
              >
                Best Price
              </button>
              <button
                onClick={() => onSearch('', 'rating')}
                className="flex items-center gap-1.5 px-3 sm:px-4 py-1.5 bg-white border border-blue-100 rounded-full text-blue-600 hover:bg-blue-600 hover:text-white hover:border-blue-600 text-sm font-medium transition-all"
              >
                <Star className="w-3.5 h-3.5" />
                Top Rated
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Strip */}
      <section className="bg-white border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6">
            {[
              { value: '50+', label: 'Partner Labs', icon: <TestTube className="w-5 h-5" /> },
              { value: '200+', label: 'Available Tests', icon: <FlaskConical className="w-5 h-5" /> },
              { value: '4.8★', label: 'Average Rating', icon: <Star className="w-5 h-5" /> },
              { value: '10K+', label: 'Happy Patients', icon: <Activity className="w-5 h-5" /> },
            ].map(({ value, label, icon }) => (
              <div key={label} className="text-center group cursor-default">
                <div className="flex justify-center mb-2">
                  <div className="w-10 h-10 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center group-hover:bg-blue-600 group-hover:text-white transition-all duration-200">
                    {icon}
                  </div>
                </div>
                <div className="text-2xl sm:text-3xl font-bold text-gray-900">{value}</div>
                <div className="text-xs sm:text-sm text-gray-500 font-medium mt-0.5">{label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-12 sm:py-16 lg:py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-10 sm:mb-14">
            <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-gray-900 mb-3">
              Why Choose TesTly?
            </h2>
            <p className="text-gray-500 text-base sm:text-lg max-w-xl mx-auto">
              Everything you need to find and book medical tests with confidence
            </p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
            <FeatureCard
              icon={<Search className="w-6 h-6 text-blue-600" />}
              title="Compare Lab Prices"
              description="View and compare prices from multiple labs in your area instantly"
            />
            <FeatureCard
              icon={<Star className="w-6 h-6 text-blue-600" />}
              title="Verified Reviews"
              description="Read authentic reviews from real patients to make informed decisions"
            />
            <FeatureCard
              icon={<Home className="w-6 h-6 text-blue-600" />}
              title="Home Sample Collection"
              description="Book sample collection at home for your convenience"
            />
            <FeatureCard
              icon={<Calendar className="w-6 h-6 text-blue-600" />}
              title="Easy Booking"
              description="Schedule appointments in just a few clicks"
            />
            <FeatureCard
              icon={<Activity className="w-6 h-6 text-blue-600" />}
              title="Digital Results"
              description="Receive your test results as PDF directly in the app"
            />
            <FeatureCard
              icon={<Shield className="w-6 h-6 text-blue-600" />}
              title="Secure & Private"
              description="Your medical data is encrypted and protected with AES-256"
            />
          </div>
        </div>
      </section>

      {/* Featured Labs Section */}
      {featuredLabs.length > 0 && (
        <section id="featured-labs" className="py-12 sm:py-16 lg:py-20 bg-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between mb-8 sm:mb-12 gap-4">
              <div>
                <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-gray-900 mb-2">
                  Featured Labs
                </h2>
                <p className="text-gray-500 text-base sm:text-lg">
                  Top-rated labs available for booking right now
                </p>
              </div>
              <button
                onClick={() => onNavigate('labs')}
                className="flex items-center gap-1.5 text-blue-600 font-semibold hover:text-blue-700 text-sm sm:text-base shrink-0 transition-colors"
              >
                View all labs
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
              {featuredLabs.map((lab, idx) => (
                <button
                  key={lab.id}
                  onClick={() => onLabSelect?.(lab)}
                  className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 hover:shadow-lg hover:-translate-y-1 transition-all duration-300 text-left group"
                >
                  <div className="flex items-start justify-between mb-4">
                    <div className="w-14 h-14 bg-blue-50 rounded-2xl flex items-center justify-center text-3xl group-hover:bg-blue-100 transition-colors duration-200">
                      {lab.imageEmoji ?? lab.name?.slice(0, 1)}
                    </div>
                    <div className="flex flex-col items-end gap-1.5">
                      {idx === 0 && (
                        <div className="flex items-center gap-1 px-2 py-0.5 bg-yellow-50 text-yellow-700 rounded-full text-xs font-semibold border border-yellow-100">
                          <Award className="w-3 h-3" />
                          Top Rated
                        </div>
                      )}
                      {lab.homeCollection && (
                        <div className="flex items-center gap-1 px-2 py-0.5 bg-green-50 text-green-700 rounded-full text-xs font-medium border border-green-100">
                          <Home className="w-3 h-3" />
                          Home
                        </div>
                      )}
                    </div>
                  </div>
                  <h3 className="text-base sm:text-lg font-semibold text-gray-900 mb-2 group-hover:text-blue-600 transition-colors">
                    {lab.name}
                  </h3>
                  <div className="flex items-center gap-2 mb-3 text-sm">
                    <div className="flex items-center gap-1">
                      <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                      <span className="font-semibold text-gray-900">{lab.rating ?? '—'}</span>
                    </div>
                    <span className="text-gray-400">({lab.reviews} reviews)</span>
                  </div>
                  <div className="space-y-1.5 mb-4 text-gray-500 text-sm">
                    {lab.distanceKm !== null && (
                      <div className="flex items-center gap-2">
                        <MapPin className="w-4 h-4 flex-shrink-0 text-gray-400" />
                        <span>{lab.distanceKm} km away</span>
                      </div>
                    )}
                    <div className="flex items-center gap-2">
                      <TestTube className="w-4 h-4 flex-shrink-0 text-gray-400" />
                      <span>{lab.testsAvailable} tests available</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Clock className="w-4 h-4 flex-shrink-0 text-gray-400" />
                      <span>{lab.turnaroundTime ?? '—'}</span>
                    </div>
                  </div>
                  <div className="pt-4 border-t border-gray-100 flex items-center justify-between">
                    <div>
                      <div className="text-gray-400 text-xs font-medium">Starting from</div>
                      <div className="text-2xl font-bold text-blue-600">
                        EGP {lab.startingFromEgp ?? '—'}
                      </div>
                    </div>
                    <div className="flex items-center gap-1.5 px-4 py-2 bg-blue-600 text-white rounded-xl group-hover:bg-blue-700 transition-colors text-sm font-semibold">
                      Book
                      <ArrowRight className="w-3.5 h-3.5" />
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </section>
      )}

      {/* How It Works */}
      <section id="how-it-works" className="py-12 sm:py-16 lg:py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-10 sm:mb-14">
            <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-gray-900 mb-3">
              How It Works
            </h2>
            <p className="text-gray-500 text-base sm:text-lg">
              Book your medical tests in four simple steps
            </p>
          </div>
          <div className="relative">
            {/* Connecting line — desktop only */}
            <div
              className="hidden md:block absolute top-7 h-0.5 bg-blue-100 z-0"
              style={{ left: 'calc(12.5% + 28px)', right: 'calc(12.5% + 28px)' }}
            />
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6 sm:gap-8 relative z-10">
              <StepCard number="1" title="Search" description="Enter test name or symptoms" />
              <StepCard number="2" title="Compare" description="View labs, prices & ratings" />
              <StepCard number="3" title="Book" description="Schedule your appointment" />
              <StepCard number="4" title="Get Results" description="Receive digital PDF results" />
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="relative py-14 sm:py-20 lg:py-28 bg-blue-600 overflow-hidden">
        {/* Decorative shapes */}
        <div className="absolute top-0 left-0 w-80 h-80 bg-blue-500 rounded-full opacity-30 -translate-y-1/2 -translate-x-1/3 pointer-events-none" />
        <div className="absolute bottom-0 right-0 w-96 h-96 bg-blue-700 rounded-full opacity-40 translate-y-1/3 translate-x-1/4 pointer-events-none" />
        <div className="absolute top-1/2 right-1/4 w-36 h-36 bg-blue-500 rounded-full opacity-20 -translate-y-1/2 pointer-events-none" />

        <div className="relative max-w-4xl mx-auto text-center px-4 sm:px-6">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 bg-white/10 text-white/90 rounded-full text-sm font-medium mb-6 border border-white/20">
            <CheckCircle2 className="w-4 h-4" />
            No registration required to browse
          </div>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4 leading-tight">
            Ready to Find Your Lab?
          </h2>
          <p className="text-lg sm:text-xl text-blue-100 mb-8">
            Find accredited labs across Egypt and book your tests in minutes
          </p>
          <button
            onClick={() => onNavigate('login')}
            className="px-8 py-3.5 bg-white text-blue-600 rounded-xl hover:bg-gray-50 hover:scale-105 active:scale-95 transition-all duration-150 text-base sm:text-lg font-bold shadow-lg hover:shadow-xl"
          >
            Get Started Now
          </button>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-400 pt-12 pb-6 sm:pt-16 sm:pb-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-10">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                  <TestTube className="w-5 h-5 text-white" />
                </div>
                <span className="text-white font-bold text-lg">
                  Tes<span className="text-blue-400">Tly</span>
                </span>
              </div>
              <p className="text-gray-500 text-sm leading-relaxed">
                Your trusted platform for comparing medical labs and booking tests across Egypt.
              </p>
            </div>
            <div>
              <h3 className="text-white font-semibold mb-4">For Patients</h3>
              <ul className="space-y-2.5 text-sm">
                <li><a href="#" className="hover:text-white transition-colors">Search Tests</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Book Appointment</a></li>
                <li><a href="#" className="hover:text-white transition-colors">View Results</a></li>
              </ul>
            </div>
            <div>
              <h3 className="text-white font-semibold mb-4">For Labs</h3>
              <ul className="space-y-2.5 text-sm">
                <li><a href="#" className="hover:text-white transition-colors">Register Your Lab</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Dashboard</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Analytics</a></li>
              </ul>
            </div>
            <div>
              <h3 className="text-white font-semibold mb-4">Support</h3>
              <ul className="space-y-2.5 text-sm">
                <li><a href="#" className="hover:text-white transition-colors">Help Center</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Privacy Policy</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Terms of Service</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 pt-6 flex flex-col sm:flex-row items-center justify-between gap-3">
            <p className="text-gray-500 text-sm">&copy; 2025 TesTly. All rights reserved.</p>
            <p className="text-gray-600 text-sm">Made with care in Egypt</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode; title: string; description: string }) {
  return (
    <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 cursor-default group">
      <div className="w-12 h-12 bg-blue-50 rounded-2xl flex items-center justify-center mb-4 group-hover:bg-blue-100 transition-colors duration-200">
        {icon}
      </div>
      <h3 className="text-base sm:text-lg font-semibold text-gray-900 mb-2">{title}</h3>
      <p className="text-sm text-gray-500 leading-relaxed">{description}</p>
    </div>
  );
}

function StepCard({ number, title, description }: { number: string; title: string; description: string }) {
  return (
    <div className="text-center group cursor-default">
      <div className="w-14 h-14 sm:w-16 sm:h-16 bg-blue-600 text-white rounded-2xl flex items-center justify-center text-xl sm:text-2xl font-bold mx-auto mb-4 group-hover:scale-110 group-hover:bg-blue-700 group-hover:shadow-lg transition-all duration-200 shadow-sm">
        {number}
      </div>
      <h3 className="text-sm sm:text-base lg:text-lg font-semibold text-gray-900 mb-1.5">{title}</h3>
      <p className="text-xs sm:text-sm text-gray-500">{description}</p>
    </div>
  );
}
