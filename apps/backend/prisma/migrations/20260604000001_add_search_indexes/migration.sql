-- Enable trigram extension for insensitive-contains queries on text columns
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- LabProfile: btree indexes for city equality filter and rating range queries
CREATE INDEX "LabProfile_city_idx" ON "LabProfile"("city");
CREATE INDEX "LabProfile_rating_average_idx" ON "LabProfile"("rating_average");

-- LabTest: GIN trigram indexes for case-insensitive name/category search
-- (plain btree does not benefit ilike/contains; pg_trgm GIN does)
CREATE INDEX "LabTest_name_trgm_idx" ON "LabTest" USING gin ("name" gin_trgm_ops);
CREATE INDEX "LabTest_category_trgm_idx" ON "LabTest" USING gin ("category" gin_trgm_ops);
