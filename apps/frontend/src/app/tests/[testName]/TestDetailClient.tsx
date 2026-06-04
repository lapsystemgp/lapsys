"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter, useParams, useSearchParams } from "next/navigation";
import {
  ArrowLeft,
  MapPin,
  Star,
  Clock,
  Home,
  FlaskConical,
  BookOpen,
  AlertCircle,
  SlidersHorizontal,
  X,
  Navigation,
} from "lucide-react";
import { fetchTestOffers, type TestOffersResponse, type TestOfferLab } from "../../../lib/publicApi";
import { Breadcrumb } from "../../../components/Breadcrumb";

type SortKey = "nearest" | "price" | "rating";
type NearestSecondary = "price" | "rating";

interface Filters {
  sort: SortKey;
  nearestSecondary: NearestSecondary;
  maxPrice: number;
  minRating: number;
  homeCollectionOnly: boolean;
}

const DEFAULT_FILTERS: Filters = {
  sort: "nearest",
  nearestSecondary: "price",
  maxPrice: 0,
  minRating: 0,
  homeCollectionOnly: false,
};

function haversineKm(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return Math.round(R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)) * 10) / 10;
}

function DistanceBadge({ km }: { km: number }) {
  return (
    <span className="flex items-center gap-1 text-blue-600 font-medium">
      <Navigation className="w-3.5 h-3.5" />
      {km < 1 ? `${Math.round(km * 1000)} m` : `${km.toFixed(1)} km`}
    </span>
  );
}

type LabWithDistance = TestOfferLab & { distanceKm: number | null };

export default function TestDetailClient() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();

  const testName = decodeURIComponent(params.testName as string);
  const category = searchParams.get("category") ?? undefined;

  const [data, setData] = useState<TestOffersResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [filters, setFilters] = useState<Filters>(DEFAULT_FILTERS);

  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  // Single fetch on mount — no dependency on location
  useEffect(() => {
    let isMounted = true;
    setIsLoading(true);
    setNotFound(false);
    fetchTestOffers({ name: testName, category })
      .then((res) => {
        if (!isMounted) return;
        setData(res);
        setIsLoading(false);
      })
      .catch(() => {
        if (!isMounted) return;
        setNotFound(true);
        setIsLoading(false);
      });
    return () => { isMounted = false; };
  }, [testName, category]);

  // Request geolocation independently — updates sort/distance without refetching
  useEffect(() => {
    if (!navigator.geolocation) {
      setFilters((f) => (f.sort === "nearest" ? { ...f, sort: "price" } : f));
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setUserLocation({ lat: pos.coords.latitude, lng: pos.coords.longitude });
      },
      () => {
        setFilters((f) => (f.sort === "nearest" ? { ...f, sort: "price" } : f));
      },
      { timeout: 8000 },
    );
  }, []);

  const preparations = data?.preparation
    ? data.preparation.split(/[,;\n]+/).map((s) => s.trim()).filter(Boolean)
    : [];

  // Compute distances client-side whenever userLocation or data changes
  const labsWithDistance = useMemo<LabWithDistance[]>(() => {
    if (!data) return [];
    return data.labs.map((lab) => ({
      ...lab,
      distanceKm:
        userLocation && lab.latitude != null && lab.longitude != null
          ? haversineKm(userLocation.lat, userLocation.lng, lab.latitude, lab.longitude)
          : null,
    }));
  }, [data, userLocation]);

  const maxPossiblePrice = useMemo(
    () => Math.max(...(data?.labs.map((l) => l.priceEgp) ?? [0]), 0),
    [data],
  );

  useEffect(() => {
    if (maxPossiblePrice > 0 && filters.maxPrice === 0) {
      setFilters((f) => ({ ...f, maxPrice: maxPossiblePrice }));
    }
  }, [maxPossiblePrice]);

  const hasDistance = useMemo(
    () => labsWithDistance.some((l) => l.distanceKm != null),
    [labsWithDistance],
  );

  // When location comes in after data is loaded, activate nearest sort automatically
  useEffect(() => {
    if (hasDistance) {
      setFilters((f) => (f.sort === "price" ? { ...f, sort: "nearest" } : f));
    }
  }, [hasDistance]);

  const displayedLabs = useMemo<LabWithDistance[]>(() => {
    let labs = [...labsWithDistance];

    if (filters.homeCollectionOnly) labs = labs.filter((l) => l.homeCollection);
    if (filters.minRating > 0) labs = labs.filter((l) => (l.rating ?? 0) >= filters.minRating);
    if (filters.maxPrice > 0) labs = labs.filter((l) => l.priceEgp <= filters.maxPrice);

    labs.sort((a, b) => {
      if (filters.sort === "nearest") {
        const da = a.distanceKm ?? Number.MAX_SAFE_INTEGER;
        const db = b.distanceKm ?? Number.MAX_SAFE_INTEGER;
        if (da !== db) return da - db;
        if (filters.nearestSecondary === "rating") return (b.rating ?? -1) - (a.rating ?? -1);
        return a.priceEgp - b.priceEgp;
      }
      if (filters.sort === "rating") {
        return (b.rating ?? -1) - (a.rating ?? -1);
      }
      return a.priceEgp - b.priceEgp;
    });

    return labs;
  }, [labsWithDistance, filters]);

  const activeFilterCount = useMemo(() => {
    let count = 0;
    if (filters.homeCollectionOnly) count++;
    if (filters.minRating > 0) count++;
    if (filters.maxPrice > 0 && filters.maxPrice < maxPossiblePrice) count++;
    return count;
  }, [filters, maxPossiblePrice]);

  function resetFilters() {
    setFilters((f) => ({ ...DEFAULT_FILTERS, sort: f.sort, maxPrice: maxPossiblePrice }));
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="bg-white shadow-sm">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div className="skeleton h-3.5 w-40 mb-3 rounded" />
            <div className="skeleton h-4 w-24 mb-4 rounded" />
          </div>
        </div>
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-5">
          <div className="bg-white rounded-2xl shadow-sm p-6 animate-slide-up">
            <div className="flex items-start gap-4 mb-4">
              <div className="skeleton h-12 w-12 rounded-xl shrink-0" />
              <div className="flex-1 space-y-2">
                <div className="skeleton h-7 w-64 rounded" />
                <div className="skeleton h-5 w-32 rounded" />
              </div>
            </div>
            <div className="skeleton h-4 w-full mb-2 rounded" />
            <div className="skeleton h-4 w-3/4 rounded" />
          </div>
          {[0, 1, 2].map((i) => (
            <div
              key={i}
              className={`bg-white rounded-2xl shadow-sm p-5 animate-slide-up ${i === 1 ? "animation-delay-100" : i === 2 ? "animation-delay-200" : ""}`}
            >
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1 space-y-2">
                  <div className="skeleton h-5 w-48 rounded" />
                  <div className="skeleton h-4 w-32 rounded" />
                </div>
                <div className="skeleton h-8 w-24 rounded" />
              </div>
              <div className="skeleton h-4 w-56 mb-4 rounded" />
              <div className="skeleton h-10 w-36 rounded-lg" />
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (notFound || !data) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white rounded-2xl shadow-sm p-12 text-center max-w-md">
          <AlertCircle className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h2 className="text-xl font-medium text-gray-900 mb-2">Test not found</h2>
          <p className="text-gray-600 mb-6">We couldn&apos;t find a test named &ldquo;{testName}&rdquo;.</p>
          <button
            onClick={() => router.back()}
            className="px-5 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-semibold"
          >
            Go Back
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white/95 backdrop-blur-sm shadow-sm sticky top-0 z-10 border-b border-gray-100">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
          <Breadcrumb items={[{ label: "Search Results", href: "/labs" }, { label: data.name }]} className="mb-2" />
          <button
            onClick={() => router.back()}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 hover:-translate-x-0.5 transition-all duration-150 font-medium"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Results
          </button>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-5">
        {/* Test Info Card */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 animate-slide-up">
          <div className="flex items-start gap-4 mb-4">
            <div className="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center shrink-0">
              <FlaskConical className="w-6 h-6 text-blue-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">{data.name}</h1>
              <span className="inline-block mt-1 px-2.5 py-0.5 bg-blue-50 text-blue-700 rounded-full text-sm font-semibold">
                {data.category}
              </span>
            </div>
          </div>

          {data.description && <p className="text-gray-600 mb-4">{data.description}</p>}

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-4 border-t border-gray-100">
            {data.turnaroundTime && (
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <Clock className="w-4 h-4 text-gray-400 shrink-0" />
                <span>
                  Results in <span className="font-medium text-gray-900">{data.turnaroundTime}</span>
                </span>
              </div>
            )}
            {data.parametersCount != null && (
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <BookOpen className="w-4 h-4 text-gray-400 shrink-0" />
                <span>
                  <span className="font-medium text-gray-900">{data.parametersCount}</span> parameters measured
                </span>
              </div>
            )}
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <FlaskConical className="w-4 h-4 text-gray-400 shrink-0" />
              <span>
                Available at <span className="font-medium text-gray-900">{data.labs.length}</span>{" "}
                {data.labs.length === 1 ? "lab" : "labs"}
              </span>
            </div>
          </div>

          {preparations.length > 0 && (
            <div className="mt-4 pt-4 border-t border-gray-100">
              <h3 className="text-sm font-medium text-gray-900 mb-2">Preparation</h3>
              <ul className="space-y-1.5">
                {preparations.map((prep, i) => (
                  <li key={i} className="flex items-start gap-2 text-sm text-gray-600">
                    <div className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 shrink-0" />
                    <span className="font-medium">{prep}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>

        {/* Sort + Filter bar */}
        <div className="space-y-2">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-1 bg-white rounded-lg border border-gray-200 p-1">
              {(["nearest", "price", "rating"] as SortKey[]).map((key) => (
                <button
                  key={key}
                  onClick={() => setFilters((f) => ({ ...f, sort: key }))}
                  disabled={key === "nearest" && !hasDistance}
                  className={`px-3 py-1.5 rounded-md text-sm transition-colors
                    ${filters.sort === key
                      ? "bg-blue-600 text-white font-semibold"
                      : "text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed font-medium"
                    }`}
                >
                  {key === "nearest" ? "Nearest" : key === "price" ? "Price" : "Rating"}
                </button>
              ))}
            </div>

            <button
              onClick={() => setFiltersOpen((o) => !o)}
              className="flex items-center gap-2 px-3 py-2 bg-white border border-gray-200 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
            >
              <SlidersHorizontal className="w-4 h-4" />
              Filters
              {activeFilterCount > 0 && (
                <span className="w-5 h-5 bg-blue-600 text-white rounded-full text-xs flex items-center justify-center">
                  {activeFilterCount}
                </span>
              )}
            </button>
          </div>

          {/* Secondary sort — only shown when Nearest is active */}
          {filters.sort === "nearest" && hasDistance && (
            <div className="flex items-center gap-2 text-sm text-gray-500">
              <span className="text-xs">then by</span>
              {(["price", "rating"] as NearestSecondary[]).map((key) => (
                <button
                  key={key}
                  onClick={() => setFilters((f) => ({ ...f, nearestSecondary: key }))}
                  className={`px-2.5 py-1 rounded-md text-xs font-medium border transition-colors ${
                    filters.nearestSecondary === key
                      ? "bg-blue-50 text-blue-700 border-blue-200"
                      : "bg-white text-gray-500 border-gray-200 hover:border-gray-300"
                  }`}
                >
                  {key === "price" ? "Price" : "Reviews"}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Filter panel */}
        {filtersOpen && (
          <div className="bg-white rounded-2xl shadow-sm p-5 border border-gray-100 animate-slide-up space-y-5">
            <div className="flex items-center justify-between">
              <h3 className="font-bold text-gray-900">Filters</h3>
              <div className="flex items-center gap-3">
                {activeFilterCount > 0 && (
                  <button onClick={resetFilters} className="text-sm text-blue-600 hover:underline font-semibold">
                    Reset
                  </button>
                )}
                <button onClick={() => setFiltersOpen(false)}>
                  <X className="w-4 h-4 text-gray-400 hover:text-gray-600" />
                </button>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-sm font-medium text-gray-700">Max Price</label>
                <span className="text-sm text-blue-600 font-medium">EGP {filters.maxPrice.toLocaleString()}</span>
              </div>
              <input
                type="range"
                min={0}
                max={maxPossiblePrice}
                step={50}
                value={filters.maxPrice}
                onChange={(e) => setFilters((f) => ({ ...f, maxPrice: Number(e.target.value) }))}
                className="w-full accent-blue-600"
              />
              <div className="flex justify-between text-xs text-gray-400 mt-1">
                <span>EGP 0</span>
                <span>EGP {maxPossiblePrice.toLocaleString()}</span>
              </div>
            </div>

            <div>
              <label className="text-sm font-medium text-gray-700 block mb-2">Minimum Rating</label>
              <div className="flex gap-2">
                {[0, 3, 3.5, 4, 4.5].map((val) => (
                  <button
                    key={val}
                    onClick={() => setFilters((f) => ({ ...f, minRating: val }))}
                    className={`px-3 py-1.5 rounded-lg text-sm border transition-colors ${
                      filters.minRating === val
                        ? "bg-blue-600 text-white border-blue-600 font-semibold"
                        : "bg-white text-gray-600 border-gray-200 hover:border-gray-300 font-medium"
                    }`}
                  >
                    {val === 0 ? "Any" : `${val}+`}
                  </button>
                ))}
              </div>
            </div>

            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={filters.homeCollectionOnly}
                onChange={(e) => setFilters((f) => ({ ...f, homeCollectionOnly: e.target.checked }))}
                className="w-4 h-4 accent-blue-600"
              />
              <span className="text-sm font-medium text-gray-700">Home collection available</span>
            </label>
          </div>
        )}

        {/* Labs list */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-base font-bold text-gray-900">Labs offering {data.name}</h2>
            <span className="text-sm text-gray-500">
              {displayedLabs.length} result{displayedLabs.length !== 1 ? "s" : ""}
            </span>
          </div>

          {displayedLabs.length === 0 ? (
            <div className="bg-white rounded-2xl shadow-sm p-8 text-center">
              <AlertCircle className="w-8 h-8 text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500 text-sm font-medium">No labs match the current filters.</p>
              <button onClick={resetFilters} className="mt-3 text-sm text-blue-600 hover:underline font-semibold">
                Clear filters
              </button>
            </div>
          ) : (
            <div className="space-y-3">
              {displayedLabs.map((lab) => (
                <div
                  key={lab.labTestId}
                  className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 hover:shadow-md transition-all duration-200"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1">
                      <div className="font-semibold text-gray-900 mb-1">{lab.labName}</div>
                      <div className="flex flex-wrap items-center gap-3 text-sm text-gray-500">
                        {lab.distanceKm != null && <DistanceBadge km={lab.distanceKm} />}
                        {lab.rating != null && (
                          <div className="flex items-center gap-1">
                            <Star className="w-3.5 h-3.5 fill-yellow-400 text-yellow-400" />
                            <span>{lab.rating.toFixed(1)}</span>
                            <span>({lab.reviews} reviews)</span>
                          </div>
                        )}
                        {lab.accreditation && (
                          <span className="px-2 py-0.5 bg-gray-100 text-gray-600 rounded text-xs">
                            {lab.accreditation}
                          </span>
                        )}
                        {lab.turnaroundTime && (
                          <div className="flex items-center gap-1">
                            <Clock className="w-3.5 h-3.5" />
                            {lab.turnaroundTime}
                          </div>
                        )}
                      </div>
                    </div>
                    <div className="text-right ml-4 shrink-0">
                      <div className="text-2xl font-bold text-blue-600">EGP {lab.priceEgp}</div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 text-sm text-gray-500 mb-3">
                    <MapPin className="w-4 h-4 shrink-0" />
                    <span>{lab.address}</span>
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3 text-sm">
                      {lab.homeCollection && (
                        <span className="flex items-center gap-1 text-green-600">
                          <Home className="w-4 h-4" />
                          Home Collection
                        </span>
                      )}
                      {lab.homeTestKit && (
                        <span className="flex items-center gap-1 text-green-600">
                          <Home className="w-4 h-4" />
                          Home Test Kit
                        </span>
                      )}
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => router.push(`/labs/${lab.labId}`)}
                        className="px-4 py-2 border border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors text-sm font-medium"
                      >
                        View Lab
                      </button>
                      <button
                        onClick={() => router.push(`/booking?labId=${lab.labId}&testId=${lab.labTestId}`)}
                        className="px-5 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors text-sm font-semibold"
                      >
                        Book Now
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
