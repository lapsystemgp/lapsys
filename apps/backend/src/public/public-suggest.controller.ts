import { Controller, Get, Query } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { expandTokens } from '../common/utils/synonyms';

type SuggestionType = 'test' | 'category' | 'abbreviation';

type Suggestion = {
  label: string;
  query: string;
  type: SuggestionType;
};

function capitalize(s: string): string {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

@Controller('public/search')
export class PublicSuggestController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('suggest')
  async suggest(
    @Query() query: Record<string, string | undefined>,
  ): Promise<{ suggestions: Suggestion[] }> {
    const q = (query.q ?? '').trim().replace(/\s+/g, ' ');
    const limit = Math.min(parseInt(query.limit ?? '8', 10) || 8, 20);

    if (q.length < 2) return { suggestions: [] };

    const suggestions: Suggestion[] = [];
    const seen = new Set<string>();

    // ── 1. Synonym abbreviation hint ───────────────────────────────────
    // If the typed text exactly matches a known abbreviation/synonym, show
    // the expanded equivalent as the first suggestion.
    const synonymGroup = expandTokens([q])[0];
    if (synonymGroup.length > 1) {
      const qLower = q.toLowerCase();
      // Pick the longest purely-ASCII English alternative (the full name)
      const englishAlts = synonymGroup.filter(
        (s) => s.toLowerCase() !== qLower && /^[\x00-\x7F]+$/.test(s),
      );
      if (englishAlts.length > 0) {
        const fullName = englishAlts.sort((a, b) => b.length - a.length)[0];
        const abbr = q.toUpperCase();
        const label = `${abbr} — ${capitalize(fullName)}`;
        seen.add(label.toLowerCase());
        seen.add(q.toLowerCase());
        suggestions.push({ label, query: abbr, type: 'abbreviation' });
      }
    }

    // ── 2. Test name suggestions ───────────────────────────────────────
    // Search using the original query AND all synonym alternatives so that
    // typing "lft" also surfaces tests named "Liver Function Tests".
    const alternatives = synonymGroup;

    const nameClauses = alternatives.flatMap((alt) => [
      Prisma.sql`lt.name ILIKE ${alt + '%'}`,
      Prisma.sql`lt.name ILIKE ${'%' + alt + '%'}`,
      Prisma.sql`word_similarity(${alt}, lt.name) > 0.3`,
    ]);
    const nameOrClause = nameClauses.reduce(
      (a, b) => Prisma.sql`${a} OR ${b}`,
    );

    // Score each row by the best match across all alternatives
    const scoreExprs = alternatives.map(
      (alt) => Prisma.sql`
        CASE
          WHEN lt.name ILIKE ${alt + '%'}    THEN 1.0
          WHEN lt.name ILIKE ${'%' + alt + '%'} THEN 0.7
          ELSE word_similarity(${alt}, lt.name)
        END`,
    );
    const scoreExpr = scoreExprs.reduce(
      (a, b) => Prisma.sql`GREATEST(${a}, ${b})`,
    );

    const testRows = await this.prisma.$queryRaw<
      Array<{ name: string; score: number }>
    >`
      SELECT name, MAX(score) AS score
      FROM (
        SELECT lt.name, ${scoreExpr} AS score
        FROM "LabTest" lt
        INNER JOIN "LabProfile" lp ON lp.id = lt.lab_profile_id
        WHERE lt.is_active = true
          AND lp.onboarding_status = 'Active'
          AND (${nameOrClause})
      ) sub
      GROUP BY name
      ORDER BY score DESC, name ASC
      LIMIT ${limit}
    `;

    for (const row of testRows) {
      const key = row.name.toLowerCase();
      if (!seen.has(key)) {
        seen.add(key);
        suggestions.push({ label: row.name, query: row.name, type: 'test' });
      }
    }

    // ── 3. Category suggestions ────────────────────────────────────────
    const catClauses = alternatives
      .map((alt) => Prisma.sql`lt.category ILIKE ${'%' + alt + '%'}`)
      .reduce((a, b) => Prisma.sql`${a} OR ${b}`);

    const catRows = await this.prisma.$queryRaw<Array<{ category: string }>>`
      SELECT DISTINCT lt.category
      FROM "LabTest" lt
      WHERE lt.is_active = true
        AND (${catClauses})
      ORDER BY lt.category ASC
      LIMIT 3
    `;

    for (const row of catRows) {
      const key = row.category.toLowerCase();
      if (!seen.has(key)) {
        seen.add(key);
        suggestions.push({
          label: row.category,
          query: row.category,
          type: 'category',
        });
      }
    }

    return { suggestions: suggestions.slice(0, limit) };
  }
}
