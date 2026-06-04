"use client";

import { useEffect, useState } from "react";
import { useRouter, useParams, useSearchParams } from "next/navigation";
import { ArrowLeft, MapPin, Star, Clock, Home, FlaskConical, BookOpen, AlertCircle } from "lucide-react";
import { fetchTestOffers, type TestOffersResponse } from "../../../lib/publicApi";
import { Breadcrumb } from "../../../components/Breadcrumb";

export default function TestDetailClient() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();

  const testName = decodeURIComponent(params.testName as string);
  const category = searchParams.get("category") ?? undefined;

  const [data, setData] = useState<TestOffersResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);

  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

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

  const preparations = data?.preparation
    ? data.preparation.split(/[,;\n]+/).map((s) => s.trim()).filter(Boolean)
    : [];

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
          <div className="bg-white rounded-xl shadow-sm p-6 animate-slide-up">
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
            <div key={i} className={`bg-white rounded-xl shadow-sm p-5 animate-slide-up ${i === 1 ? 'animation-delay-100' : i === 2 ? 'animation-delay-200' : ''}`}>
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
        <div className="bg-white rounded-xl shadow-sm p-12 text-center max-w-md">
          <AlertCircle className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h2 className="text-xl font-medium text-gray-900 mb-2">Test not found</h2>
          <p className="text-gray-600 mb-6">We couldn't find a test named "{testName}".</p>
          <button
            onClick={() => router.back()}
            className="px-5 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
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
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
          <Breadcrumb items={[{ label: "Search Results", href: "/labs" }, { label: data.name }]} className="mb-2" />
          <button
            onClick={() => router.back()}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 hover:-translate-x-0.5 transition-all duration-150"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Results
          </button>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-5">
        {/* Test Info Card */}
        <div className="bg-white rounded-xl shadow-sm p-6 animate-slide-up">
          <div className="flex items-start gap-4 mb-4">
            <div className="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center shrink-0">
              <FlaskConical className="w-6 h-6 text-blue-600" />
            </div>
            <div>
              <h1 className="text-2xl font-semibold text-gray-900">{data.name}</h1>
              <span className="inline-block mt-1 px-2.5 py-0.5 bg-blue-50 text-blue-700 rounded-full text-sm">
                {data.category}
              </span>
            </div>
          </div>

          {data.description && (
            <p className="text-gray-600 mb-4">{data.description}</p>
          )}

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-4 border-t border-gray-100">
            {data.turnaroundTime && (
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <Clock className="w-4 h-4 text-gray-400 shrink-0" />
                <span>Results in <span className="font-medium text-gray-900">{data.turnaroundTime}</span></span>
              </div>
            )}
            {data.parametersCount != null && (
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <BookOpen className="w-4 h-4 text-gray-400 shrink-0" />
                <span><span className="font-medium text-gray-900">{data.parametersCount}</span> parameters measured</span>
              </div>
            )}
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <FlaskConical className="w-4 h-4 text-gray-400 shrink-0" />
              <span>Available at <span className="font-medium text-gray-900">{data.labs.length}</span> {data.labs.length === 1 ? 'lab' : 'labs'}</span>
            </div>
          </div>

          {preparations.length > 0 && (
            <div className="mt-4 pt-4 border-t border-gray-100">
              <h3 className="text-sm font-medium text-gray-900 mb-2">Preparation</h3>
              <ul className="space-y-1.5">
                {preparations.map((prep, i) => (
                  <li key={i} className="flex items-start gap-2 text-sm text-gray-600">
                    <div className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 shrink-0" />
                    {prep}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>

        {/* Labs offering this test */}
        <div>
          <h2 className="text-base font-medium text-gray-900 mb-3">
            Labs offering {data.name}
          </h2>
          <div className="space-y-3">
            {data.labs.map((lab) => (
              <div
                key={lab.labTestId}
                className="bg-white rounded-xl shadow-sm p-5 hover:shadow-md transition-all duration-200"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="font-medium text-gray-900 mb-1">{lab.labName}</div>
                    <div className="flex flex-wrap items-center gap-3 text-sm text-gray-500">
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
                    <div className="text-2xl font-semibold text-blue-600">EGP {lab.priceEgp}</div>
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
                      className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors text-sm"
                    >
                      View Lab
                    </button>
                    <button
                      onClick={() =>
                        router.push(`/booking?labId=${lab.labId}&testId=${lab.labTestId}`)
                      }
                      className="px-5 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm"
                    >
                      Book Now
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
