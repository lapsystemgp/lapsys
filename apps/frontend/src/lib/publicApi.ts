import { apiFetch } from "./api";

export type PublicLabCard = {
  id: string;
  name: string;
  address: string;
  city: string | null;
  phone: string | null;
  contactEmail: string | null;
  accreditation: string | null;
  turnaroundTime: string | null;
  homeCollection: boolean;
  homeTestKit: boolean;
  rating: number | null;
  reviews: number;
  distanceKm: number | null;
  testsAvailable: number;
  startingFromEgp: number | null;
  priceForQueryEgp: number | null;
  imageEmoji: string | null;
};

export type PublicLabListResponse = {
  items: PublicLabCard[];
  pagination: { page: number; pageSize: number; totalCount: number };
};

export type PublicReview = {
  id: string;
  rating: number;
  comment: string | null;
  createdAt: string;
  patientName: string;
};

export type PublicLabDetailResponse = {
  lab: PublicLabCard;
  tests: Array<{
    id: string;
    name: string;
    category: string;
    priceEgp: number;
    description: string | null;
    preparation: string | null;
    turnaroundTime: string | null;
    parametersCount: number | null;
  }>;
  pagination: { page: number; pageSize: number; totalCount: number };
  reviewItems: PublicReview[];
};

export type PublicTestResponse = {
  id: string;
  name: string;
  category: string;
  priceEgp: number;
  description: string | null;
  preparation: string | null;
  turnaroundTime: string | null;
  parametersCount: number | null;
  lab: {
    id: string;
    name: string;
    address: string;
    homeCollection: boolean;
    homeTestKit: boolean;
    accreditation: string | null;
    turnaroundTime: string | null;
  };
};

export type PublicTestCard = {
  name: string;
  category: string;
  minPriceEgp: number | null;
  labCount: number;
};

export type PublicTestListResponse = {
  items: PublicTestCard[];
  pagination: { page: number; pageSize: number; totalCount: number };
};

export type TestOfferLab = {
  labTestId: string;
  labId: string;
  labName: string;
  address: string;
  priceEgp: number;
  rating: number | null;
  reviews: number;
  homeCollection: boolean;
  homeTestKit: boolean;
  accreditation: string | null;
  turnaroundTime: string | null;
  latitude: number | null;
  longitude: number | null;
};

export type TestOffersResponse = {
  name: string;
  category: string;
  description: string | null;
  preparation: string | null;
  turnaroundTime: string | null;
  parametersCount: number | null;
  labs: TestOfferLab[];
};

function toQueryString(params: Record<string, string | number | boolean | undefined | null>) {
  const searchParams = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === null) continue;
    searchParams.set(key, String(value));
  }
  const qs = searchParams.toString();
  return qs.length > 0 ? `?${qs}` : "";
}

export async function fetchPublicLabs(params: {
  q?: string;
  labName?: string;
  city?: string;
  sort?: "price" | "rating" | "distance";
  minRating?: number;
  maxDistanceKm?: number;
  maxPriceEgp?: number;
  homeCollection?: boolean;
  accreditations?: string[];
  userLat?: number;
  userLng?: number;
  page?: number;
  pageSize?: number;
}) {
  return await apiFetch<PublicLabListResponse>(
    `/public/labs${toQueryString({
      q: params.q,
      labName: params.labName,
      city: params.city,
      sort: params.sort,
      minRating: params.minRating,
      maxDistanceKm: params.maxDistanceKm,
      maxPriceEgp: params.maxPriceEgp,
      homeCollection: params.homeCollection,
      accreditations: params.accreditations?.join(","),
      userLat: params.userLat,
      userLng: params.userLng,
      page: params.page,
      pageSize: params.pageSize,
    })}`,
  );
}

export async function fetchPublicLabDetail(labId: string, params?: { q?: string; category?: string; page?: number; pageSize?: number }) {
  return await apiFetch<PublicLabDetailResponse>(
    `/public/labs/${encodeURIComponent(labId)}${toQueryString({
      q: params?.q,
      category: params?.category,
      page: params?.page,
      pageSize: params?.pageSize,
    })}`,
  );
}

export async function fetchPublicTest(labTestId: string) {
  return await apiFetch<PublicTestResponse>(`/public/tests/${encodeURIComponent(labTestId)}`);
}

export async function fetchPublicTests(params: { q?: string; page?: number; pageSize?: number }) {
  return await apiFetch<PublicTestListResponse>(
    `/public/tests${toQueryString({ q: params.q, page: params.page, pageSize: params.pageSize })}`,
  );
}

export async function fetchTestOffers(params: { name: string; category?: string }) {
  return await apiFetch<TestOffersResponse>(
    `/public/tests/by-name${toQueryString({ name: params.name, category: params.category })}`,
  );
}

export type SuggestionItem = {
  label: string;
  query: string;
  type: 'test' | 'category' | 'abbreviation';
};

export type SuggestResponse = {
  suggestions: SuggestionItem[];
};

export async function fetchSuggestions(q: string, limit = 8): Promise<SuggestResponse> {
  if (q.trim().length < 2) return { suggestions: [] };
  return apiFetch<SuggestResponse>(`/public/search/suggest${toQueryString({ q: q.trim(), limit })}`);
}

