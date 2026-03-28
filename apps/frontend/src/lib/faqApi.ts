import { apiFetch } from "./api";

export type FaqIntent = {
  id: string;
  label: string;
  query: string;
};

export type FaqItem = {
  id: string;
  question: string;
  answer: string;
  category: string | null;
  tags: string[];
};

export async function fetchFaqIntents() {
  return await apiFetch<{ items: FaqIntent[] }>("/faq/intents");
}

export async function searchFaq(params: { q?: string; page?: number; pageSize?: number }) {
  const search = new URLSearchParams();
  if (params.q) search.set("q", params.q);
  if (params.page) search.set("page", String(params.page));
  if (params.pageSize) search.set("pageSize", String(params.pageSize));
  const query = search.toString();
  return await apiFetch<{ items: FaqItem[]; pagination: { page: number; pageSize: number; totalCount: number } }>(
    `/faq/search${query ? `?${query}` : ""}`,
  );
}

export async function askFaq(question: string) {
  return await apiFetch<{
    answer: string;
    matched?: FaqItem[];
    escalation?: string;
  }>("/faq/ask", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ question }),
  });
}
