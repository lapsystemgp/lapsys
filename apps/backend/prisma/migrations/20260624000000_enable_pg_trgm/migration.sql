-- Enable the pg_trgm extension for fuzzy string matching (word_similarity).
-- This is a one-time, non-destructive operation. Safe to run on existing data.
CREATE EXTENSION IF NOT EXISTS pg_trgm;
