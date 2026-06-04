import { useState, useEffect } from 'react';
import { ArrowLeft, MapPin, Star, Clock, Home, Phone, Mail, Award, Calendar, MessageSquare } from 'lucide-react';
import type { PublicLabCard, PublicReview } from '../../lib/publicApi';
import { Breadcrumb } from '../../components/Breadcrumb';

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
  reviewItems?: PublicReview[];
  isLoading?: boolean;
  onBack: () => void;
  onBookTest: (lab: PublicLabCard, test: LabDetailsTest) => void;
}

export function LabDetailsPage({ lab, tests, reviewItems = [], isLoading, onBack, onBookTest }: LabDetailsPageProps) {
  const [selectedCategory, setSelectedCategory] = useState('all');

  // Scroll to top when component mounts
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div className="skeleton h-3.5 w-32 mb-3 rounded" />
            <div className="skeleton h-4 w-24 mb-4 rounded" />
          </div>
        </div>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="bg-white rounded-xl shadow-sm p-8 mb-6 animate-slide-up">
            <div className="skeleton h-8 w-64 mb-3 rounded" />
            <div className="flex gap-6 mb-4">
              <div className="skeleton h-5 w-24 rounded" />
              <div className="skeleton h-5 w-20 rounded" />
            </div>
            <div className="skeleton h-4 w-48 mb-6 rounded" />
            <div className="grid grid-cols-4 gap-6 pb-6 border-b border-gray-100 mb-6">
              {[0,1,2,3].map(i => (
                <div key={i}>
                  <div className="skeleton h-3.5 w-24 mb-2 rounded" />
                  <div className="skeleton h-4 w-16 rounded" />
                </div>
              ))}
            </div>
            <div className="skeleton h-4 w-40 mb-3 rounded" />
            <div className="flex gap-2">
              {[0,1,2,3].map(i => <div key={i} className="skeleton h-9 w-20 rounded-lg" />)}
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6 animate-slide-up animation-delay-100">
            <div className="skeleton h-6 w-36 mb-6 rounded" />
            <div className="flex gap-2 mb-6 pb-6 border-b border-gray-100">
              {[0,1,2].map(i => <div key={i} className="skeleton h-9 w-24 rounded-lg" />)}
            </div>
            <div className="space-y-4">
              {[0,1,2].map(i => (
                <div key={i} className="border border-gray-100 rounded-lg p-6">
                  <div className="skeleton h-6 w-48 mb-2 rounded" />
                  <div className="skeleton h-4 w-full mb-4 rounded" />
                  <div className="grid grid-cols-3 gap-4 mb-4">
                    {[0,1,2].map(j => (
                      <div key={j}>
                        <div className="skeleton h-3.5 w-20 mb-1 rounded" />
                        <div className="skeleton h-4 w-28 rounded" />
                      </div>
                    ))}
                  </div>
                  <div className="skeleton h-10 w-36 rounded-lg" />
                </div>
              ))}
            </div>
          </div>
        </div>
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
          <Breadcrumb
            items={[{ label: "Labs", href: "/labs" }, { label: lab.name }]}
            className="mb-3"
          />
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
                {lab.distanceKm !== null && (
                  <div className="flex items-center gap-1">
                    <MapPin className="w-5 h-5" />
                    <span>{lab.distanceKm} km away</span>
                  </div>
                )}
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
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 pb-6 border-b border-gray-200 mb-6">
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
            {lab.phone && (
              <div>
                <div className="flex items-center gap-2 text-gray-500 mb-2">
                  <Phone className="w-5 h-5" />
                  <span>Contact</span>
                </div>
                <div className="text-gray-900">{lab.phone}</div>
              </div>
            )}
            {lab.contactEmail && (
              <div>
                <div className="flex items-center gap-2 text-gray-500 mb-2">
                  <Mail className="w-5 h-5" />
                  <span>Email</span>
                </div>
                <div className="text-gray-900">{lab.contactEmail}</div>
              </div>
            )}
          </div>

        </div>

        {/* Reviews */}
        {reviewItems.length > 0 && (
          <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
            <div className="flex items-center gap-2 mb-6">
              <MessageSquare className="w-5 h-5 text-blue-600" />
              <h2 className="text-2xl text-gray-900">Patient Reviews</h2>
              <span className="text-gray-500">({reviewItems.length})</span>
            </div>
            <div className="space-y-4">
              {reviewItems.map((review) => (
                <div key={review.id} className="border border-gray-100 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-sm font-medium">
                        {review.patientName[0].toUpperCase()}
                      </div>
                      <span className="text-gray-900 font-medium">{review.patientName}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      {Array.from({ length: 5 }).map((_, i) => (
                        <Star
                          key={i}
                          className={`w-4 h-4 ${i < review.rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'}`}
                        />
                      ))}
                    </div>
                  </div>
                  {review.comment && (
                    <p className="text-gray-600 text-sm mt-2">{review.comment}</p>
                  )}
                  <p className="text-gray-400 text-xs mt-2">
                    {new Date(review.createdAt).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })}
                  </p>
                </div>
              ))}
            </div>
          </div>
        )}

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
