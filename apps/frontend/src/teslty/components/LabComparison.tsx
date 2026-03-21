import { useState, useEffect } from 'react';
import { ArrowLeft, MapPin, Star, Clock, Home, Filter, SlidersHorizontal, Info, Search } from 'lucide-react';

interface Lab {
  id: number;
  name: string;
  rating: number;
  reviews: number;
  distance: number;
  price: number;
  homeCollection: boolean;
  timeSlots: string[];
  address: string;
  accreditation: string;
  turnaroundTime: string;
}

interface LabComparisonProps {
  searchQuery: string;
  onLabSelect: (lab: Lab) => void;
  onBack: () => void;
}

export function LabComparison({ searchQuery, onLabSelect, onBack }: LabComparisonProps) {
  const [sortBy, setSortBy] = useState<'price' | 'rating' | 'distance'>('price');
  const [showFilters, setShowFilters] = useState(false);
  const [homeCollectionOnly, setHomeCollectionOnly] = useState(false);
  const [localSearchQuery, setLocalSearchQuery] = useState('');
  const [minRating, setMinRating] = useState(0);
  const [maxDistance, setMaxDistance] = useState(10);
  const [maxPrice, setMaxPrice] = useState(1000);
  const [selectedAccreditations, setSelectedAccreditations] = useState<string[]>([]);

  // Scroll to top when component mounts
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  // Mock data
  const labs: Lab[] = [
    {
      id: 1,
      name: 'Alaf labs',
      rating: 4.8,
      reviews: 342,
      distance: 1.2,
      price: 450,
      homeCollection: true,
      timeSlots: ['9:00 AM', '11:00 AM', '2:00 PM', '4:00 PM'],
      address: '12 Nile Corniche, Downtown Cairo',
      accreditation: 'NABL, CAP',
      turnaroundTime: '24 hours'
    },
    {
      id: 2,
      name: 'Al mokhtabar',
      rating: 4.6,
      reviews: 218,
      distance: 2.5,
      price: 380,
      homeCollection: true,
      timeSlots: ['8:00 AM', '10:00 AM', '1:00 PM', '3:00 PM'],
      address: '45 Tahrir Street, Garden City, Cairo',
      accreditation: 'NABL',
      turnaroundTime: '48 hours'
    },
    {
      id: 3,
      name: 'Daman labs',
      rating: 4.9,
      reviews: 567,
      distance: 3.8,
      price: 520,
      homeCollection: true,
      timeSlots: ['9:30 AM', '12:00 PM', '3:00 PM', '5:00 PM'],
      address: '78 El Merghany Street, Heliopolis, Cairo',
      accreditation: 'NABL, CAP, ISO',
      turnaroundTime: '12 hours'
    },
    {
      id: 4,
      name: 'Makka lab',
      rating: 4.3,
      reviews: 156,
      distance: 0.8,
      price: 350,
      homeCollection: false,
      timeSlots: ['8:30 AM', '11:30 AM', '2:30 PM'],
      address: '32 Ramses Street, Downtown Cairo',
      accreditation: 'NABL',
      turnaroundTime: '48 hours'
    },
    {
      id: 5,
      name: 'Future lab',
      rating: 4.7,
      reviews: 423,
      distance: 4.2,
      price: 580,
      homeCollection: true,
      timeSlots: ['7:00 AM', '10:00 AM', '1:00 PM', '4:00 PM', '6:00 PM'],
      address: '55 Road 9, Maadi, Cairo',
      accreditation: 'NABL, CAP, ISO, JCI',
      turnaroundTime: '6 hours'
    }
  ];

  const testInfo = {
    name: searchQuery || 'Complete Blood Count (CBC)',
    description: 'A complete blood count test measures several components of your blood including red blood cells, white blood cells, and platelets.',
    preparations: [
      'Fasting for 8-12 hours recommended',
      'Avoid alcohol 24 hours before test',
      'Stay hydrated',
      'Inform about any medications'
    ],
    commonlyDetects: ['Anemia', 'Infections', 'Blood disorders', 'Immune system issues']
  };

  const filteredLabs = labs
    .filter(lab => !homeCollectionOnly || lab.homeCollection)
    .filter(lab => lab.name.toLowerCase().includes(localSearchQuery.toLowerCase()))
    .filter(lab => lab.rating >= minRating)
    .filter(lab => lab.distance <= maxDistance)
    .filter(lab => lab.price <= maxPrice)
    .filter(lab => {
      if (selectedAccreditations.length === 0) return true;
      return selectedAccreditations.some(acc => lab.accreditation.includes(acc));
    })
    .sort((a, b) => {
      if (sortBy === 'price') return a.price - b.price;
      if (sortBy === 'rating') return b.rating - a.rating;
      return a.distance - b.distance;
    });

  const availableAccreditations = ['NABL', 'CAP', 'ISO', 'JCI'];

  const toggleAccreditation = (accreditation: string) => {
    setSelectedAccreditations(prev =>
      prev.includes(accreditation)
        ? prev.filter(a => a !== accreditation)
        : [...prev, accreditation]
    );
  };

  const clearAllFilters = () => {
    setHomeCollectionOnly(false);
    setMinRating(0);
    setMaxDistance(10);
    setMaxPrice(1000);
    setSelectedAccreditations([]);
  };

  const activeFiltersCount = 
    (homeCollectionOnly ? 1 : 0) +
    (minRating > 0 ? 1 : 0) +
    (maxDistance < 10 ? 1 : 0) +
    (maxPrice < 1000 ? 1 : 0) +
    selectedAccreditations.length;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <button onClick={onBack} className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4">
            <ArrowLeft className="w-5 h-5" />
            Back to Home
          </button>
          <h1 className="text-2xl text-gray-900">
            {testInfo.name}
          </h1>
          <p className="text-gray-600 mt-2">{testInfo.description}</p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Test Information Sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-xl shadow-sm p-6 sticky top-24">
              <h2 className="text-xl text-gray-900 mb-4">Test Preparation</h2>
              <ul className="space-y-3 mb-6">
                {testInfo.preparations.map((prep, index) => (
                  <li key={index} className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-2"></div>
                    <span className="text-gray-700">{prep}</span>
                  </li>
                ))}
              </ul>
              
              <h2 className="text-xl text-gray-900 mb-4">Commonly Detects</h2>
              <div className="flex flex-wrap gap-2">
                {testInfo.commonlyDetects.map((item, index) => (
                  <span key={index} className="px-3 py-1 bg-blue-50 text-blue-700 rounded-full">
                    {item}
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* Labs List */}
          <div className="lg:col-span-2">
            <div className="mb-6">
              <h2 className="text-xl text-gray-900 mb-2">Available Labs</h2>
              <p className="text-gray-600">Click on a lab name to view full details and all available tests</p>
            </div>
            {/* Filters and Sort */}
            <div className="bg-white rounded-xl shadow-sm p-4 mb-6">
              <div className="flex flex-wrap items-center justify-between gap-4 mb-4">
                <div className="flex items-center gap-4">
                  <button
                    onClick={() => setShowFilters(!showFilters)}
                    className={`flex items-center gap-2 px-4 py-2 border rounded-lg transition ${
                      showFilters 
                        ? 'bg-blue-50 border-blue-600 text-blue-600' 
                        : 'border-gray-300 hover:bg-gray-50'
                    }`}
                  >
                    <SlidersHorizontal className="w-4 h-4" />
                    Filters
                    {activeFiltersCount > 0 && (
                      <span className="ml-1 px-2 py-0.5 bg-blue-600 text-white rounded-full">
                        {activeFiltersCount}
                      </span>
                    )}
                  </button>
                  
                  <label className="flex items-center gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={homeCollectionOnly}
                      onChange={(e) => setHomeCollectionOnly(e.target.checked)}
                      className="w-4 h-4 text-blue-600 rounded"
                    />
                    <span className="text-gray-700">Home Collection Only</span>
                  </label>
                </div>

                <div className="flex items-center gap-2">
                  <span className="text-gray-600">Sort by:</span>
                  <select
                    value={sortBy}
                    onChange={(e) => setSortBy(e.target.value as any)}
                    className="px-4 py-2 border border-gray-300 rounded-lg"
                  >
                    <option value="price">Price (Low to High)</option>
                    <option value="rating">Rating (High to Low)</option>
                    <option value="distance">Distance (Nearest)</option>
                  </select>
                </div>
              </div>
              
              {/* Expandable Filters Panel */}
              {showFilters && (
                <div className="mb-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-gray-900">Advanced Filters</h3>
                    {activeFiltersCount > 0 && (
                      <button
                        onClick={clearAllFilters}
                        className="text-blue-600 hover:text-blue-700"
                      >
                        Clear All
                      </button>
                    )}
                  </div>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {/* Rating Filter */}
                    <div>
                      <label className="block text-gray-700 mb-2">
                        Minimum Rating: {minRating > 0 ? minRating.toFixed(1) : 'Any'}
                      </label>
                      <input
                        type="range"
                        min="0"
                        max="5"
                        step="0.5"
                        value={minRating}
                        onChange={(e) => setMinRating(parseFloat(e.target.value))}
                        className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer accent-blue-600"
                      />
                      <div className="flex justify-between text-gray-500 mt-1">
                        <span>Any</span>
                        <span>5.0</span>
                      </div>
                    </div>

                    {/* Distance Filter */}
                    <div>
                      <label className="block text-gray-700 mb-2">
                        Maximum Distance: {maxDistance < 10 ? `${maxDistance} km` : '10+ km'}
                      </label>
                      <input
                        type="range"
                        min="1"
                        max="10"
                        step="0.5"
                        value={maxDistance}
                        onChange={(e) => setMaxDistance(parseFloat(e.target.value))}
                        className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer accent-blue-600"
                      />
                      <div className="flex justify-between text-gray-500 mt-1">
                        <span>1 km</span>
                        <span>10+ km</span>
                      </div>
                    </div>

                    {/* Price Filter */}
                    <div>
                      <label className="block text-gray-700 mb-2">
                        Maximum Price: {maxPrice < 1000 ? `EGP ${maxPrice}` : 'EGP 1000+'}
                      </label>
                      <input
                        type="range"
                        min="100"
                        max="1000"
                        step="50"
                        value={maxPrice}
                        onChange={(e) => setMaxPrice(parseInt(e.target.value))}
                        className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer accent-blue-600"
                      />
                      <div className="flex justify-between text-gray-500 mt-1">
                        <span>EGP 100</span>
                        <span>EGP 1000+</span>
                      </div>
                    </div>

                    {/* Accreditation Filter */}
                    <div>
                      <label className="block text-gray-700 mb-2">Accreditations</label>
                      <div className="flex flex-wrap gap-2">
                        {availableAccreditations.map((acc) => (
                          <button
                            key={acc}
                            onClick={() => toggleAccreditation(acc)}
                            className={`px-3 py-1.5 rounded-lg border transition ${
                              selectedAccreditations.includes(acc)
                                ? 'bg-blue-600 text-white border-blue-600'
                                : 'bg-white text-gray-700 border-gray-300 hover:border-blue-600'
                            }`}
                          >
                            {acc}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}
              
              {/* Search Input */}
              <div className="relative">
                <Search className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
                <input
                  type="text"
                  value={localSearchQuery}
                  onChange={(e) => setLocalSearchQuery(e.target.value)}
                  placeholder="Search labs by name..."
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            {/* Lab Cards */}
            <div className="space-y-4">
              {filteredLabs.length === 0 ? (
                <div className="bg-white rounded-xl shadow-sm p-12 text-center">
                  <Search className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-xl text-gray-900 mb-2">No labs found</h3>
                  <p className="text-gray-600">
                    Try adjusting your search or filters to find more labs
                  </p>
                </div>
              ) : (
                filteredLabs.map((lab) => (
                  <div key={lab.id} className="bg-white rounded-xl shadow-sm p-6 hover:shadow-md transition">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex-1">
                        <button 
                          onClick={() => onLabSelect(lab)}
                          className="text-xl text-blue-600 hover:text-blue-700 mb-2 flex items-center gap-2"
                        >
                          {lab.name}
                          <Info className="w-5 h-5" />
                        </button>
                        <div className="flex items-center gap-4 text-gray-600">
                          <div className="flex items-center gap-1">
                            <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                            <span>{lab.rating}</span>
                            <span>({lab.reviews} reviews)</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <MapPin className="w-4 h-4" />
                            <span>{lab.distance} km away</span>
                          </div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-3xl text-blue-600">EGP {lab.price}</div>
                        <div className="text-gray-500">for this test</div>
                      </div>
                    </div>

                    <div className="flex items-center gap-2 text-gray-600 mb-4">
                      <MapPin className="w-4 h-4" />
                      <span>{lab.address}</span>
                    </div>

                    <div className="grid grid-cols-2 gap-4 mb-4 pb-4 border-b border-gray-200">
                      <div>
                        <div className="text-gray-500 mb-1">Accreditation</div>
                        <div className="text-gray-900">{lab.accreditation}</div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Turnaround Time</div>
                        <div className="flex items-center gap-1 text-gray-900">
                          <Clock className="w-4 h-4" />
                          {lab.turnaroundTime}
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        {lab.homeCollection && (
                          <div className="flex items-center gap-1 text-green-600">
                            <Home className="w-4 h-4" />
                            <span>Home Collection Available</span>
                          </div>
                        )}
                        <div className="text-gray-600">
                          {lab.timeSlots.length} slots available today
                        </div>
                      </div>
                      <button
                        onClick={() => onLabSelect(lab)}
                        className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                      >
                        Book Now
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
