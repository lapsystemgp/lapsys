# TesTly Search — Implementation Guide

## Problem

The original search used exact substring matching (`ILIKE '%query%'`). This meant:
- **Typos** failed silently — "blod" found nothing instead of "blood"
- **Word variants** missed — "testing" didn't match "test"
- The same tokenization logic was duplicated across 4 separate files

## What was implemented

### 1. Shared search utility

**File:** [`apps/backend/src/common/utils/search.utils.ts`](../apps/backend/src/common/utils/search.utils.ts)

All search logic lives here. No more duplication.

| Export | Purpose |
|---|---|
| `tokenize(q)` | Normalize + split a query into tokens, drop stopwords (`test`, `tests`) |
| `fuzzyContains(text, token)` | In-memory fuzzy check using Levenshtein edit distance |
| `fuzzyMatchTestsByLab(...)` | DB fuzzy search — returns labId → min price map |
| `fuzzySearchTests(...)` | DB fuzzy search — returns grouped (name, category) rows |
| `fuzzySearchLabTests(...)` | DB fuzzy search — returns paginated tests for one lab |
| `fuzzyFindLabTestsForChat(...)` | DB fuzzy search — for the AI chat assistant tools |
| `fuzzySearchFaq(...)` | DB fuzzy search — for FAQ question/answer search |

### 2. Database — PostgreSQL pg_trgm

**Migration:** `20260624000000_enable_pg_trgm`

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

Applied to the Neon database on 2026-06-24. This extension provides the `word_similarity()` function used for fuzzy matching.

### 3. Two-layer fuzzy matching

#### Layer 1 — In-memory (lab names, addresses)
Uses **Levenshtein edit distance** implemented in TypeScript:
- Token length ≥ 4: allows **1 edit** (1 wrong/missing/extra character)
- Token length ≥ 6: allows **2 edits**
- Shorter tokens: exact match only (avoids false positives on 2-3 letter abbreviations)

```
"blod" → edit distance 1 from "blood" → MATCH ✓
"haemo" → substring of "haemoglobin" → MATCH ✓
"LTF"  → edit distance 1 from "LFT" → MATCH ✓
```

#### Layer 2 — Database (test names, categories, descriptions, FAQ)
Uses **`word_similarity(token, field)`** from `pg_trgm`:
- Threshold: **0.3** for tests/labs, **0.25** for FAQ
- Direction matters: `word_similarity(needle, haystack)` — checks how similar the token is to the best matching word in the field
- Combined with `ILIKE '%token%'` (exact substring) via OR — so exact matches are always found even if trigram score is low

```sql
word_similarity('blod', 'blood count') > 0.3   -- ~0.57 → MATCH ✓
word_similarity('CBC', 'Complete Blood Count')  > 0.3   -- 1.0  → MATCH ✓
word_similarity('haemoglobin', 'hemoglobin')   > 0.3   -- ~0.7  → MATCH ✓
```

### 4. Tokenization

```typescript
tokenize("blood  Tests CBC") // → ["blood", "CBC"]
//  1. trim + collapse whitespace
//  2. split on spaces
//  3. drop stopwords: "test", "tests"
```

Multi-token queries use **AND logic**: every token must match at least one field. This means "blood glucose" only returns tests that mention both words.

## Endpoints updated

| Endpoint | File |
|---|---|
| `GET /public/labs` | `public-labs.controller.ts` |
| `GET /public/labs/:id` | `public-labs.controller.ts` |
| `GET /public/tests` | `public-tests.controller.ts` |
| `GET /faq/search` | `faq.service.ts` |
| AI chat `find_labs` tool | `chat.service.ts` |
| AI chat `search_tests` tool | `chat.service.ts` |

## Tuning the similarity threshold

The threshold `0.3` in `search.utils.ts` controls how fuzzy the matching is:

| Threshold | Behaviour |
|---|---|
| `0.5+` | Strict — only catches minor typos (1 char off) |
| `0.3` | Balanced — catches most typos, rare false positives *(current)* |
| `0.2` | Loose — more results, higher chance of irrelevant matches |

To change it, edit `SIMILARITY_THRESHOLD` at the top of `search.utils.ts`.

## What handles what

| User input | Handled by |
|---|---|
| `"blod test"` → finds "blood count" | Levenshtein (in-memory) + pg_trgm |
| `"BLOOD  Tests"` → multiple spaces, mixed case | `tokenize()` normalization |
| `"CBC test"` → stopword "test" dropped, "CBC" searched | `tokenize()` stopwords |
| `"testing"` → still matches "test" results | pg_trgm `word_similarity` |
| `"liver function"` → finds LFT tests | exact substring (`ILIKE`) |

## Future improvements (not yet implemented)

See the diagram for a full upgrade map. The highest-value next steps:

1. **Medical synonyms** — map `CBC` → `complete blood count`, `LFT` → `liver function`, etc. in a DB table or constant. Massively improves discoverability without infra changes.
2. **Autocomplete endpoint** — `GET /public/search/suggest?q=blo` using pg_trgm prefix queries. The extension is already enabled.
3. **pgvector semantic search** — store embeddings per test, search by meaning ("is my liver ok" → finds LFT). Neon supports `pgvector` natively. Use Gemini embeddings (already integrated).
4. **Relevance ranking** — currently results sort by price. Add a similarity score column so exact-name matches appear above fuzzy ones.
5. **Zero-result logging** — save queries that returned 0 results to a `search_miss` table for data-quality review.
