CREATE TABLE "SearchZeroResultLog" (
  "id"         TEXT        NOT NULL DEFAULT gen_random_uuid()::text,
  "query"      TEXT        NOT NULL,
  "source"     TEXT        NOT NULL,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "SearchZeroResultLog_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "SearchZeroResultLog_created_at_idx" ON "SearchZeroResultLog"("created_at");
CREATE INDEX "SearchZeroResultLog_query_idx"      ON "SearchZeroResultLog"("query");
