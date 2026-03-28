import { apiFetch } from "./api";

export type PublicLabCard = {
  id: string;
  name: string;
  address: string;
  accreditation: string | null;
  turnaroundTime: string | null;
  homeCollection: boolean;
  rating: number | null;
  reviews: number;
  distanceKm: number;
  testsAvailable: number;
  startingFromEgp: number | null;
  priceForQueryEgp: number | null;
  imageEmoji: string;
};

export type PublicLabListResponse = {
  items: PublicLabCard[];
  pagination: { page: number; pageSize: number; totalCount: number };
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
    accreditation: string | null;
    turnaroundTime: string | null;
  };
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
  sort?: "price" | "rating" | "distance";
  minRating?: number;
  maxDistanceKm?: number;
  maxPriceEgp?: number;
  homeCollection?: boolean;
  accreditations?: string[];
  page?: number;
  pageSize?: number;
}) {
  return await apiFetch<PublicLabListResponse>(
    `/public/labs${toQueryString({
      q: params.q,
      labName: params.labName,
      sort: params.sort,
      minRating: params.minRating,
      maxDistanceKm: params.maxDistanceKm,
      maxPriceEgp: params.maxPriceEgp,
      homeCollection: params.homeCollection,
      accreditations: params.accreditations?.join(","),
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

