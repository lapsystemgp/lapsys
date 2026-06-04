import { useMemo, useState, useEffect } from 'react';
import { ArrowLeft, MapPin, Star, Clock, Home, SlidersHorizontal, Info, Search, FlaskConical, ChevronRight } from 'lucide-react';
import { fetchPublicLabs, fetchPublicTests, type PublicLabCard, type PublicTestCard } from '../../lib/publicApi';
import { Breadcrumb } from '../../components/Breadcrumb';

interface LabComparisonProps {
  searchQuery: string;
  initialSort?: 'price' | 'rating' | 'distance';
  initialCity?: string;
  onLabSelect: (lab: PublicLabCard) => void;
  onTestSelect: (test: PublicTestCard) => void;
  onBack: () => void;
}

export function LabComparison({ searchQuery, initialSort = 'price', initialCity = '', onLabSelect, onTestSelect, onBack }: LabComparisonProps) {
  const [sortBy, setSortBy] = useState<'price' | 'rating' | 'distance'>(initialSort);
  const [showFilters, setShowFilters] = useState(false);
  const [homeCollectionOnly, setHomeCollectionOnly] = useState(false);
  const [localSearchQuery, setLocalSearchQuery] = useState(searchQuery);
  const [localCity, setLocalCity] = useState(initialCity);
  const [minRating, setMinRating] = useState(0);
  const [maxDistance, setMaxDistance] = useState(10);
  const [maxPrice, setMaxPrice] = useState(1000);
  const [selectedAccreditations, setSelectedAccreditations] = useState<string[]>([]);
  const [labs, setLabs] = useState<PublicLabCard[]>([]);
  const [tests, setTests] = useState<PublicTestCard[]>([]);
  const [lastResolvedKey, setLastResolvedKey] = useState<string>('');
  const [testsLoaded, setTestsLoaded] = useState(false);
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [locationStatus, setLocationStatus] = useState<'idle' | 'requesting' | 'denied'>('idle');

  const effectiveSearchQuery = localSearchQuery.trim();
  const [activeTab, setActiveTab] = useState<'tests' | 'labs'>(searchQuery.trim() ? 'tests' : 'labs');

  useEffect(() => {
    if (sortBy !== 'distance' || userLocation || locationStatus !== 'idle') return;
    if (!navigator.geolocation) { setLocationStatus('denied'); return; }
    setLocationStatus('requesting');
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setUserLocation({ lat: pos.coords.latitude, lng: pos.coords.longitude });
        setLocationStatus('idle');
      },
      () => setLocationStatus('denied'),
      { timeout: 10000 },
    );
  }, [sortBy, userLocation, locationStatus]);

  const requestKey = useMemo(
    () =>
      JSON.stringify({
        localSearchQuery,
        localCity,
        sortBy,
        homeCollectionOnly,
        minRating,
        maxDistance,
        maxPrice,
        selectedAccreditations,
        userLocation,
      }),
    [homeCollectionOnly, localCity, localSearchQuery, maxDistance, maxPrice, minRating, selectedAccreditations, sortBy, userLocation],
  );

  const isLoading = lastResolvedKey !== '' && lastResolvedKey !== requestKey;

  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  useEffect(() => {
    setLocalSearchQuery(searchQuery);
    setActiveTab(searchQuery.trim() ? 'tests' : 'labs');
  }, [searchQuery]);

  useEffect(() => {
    setLocalCity(initialCity);
  }, [initialCity]);

  // Fetch tests whenever the search query changes
  useEffect(() => {
    let isMounted = true;
    setTestsLoaded(false);
    fetchPublicTests({ q: effectiveSearchQuery || undefined, pageSize: 50 })
      .then((res) => {
        if (!isMounted) return;
        setTests(res.items);
        setTestsLoaded(true);
      })
      .catch(() => {
        if (!isMounted) return;
        setTests([]);
        setTestsLoaded(true);
      });
    return () => { isMounted = false; };
  }, [effectiveSearchQuery]);

  useEffect(() => {
    let isMounted = true;
    fetchPublicLabs({
      q: effectiveSearchQuery || undefined,
      city: localCity.trim() || undefined,
      sort: sortBy,
      minRating: minRating > 0 ? minRating : undefined,
      maxDistanceKm: userLocation && maxDistance < 10 ? maxDistance : undefined,
      maxPriceEgp: maxPrice < 1000 ? maxPrice : undefined,
      homeCollection: homeCollectionOnly ? true : undefined,
      accreditations: selectedAccreditations.length > 0 ? selectedAccreditations : undefined,
      userLat: userLocation?.lat,
      userLng: userLocation?.lng,
      page: 1,
      pageSize: 50,
    })
      .then((res) => {
        if (!isMounted) return;
        setLabs(res.items);
        setLastResolvedKey(requestKey);
      })
      .catch(() => {
        if (!isMounted) return;
        setLabs([]);
        setLastResolvedKey(requestKey);
      });
    return () => { isMounted = false; };
  }, [effectiveSearchQuery, homeCollectionOnly, maxDistance, maxPrice, minRating, requestKey, selectedAccreditations, sortBy, userLocation]);

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

  const getPlaceholderTimeSlots = (stableId: string) => {
    const slots = ['08:00', '09:30', '11:00', '13:00', '15:00', '16:30', '18:00'];
    const seed = stableId.split('').reduce((acc, ch) => acc + ch.charCodeAt(0), 0);
    const count = 3 + (seed % 3);
    const start = seed % (slots.length - count);
    return slots.slice(start, start + count);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
          <Breadcrumb items={[{ label: "Search Results" }]} className="mb-2" />
          <button onClick={onBack} className="flex items-center gap-2 text-gray-600 hover:text-gray-900 hover:-translate-x-0.5 transition-all duration-150 mb-2">
            <ArrowLeft className="w-4 h-4" />
            Back to Home
          </button>
          <h1 className="text-xl text-gray-900">{effectiveSearchQuery || 'All Available Tests & Labs'}</h1>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-5">
        {/* Tabs */}
        <div className="flex gap-1 mb-5 border-b border-gray-200">
          <button
            onClick={() => setActiveTab('tests')}
            className={`px-5 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors ${
              activeTab === 'tests'
                ? 'border-blue-600 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700'
            }`}
          >
            Tests
            {testsLoaded && tests.length > 0 && (
              <span className={`ml-2 px-2 py-0.5 rounded-full text-xs ${activeTab === 'tests' ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-600'}`}>
                {tests.length}
              </span>
            )}
          </button>
          <button
            onClick={() => setActiveTab('labs')}
            className={`px-5 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors ${
              activeTab === 'labs'
                ? 'border-blue-600 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700'
            }`}
          >
            Labs
            {lastResolvedKey !== '' && labs.length > 0 && (
              <span className={`ml-2 px-2 py-0.5 rounded-full text-xs ${activeTab === 'labs' ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-600'}`}>
                {labs.length}
              </span>
            )}
          </button>
        </div>

        {/* Search bar (always visible) */}
        <div className="bg-white rounded-xl shadow-sm p-3 mb-5">
          <div className="flex flex-col sm:flex-row gap-2">
            <div className="relative flex-1">
              <Search className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={localSearchQuery}
                onChange={(e) => {
                  setLocalSearchQuery(e.target.value);
                  setActiveTab(e.target.value.trim() ? 'tests' : 'labs');
                }}
                placeholder="Search tests or labs..."
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="relative sm:w-52">
              <MapPin className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={localCity}
                onChange={(e) => setLocalCity(e.target.value)}
                placeholder="Filter by city…"
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
        </div>

        {activeTab === 'tests' ? (
          /* ── Tests Tab ─────────────────────────────────────────── */
          <div>
            {!testsLoaded ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {[0, 1, 2, 3].map((i) => (
                  <div key={i} className={`bg-white rounded-xl shadow-sm p-5 animate-slide-up ${i === 1 ? 'animation-delay-100' : i === 2 ? 'animation-delay-200' : ''}`}>
                    <div className="flex items-start gap-3 mb-3">
                      <div className="skeleton h-10 w-10 rounded-lg shrink-0" />
                      <div className="flex-1 space-y-2">
                        <div className="skeleton h-5 w-48 rounded" />
                        <div className="skeleton h-4 w-28 rounded" />
                      </div>
                    </div>
                    <div className="flex items-center justify-between">
                      <div className="skeleton h-4 w-32 rounded" />
                      <div className="skeleton h-4 w-24 rounded" />
                    </div>
                  </div>
                ))}
              </div>
            ) : tests.length === 0 ? (
              <div className="bg-white rounded-xl shadow-sm p-12 text-center">
                <FlaskConical className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-xl text-gray-900 mb-2">No tests found</h3>
                <p className="text-gray-600 mb-4">
                  {effectiveSearchQuery
                    ? `No tests matched "${effectiveSearchQuery}"`
                    : 'No tests available'}
                </p>
                <button
                  onClick={() => setActiveTab('labs')}
                  className="px-5 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Browse Labs Instead
                </button>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {tests.map((test) => (
                  <button
                    key={`${test.name}__${test.category}`}
                    onClick={() => onTestSelect(test)}
                    className="bg-white rounded-xl shadow-sm p-5 hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 text-left flex flex-col gap-3"
                  >
                    <div className="flex items-start gap-3">
                      <div className="w-10 h-10 bg-blue-50 rounded-lg flex items-center justify-center shrink-0">
                        <FlaskConical className="w-5 h-5 text-blue-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-gray-900 truncate">{test.name}</div>
                        <div className="text-sm text-gray-500 mt-0.5">{test.category}</div>
                      </div>
                    </div>
                    <div className="flex items-center justify-between">
                      <div className="text-sm text-gray-600">
                        {test.minPriceEgp != null
                          ? <span>from <span className="font-medium text-blue-600">EGP {test.minPriceEgp}</span></span>
                          : '—'
                        }
                        <span className="mx-2 text-gray-300">·</span>
                        <span>Available at {test.labCount} {test.labCount === 1 ? 'lab' : 'labs'}</span>
                      </div>
                      <div className="flex items-center gap-1 text-blue-600 text-sm font-medium shrink-0">
                        View labs <ChevronRight className="w-4 h-4" />
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>
        ) : (
          /* ── Labs Tab ──────────────────────────────────────────── */
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
            {/* Sidebar */}
            <div className="lg:col-span-1">
              <div className="bg-white rounded-xl shadow-sm p-5 sticky top-[72px]">
                <h2 className="text-base font-medium text-gray-900 mb-3">Browse Labs</h2>
                <p className="text-sm text-gray-600 mb-4">
                  Compare prices, ratings, and availability across labs. Click a lab name to view full details.
                </p>
                {testsLoaded && tests.length > 0 && (
                  <div className="mt-3 pt-3 border-t border-gray-100">
                    <p className="text-sm text-gray-500 mb-2">Also found:</p>
                    <button
                      onClick={() => setActiveTab('tests')}
                      className="flex items-center gap-2 text-sm text-blue-600 hover:text-blue-700"
                    >
                      <FlaskConical className="w-4 h-4" />
                      {tests.length} matching test{tests.length !== 1 ? 's' : ''}
                      <ChevronRight className="w-3.5 h-3.5" />
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Labs List */}
            <div className="lg:col-span-2">
              <div className="mb-4">
                <h2 className="text-base font-medium text-gray-900 mb-0.5">Available Labs</h2>
                <p className="text-sm text-gray-500">Click on a lab name to view full details and all available tests</p>
              </div>

              {/* Filters and Sort */}
              <div className="bg-white rounded-xl shadow-sm p-3 mb-4">
                <div className="flex flex-wrap items-center justify-between gap-4">
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
                        <span className="ml-1 px-2 py-0.5 bg-blue-600 text-white rounded-full text-xs">
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
                      onChange={(e) => {
                        const value = e.target.value;
                        if (value === 'price' || value === 'rating' || value === 'distance') setSortBy(value);
                      }}
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
                  <div className="mt-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
                    <div className="flex items-center justify-between mb-4">
                      <h3 className="text-gray-900">Advanced Filters</h3>
                      {activeFiltersCount > 0 && (
                        <button onClick={clearAllFilters} className="text-blue-600 hover:text-blue-700">
                          Clear All
                        </button>
                      )}
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-gray-700 mb-2">
                          Minimum Rating: {minRating > 0 ? minRating.toFixed(1) : 'Any'}
                        </label>
                        <input
                          type="range" min="0" max="5" step="0.5" value={minRating}
                          onChange={(e) => setMinRating(parseFloat(e.target.value))}
                          className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer accent-blue-600"
                        />
                        <div className="flex justify-between text-gray-500 mt-1">
                          <span>Any</span><span>5.0</span>
                        </div>
                      </div>

                      <div>
                        <label className="block text-gray-700 mb-2">
                          Maximum Distance: {maxDistance < 10 ? `${maxDistance} km` : '10+ km'}
                        </label>
                        <input
                          type="range" min="1" max="10" step="0.5" value={maxDistance}
                          onChange={(e) => setMaxDistance(parseFloat(e.target.value))}
                          className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer accent-blue-600"
                        />
                        <div className="flex justify-between text-gray-500 mt-1">
                          <span>1 km</span><span>10+ km</span>
                        </div>
                      </div>

                      <div>
                        <label className="block text-gray-700 mb-2">
                          Maximum Price: {maxPrice < 1000 ? `EGP ${maxPrice}` : 'EGP 1000+'}
                        </label>
                        <input
                          type="range" min="100" max="1000" step="50" value={maxPrice}
                          onChange={(e) => setMaxPrice(parseInt(e.target.value))}
                          className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer accent-blue-600"
                        />
                        <div className="flex justify-between text-gray-500 mt-1">
                          <span>EGP 100</span><span>EGP 1000+</span>
                        </div>
                      </div>

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
              </div>

              {/* Location status banners */}
              {sortBy === 'distance' && locationStatus === 'requesting' && (
                <div className="flex items-center gap-2 px-4 py-3 bg-blue-50 border border-blue-200 rounded-lg text-blue-700 text-sm mb-4">
                  <MapPin className="w-4 h-4 animate-pulse flex-shrink-0" />
                  Getting your location to sort by nearest…
                </div>
              )}
              {sortBy === 'distance' && locationStatus === 'denied' && (
                <div className="flex items-center gap-2 px-4 py-3 bg-amber-50 border border-amber-200 rounded-lg text-amber-700 text-sm mb-4">
                  <MapPin className="w-4 h-4 flex-shrink-0" />
                  Location access denied — showing approximate distances instead. Allow location in your browser to sort by actual distance.
                </div>
              )}

              {/* Lab Cards */}
              <div className="space-y-3">
                {lastResolvedKey === '' || (isLoading && labs.length === 0) ? (
                  <>
                    {[0, 1, 2].map((i) => (
                      <div key={i} className={`bg-white rounded-xl shadow-sm p-5 animate-slide-up ${i === 1 ? 'animation-delay-100' : i === 2 ? 'animation-delay-200' : ''}`}>
                        <div className="flex items-start justify-between mb-3">
                          <div className="flex-1 space-y-2">
                            <div className="skeleton h-5 w-48 rounded" />
                            <div className="skeleton h-4 w-32 rounded" />
                          </div>
                          <div className="skeleton h-8 w-20 rounded" />
                        </div>
                        <div className="skeleton h-4 w-64 mb-3 rounded" />
                        <div className="grid grid-cols-2 gap-3 mb-3 pb-3 border-b border-gray-100">
                          <div className="skeleton h-4 w-24 rounded" />
                          <div className="skeleton h-4 w-24 rounded" />
                        </div>
                        <div className="flex items-center justify-between">
                          <div className="skeleton h-4 w-40 rounded" />
                          <div className="skeleton h-9 w-24 rounded-lg" />
                        </div>
                      </div>
                    ))}
                  </>
                ) : labs.length === 0 ? (
                  <div className="bg-white rounded-xl shadow-sm p-12 text-center">
                    <Search className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                    <h3 className="text-xl text-gray-900 mb-2">No labs found</h3>
                    <p className="text-gray-600">
                      Try adjusting your search or filters to find more labs
                    </p>
                  </div>
                ) : (
                  labs.map((lab) => {
                    const price = lab.priceForQueryEgp ?? lab.startingFromEgp;
                    const priceLabel = lab.priceForQueryEgp ? 'for this test' : 'starting from';
                    const timeSlots = getPlaceholderTimeSlots(lab.id);
                    return (
                      <div key={lab.id} className="bg-white rounded-xl shadow-sm p-5 hover:shadow-md hover:-translate-y-0.5 transition-all duration-200">
                        <div className="flex items-start justify-between mb-3">
                          <div className="flex-1">
                            <button
                              onClick={() => onLabSelect(lab)}
                              className="text-lg text-blue-600 hover:text-blue-700 mb-1.5 flex items-center gap-2"
                            >
                              {lab.name}
                              <Info className="w-4 h-4" />
                            </button>
                            <div className="flex items-center gap-4 text-gray-600 text-sm">
                              <div className="flex items-center gap-1">
                                <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                                <span>{lab.rating ?? '—'}</span>
                                <span>({lab.reviews} reviews)</span>
                              </div>
                              {lab.distanceKm !== null && (
                                <div className="flex items-center gap-1">
                                  <MapPin className="w-4 h-4" />
                                  <span>{lab.distanceKm} km away</span>
                                </div>
                              )}
                            </div>
                          </div>
                          <div className="text-right">
                            <div className="text-2xl text-blue-600">EGP {price ?? '—'}</div>
                            <div className="text-gray-500 text-sm">{priceLabel}</div>
                          </div>
                        </div>

                        <div className="flex items-center gap-2 text-gray-600 text-sm mb-3">
                          <MapPin className="w-4 h-4" />
                          <span>{lab.address}</span>
                        </div>

                        <div className="grid grid-cols-2 gap-3 mb-3 pb-3 border-b border-gray-200 text-sm">
                          <div>
                            <div className="text-gray-500 mb-0.5">Accreditation</div>
                            <div className="text-gray-900">{lab.accreditation ?? '—'}</div>
                          </div>
                          <div>
                            <div className="text-gray-500 mb-0.5">Turnaround Time</div>
                            <div className="flex items-center gap-1 text-gray-900">
                              <Clock className="w-4 h-4" />
                              {lab.turnaroundTime ?? '—'}
                            </div>
                          </div>
                        </div>

                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-4 text-sm">
                            {lab.homeCollection && (
                              <div className="flex items-center gap-1 text-green-600">
                                <Home className="w-4 h-4" />
                                <span>Home Collection</span>
                              </div>
                            )}
                            <div className="text-gray-600">
                              {timeSlots.length} slots today
                            </div>
                          </div>
                          <button
                            onClick={() => onLabSelect(lab)}
                            className="px-5 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                          >
                            Book Now
                          </button>
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
