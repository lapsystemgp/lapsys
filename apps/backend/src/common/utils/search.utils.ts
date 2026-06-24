import { Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { expandTokens } from './synonyms';

export { expandTokens } from './synonyms';

const STOPWORDS = new Set(['test', 'tests']);
const SIMILARITY_THRESHOLD = 0.3;

/** Normalize and split a search query into tokens, dropping noise words. */
export function tokenize(q: string): string[] {
  const raw = q.trim().replace(/\s+/g, ' ').split(' ').filter(Boolean);
  const filtered = raw.filter((t) => !STOPWORDS.has(t.toLowerCase()));
  return filtered.length > 0 ? filtered : raw;
}

/** Levenshtein edit distance for short-word in-memory fuzzy matching. */
function editDistance(a: string, b: string): number {
  const m = a.length;
  const n = b.length;
  const prev = Array.from({ length: n + 1 }, (_, j) => j);
  const curr = new Array<number>(n + 1);
  for (let i = 1; i <= m; i++) {
    curr[0] = i;
    for (let j = 1; j <= n; j++) {
      curr[j] =
        a[i - 1] === b[j - 1]
          ? prev[j - 1]
          : 1 + Math.min(prev[j], curr[j - 1], prev[j - 1]);
    }
    prev.splice(0, n + 1, ...curr);
  }
  return prev[n];
}

/**
 * Returns true if `token` fuzzy-matches anywhere in `text`.
 * Tries exact substring first, then Levenshtein against each word in the text.
 * Allowed edit distance: 1 for tokens ≥4 chars, 2 for tokens ≥6 chars.
 */
export function fuzzyContains(text: string, token: string): boolean {
  const t = token.toLowerCase();
  const s = text.toLowerCase();
  if (s.includes(t)) return true;
  const maxDist = t.length >= 6 ? 2 : t.length >= 4 ? 1 : 0;
  if (maxDist === 0) return false;
  return s.split(/\s+/).some((w) => editDistance(t, w) <= maxDist);
}

/**
 * Build an AND clause where every token group must match.
 * Each group is OR-ed: any synonym (or fuzzy variant) satisfies the position.
 * Shape: AND( OR(synonyms_for_token_1) , OR(synonyms_for_token_2) , … )
 */
function buildExpandedAndClause(expandedTokens: string[][], threshold: number): Prisma.Sql {
  const perToken = expandedTokens.map((alternatives) => {
    const conditions: Prisma.Sql[] = alternatives.flatMap((t) => [
      Prisma.sql`lt.name ILIKE ${'%' + t + '%'}`,
      Prisma.sql`COALESCE(lt.category, '') ILIKE ${'%' + t + '%'}`,
      Prisma.sql`COALESCE(lt.description, '') ILIKE ${'%' + t + '%'}`,
      Prisma.sql`word_similarity(${t}, lt.name) > ${threshold}`,
      Prisma.sql`word_similarity(${t}, COALESCE(lt.category, '')) > ${threshold}`,
    ]);
    return Prisma.sql`(${conditions.reduce((a, b) => Prisma.sql`${a} OR ${b}`)})`;
  });
  return perToken.reduce((a, b) => Prisma.sql`${a} AND ${b}`);
}

/** Same shape as buildExpandedAndClause but for FAQ fields (question / answer). */
function buildFaqExpandedClause(alternatives: string[], threshold: number): Prisma.Sql {
  const conditions: Prisma.Sql[] = alternatives.flatMap((t) => [
    Prisma.sql`fe.question ILIKE ${'%' + t + '%'}`,
    Prisma.sql`fe.answer ILIKE ${'%' + t + '%'}`,
    Prisma.sql`word_similarity(${t}, fe.question) > ${threshold}`,
    Prisma.sql`word_similarity(${t}, fe.answer) > ${threshold}`,
  ]);
  return conditions.reduce((a, b) => Prisma.sql`${a} OR ${b}`);
}

/**
 * Fuzzy-search LabTests within a fixed set of labs.
 * Returns a map of labProfileId → min matching price (used by the labs listing).
 */
export async function fuzzyMatchTestsByLab(
  prisma: PrismaService,
  tokens: string[],
  labIds: string[],
  threshold = SIMILARITY_THRESHOLD,
): Promise<Map<string, number>> {
  if (tokens.length === 0 || labIds.length === 0) return new Map();
  const andClause = buildExpandedAndClause(expandTokens(tokens), threshold);
  const rows = await prisma.$queryRaw<Array<{ lab_profile_id: string; min_price: number | null }>>`
    SELECT lt.lab_profile_id, MIN(lt.price_egp) AS min_price
    FROM "LabTest" lt
    WHERE lt.is_active = true
      AND lt.lab_profile_id = ANY(${labIds})
      AND ${andClause}
    GROUP BY lt.lab_profile_id
  `;
  return new Map(rows.map((r) => [r.lab_profile_id, r.min_price ?? 0]));
}

/**
 * Fuzzy-search LabTests across all active labs, grouped by (name, category).
 * Used by the public tests listing endpoint.
 * Results are sorted by relevance: prefix match → contains match → fuzzy score.
 */
export async function fuzzySearchTests(
  prisma: PrismaService,
  tokens: string[],
  rawQ = '',
  threshold = SIMILARITY_THRESHOLD,
): Promise<Array<{ name: string; category: string; minPriceEgp: number | null; labCount: number }>> {
  if (tokens.length === 0) return [];
  const andClause = buildExpandedAndClause(expandTokens(tokens), threshold);
  const q = rawQ.trim();

  // Relevance: prefix match (1.0) > contains match (0.9) > pg_trgm score
  const relevanceExpr = q.length > 0
    ? Prisma.sql`CASE
        WHEN lt.name ILIKE ${q + '%'}     THEN 1.0
        WHEN lt.name ILIKE ${'%' + q + '%'} THEN 0.9
        ELSE GREATEST(
          word_similarity(${q}, lt.name),
          word_similarity(${q}, COALESCE(lt.category, ''))
        )
      END`
    : Prisma.sql`0.0::float`;

  const rows = await prisma.$queryRaw<
    Array<{ name: string; category: string; min_price_egp: number | null; lab_count: number }>
  >`
    SELECT name, category, min_price_egp, lab_count
    FROM (
      SELECT lt.name, lt.category,
        MIN(lt.price_egp)  AS min_price_egp,
        COUNT(*)::int      AS lab_count,
        MAX(${relevanceExpr}) AS relevance
      FROM "LabTest" lt
      INNER JOIN "LabProfile" lp ON lp.id = lt.lab_profile_id
      WHERE lt.is_active = true
        AND lp.onboarding_status = 'Active'
        AND ${andClause}
      GROUP BY lt.name, lt.category
    ) ranked
    ORDER BY relevance DESC, name ASC
  `;
  return rows.map((r) => ({
    name: r.name,
    category: r.category,
    minPriceEgp: r.min_price_egp,
    labCount: r.lab_count,
  }));
}

/**
 * Fuzzy-search LabTests within a single lab (lab detail page).
 * Supports category filter, sorting, and pagination.
 * When rawQ is provided and sort is 'price' (default), results are ranked by
 * relevance first (exact prefix > contains > fuzzy), then price ascending.
 */
export async function fuzzySearchLabTests(
  prisma: PrismaService,
  labId: string,
  tokens: string[],
  category: string,
  sort: string,
  page: number,
  pageSize: number,
  rawQ = '',
  threshold = SIMILARITY_THRESHOLD,
): Promise<{
  items: Array<{
    id: string;
    name: string;
    category: string;
    price_egp: number;
    description: string | null;
    preparation: string | null;
    turnaround_time: string | null;
    parameters_count: number | null;
  }>;
  totalCount: number;
}> {
  const baseClauses: Prisma.Sql[] = [
    Prisma.sql`lt.lab_profile_id = ${labId}`,
    Prisma.sql`lt.is_active = true`,
  ];

  if (category.length > 0 && category !== 'all') {
    baseClauses.push(Prisma.sql`lt.category = ${category}`);
  }

  if (tokens.length > 0) {
    baseClauses.push(buildExpandedAndClause(expandTokens(tokens), threshold));
  }

  const whereClause = baseClauses.reduce((acc, c) => Prisma.sql`${acc} AND ${c}`);

  const trimmedQ = rawQ.trim();
  const useRelevance = tokens.length > 0 && trimmedQ.length > 0 && sort === 'price';

  const orderByClause = useRelevance
    ? Prisma.sql`
        CASE
          WHEN lt.name ILIKE ${trimmedQ + '%'}     THEN 1.0
          WHEN lt.name ILIKE ${'%' + trimmedQ + '%'} THEN 0.9
          ELSE word_similarity(${trimmedQ}, lt.name)
        END DESC, lt.price_egp ASC`
    : sort === 'name'
      ? Prisma.sql`lt.name ASC`
      : sort === 'price_desc'
        ? Prisma.sql`lt.price_egp DESC`
        : Prisma.sql`lt.price_egp ASC`;

  const offset = (page - 1) * pageSize;

  const [countRows, rows] = await Promise.all([
    prisma.$queryRaw<Array<{ count: number }>>`
      SELECT COUNT(*)::int AS count FROM "LabTest" lt WHERE ${whereClause}
    `,
    prisma.$queryRaw<
      Array<{
        id: string;
        name: string;
        category: string;
        price_egp: number;
        description: string | null;
        preparation: string | null;
        turnaround_time: string | null;
        parameters_count: number | null;
      }>
    >`
      SELECT lt.id, lt.name, lt.category, lt.price_egp,
             lt.description, lt.preparation, lt.turnaround_time, lt.parameters_count
      FROM "LabTest" lt
      WHERE ${whereClause}
      ORDER BY ${orderByClause}
      LIMIT ${pageSize} OFFSET ${offset}
    `,
  ]);

  return { items: rows, totalCount: countRows[0]?.count ?? 0 };
}

/**
 * Fuzzy-search tests for the AI chat assistant.
 * Returns raw {lab_id, test_id, price_egp, turnaround_time} rows for further enrichment.
 */
export async function fuzzyFindLabTestsForChat(
  prisma: PrismaService,
  tokens: string[],
  city?: string,
  threshold = SIMILARITY_THRESHOLD,
): Promise<Array<{ lab_id: string; test_id: string; price_egp: number; turnaround_time: string | null }>> {
  if (tokens.length === 0) return [];
  const andClause = buildExpandedAndClause(expandTokens(tokens), threshold);
  const cityClause = city ? Prisma.sql`AND lp.city ILIKE ${'%' + city + '%'}` : Prisma.empty;
  return prisma.$queryRaw<
    Array<{ lab_id: string; test_id: string; price_egp: number; turnaround_time: string | null }>
  >`
    SELECT lt.lab_profile_id AS lab_id, lt.id AS test_id, lt.price_egp, lt.turnaround_time
    FROM "LabTest" lt
    INNER JOIN "LabProfile" lp ON lp.id = lt.lab_profile_id
    WHERE lt.is_active = true
      AND lp.onboarding_status = 'Active'
      ${cityClause}
      AND ${andClause}
    ORDER BY lt.price_egp ASC
  `;
}

/**
 * Fuzzy-search FAQ entries by question and answer text.
 * Expands abbreviations via synonym map so "CBC" finds FAQ about "complete blood count".
 */
export async function fuzzySearchFaq(
  prisma: PrismaService,
  q: string,
  category: string,
  page: number,
  pageSize: number,
  threshold = 0.25,
): Promise<{
  items: Array<{ id: string; question: string; answer: string; category: string | null; tags: string[] }>;
  totalCount: number;
}> {
  const normalized = q.trim().replace(/\s+/g, ' ');
  const categoryClause =
    category.length > 0 ? Prisma.sql`AND fe.category ILIKE ${category}` : Prisma.empty;

  // Expand the full query + each individual token through the synonym map
  const synonymAlternatives: string[] = [normalized];
  if (normalized.length > 0) {
    const tokens = normalized.split(/\s+/).filter(Boolean);
    for (const token of tokens) {
      const expanded = expandTokens([token])[0];
      for (const alt of expanded) {
        if (alt.toLowerCase() !== token.toLowerCase()) synonymAlternatives.push(alt);
      }
    }
  }

  const qClause =
    normalized.length > 0
      ? Prisma.sql`AND (${buildFaqExpandedClause(synonymAlternatives, threshold)})`
      : Prisma.empty;

  // Rank by best similarity score across all synonym alternatives
  const rankingScores = synonymAlternatives.map(
    (t) => Prisma.sql`word_similarity(${t}, fe.question)`,
  );
  const bestScore = rankingScores.reduce(
    (a, b) => Prisma.sql`GREATEST(${a}, ${b})`,
  );

  const orderClause =
    normalized.length > 0
      ? Prisma.sql`${bestScore} DESC, fe.updated_at DESC`
      : Prisma.sql`fe.updated_at DESC`;

  const offset = (page - 1) * pageSize;

  const [countRows, rows] = await Promise.all([
    prisma.$queryRaw<Array<{ count: number }>>`
      SELECT COUNT(*)::int AS count
      FROM "FaqEntry" fe
      WHERE fe.is_active = true ${categoryClause} ${qClause}
    `,
    prisma.$queryRaw<
      Array<{ id: string; question: string; answer: string; category: string | null; tags: string[] }>
    >`
      SELECT fe.id, fe.question, fe.answer, fe.category, fe.tags
      FROM "FaqEntry" fe
      WHERE fe.is_active = true ${categoryClause} ${qClause}
      ORDER BY ${orderClause}
      LIMIT ${pageSize} OFFSET ${offset}
    `,
  ]);

  return { items: rows, totalCount: countRows[0]?.count ?? 0 };
}
