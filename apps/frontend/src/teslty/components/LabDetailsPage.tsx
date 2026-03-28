import { useState, useEffect } from 'react';
import { ArrowLeft, MapPin, Star, Clock, Home, Phone, Mail, Award, Calendar } from 'lucide-react';
import type { PublicLabCard } from '../../lib/publicApi';

type LabDetailsTest = {
  id: string;
  name: string;
  category: string;
  priceEgp: number;
  description: string | null;
  preparation: string | null;
  turnaroundTime: string | null;
  parametersCount: number | null;
};

interface LabDetailsPageProps {
  lab?: PublicLabCard | null;
  tests: LabDetailsTest[];
  isLoading?: boolean;
  timeSlots?: string[];
  onBack: () => void;
  onBookTest: (lab: PublicLabCard, test: LabDetailsTest) => void;
}

export function LabDetailsPage({ lab, tests, isLoading, timeSlots, onBack, onBookTest }: LabDetailsPageProps) {
  const [selectedCategory, setSelectedCategory] = useState('all');

  // Scroll to top when component mounts
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <p>Loading lab…</p>
      </div>
    );
  }

  if (!lab) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p>No lab selected</p>
      </div>
    );
  }

  const categories = ['all', ...Array.from(new Set(tests.map((t) => t.category))).sort()];
  
  const filteredTests = selectedCategory === 'all' 
    ? tests 
    : tests.filter(test => test.category === selectedCategory);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <button onClick={onBack} className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4">
            <ArrowLeft className="w-5 h-5" />
            Back to Home
          </button>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Lab Header */}
        <div className="bg-white rounded-xl shadow-sm p-8 mb-6">
          <div className="flex items-start justify-between mb-6">
            <div className="flex-1">
              <h1 className="text-3xl text-gray-900 mb-3">{lab.name}</h1>
              <div className="flex items-center gap-6 text-gray-600 mb-4">
                <div className="flex items-center gap-1">
                  <Star className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                  <span className="text-xl">{lab.rating ?? '—'}</span>
                  <span>({lab.reviews} reviews)</span>
                </div>
                <div className="flex items-center gap-1">
                  <MapPin className="w-5 h-5" />
                  <span>{lab.distanceKm} km away</span>
                </div>
              </div>
              <div className="flex items-center gap-2 text-gray-600 mb-4">
                <MapPin className="w-5 h-5" />
                <span>{lab.address}</span>
              </div>
            </div>
            {lab.homeCollection && (
              <div className="flex items-center gap-2 px-4 py-2 bg-green-50 text-green-700 rounded-lg">
                <Home className="w-5 h-5" />
                <span>Home Collection Available</span>
              </div>
            )}
          </div>

          {/* Lab Details Grid */}
          <div className="grid grid-cols-4 gap-6 pb-6 border-b border-gray-200 mb-6">
            <div>
              <div className="flex items-center gap-2 text-gray-500 mb-2">
                <Award className="w-5 h-5" />
                <span>Accreditation</span>
              </div>
              <div className="text-gray-900">{lab.accreditation ?? '—'}</div>
            </div>
            <div>
              <div className="flex items-center gap-2 text-gray-500 mb-2">
                <Clock className="w-5 h-5" />
                <span>Turnaround Time</span>
              </div>
              <div className="text-gray-900">{lab.turnaroundTime ?? '—'}</div>
            </div>
            <div>
              <div className="flex items-center gap-2 text-gray-500 mb-2">
                <Phone className="w-5 h-5" />
                <span>Contact</span>
              </div>
              <div className="text-gray-900">+20 2 1234 5678</div>
            </div>
            <div>
              <div className="flex items-center gap-2 text-gray-500 mb-2">
                <Mail className="w-5 h-5" />
                <span>Email</span>
              </div>
              <div className="text-gray-900">info@{lab.name.toLowerCase().replace(/\s+/g, '')}.com</div>
            </div>
          </div>

          {/* Available Time Slots */}
          <div>
            <h3 className="text-lg text-gray-900 mb-3">Available Time Slots Today</h3>
            <div className="flex flex-wrap gap-2">
              {timeSlots?.map((time: string, index: number) => (
                <span key={index} className="px-4 py-2 bg-blue-50 text-blue-700 rounded-lg">
                  {time}
                </span>
              ))}
            </div>
          </div>
        </div>

        {/* Test Catalog */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl text-gray-900">Available Tests</h2>
            <div className="text-gray-600">{filteredTests.length} tests available</div>
          </div>

          {/* Category Filter */}
          <div className="flex flex-wrap gap-2 mb-6 pb-6 border-b border-gray-200">
            {categories.map((category) => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-4 py-2 rounded-lg transition ${
                  selectedCategory === category
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {category === 'all' ? 'All Tests' : category}
              </button>
            ))}
          </div>

          {/* Tests Grid */}
          <div className="grid grid-cols-1 gap-4">
            {filteredTests.map((test) => (
              <div key={test.id} className="border border-gray-200 rounded-lg p-6 hover:border-blue-300 transition">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <div className="flex items-start justify-between mb-2">
                      <h3 className="text-xl text-gray-900">{test.name}</h3>
                      <div className="text-right ml-4">
                        <div className="text-2xl text-blue-600">EGP {test.priceEgp}</div>
                      </div>
                    </div>
                    <p className="text-gray-600 mb-3">{test.description ?? '—'}</p>
                    <div className="grid grid-cols-3 gap-4 mb-4">
                      <div>
                        <div className="text-gray-500 mb-1">Preparation</div>
                        <div className="text-gray-900">{test.preparation ?? '—'}</div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Turnaround</div>
                        <div className="flex items-center gap-1 text-gray-900">
                          <Clock className="w-4 h-4" />
                          {test.turnaroundTime ?? '—'}
                        </div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Parameters</div>
                        <div className="text-gray-900">{test.parametersCount ?? '—'} parameters tested</div>
                      </div>
                    </div>
                  </div>
                </div>
                <button
                  onClick={() => onBookTest(lab, test)}
                  className="flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                  <Calendar className="w-4 h-4" />
                  Book This Test
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
