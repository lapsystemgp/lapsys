-- CreateTable
CREATE TABLE "CanonicalMarker" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "display_name" TEXT NOT NULL,
    "category" TEXT,
    "default_unit" TEXT,
    "loinc_code" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CanonicalMarker_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MarkerAlias" (
    "id" TEXT NOT NULL,
    "canonical_marker_id" TEXT NOT NULL,
    "alias_normalized" TEXT NOT NULL,

    CONSTRAINT "MarkerAlias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ResultPanel" (
    "id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "name" TEXT,
    "test_date" TIMESTAMP(3) NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "ResultPanel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ResultObservation" (
    "id" TEXT NOT NULL,
    "panel_id" TEXT NOT NULL,
    "canonical_marker_id" TEXT,
    "raw_name" TEXT NOT NULL,
    "value_numeric" DECIMAL(18,6),
    "value_text" TEXT,
    "unit" TEXT,
    "ref_low" DECIMAL(18,6),
    "ref_high" DECIMAL(18,6),
    "ref_text" TEXT,
    "value_in_canonical_unit" DECIMAL(18,6),
    "comparable_unit" TEXT,
    "is_comparable" BOOLEAN NOT NULL DEFAULT true,
    "comparability_note" TEXT,

    CONSTRAINT "ResultObservation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "CanonicalMarker_code_key" ON "CanonicalMarker"("code");

-- CreateIndex
CREATE INDEX "CanonicalMarker_category_idx" ON "CanonicalMarker"("category");

-- CreateIndex
CREATE UNIQUE INDEX "MarkerAlias_alias_normalized_key" ON "MarkerAlias"("alias_normalized");

-- CreateIndex
CREATE INDEX "MarkerAlias_canonical_marker_id_idx" ON "MarkerAlias"("canonical_marker_id");

-- CreateIndex
CREATE INDEX "ResultPanel_booking_id_idx" ON "ResultPanel"("booking_id");

-- CreateIndex
CREATE INDEX "ResultPanel_booking_id_test_date_idx" ON "ResultPanel"("booking_id", "test_date");

-- CreateIndex
CREATE INDEX "ResultObservation_panel_id_idx" ON "ResultObservation"("panel_id");

-- CreateIndex
CREATE INDEX "ResultObservation_canonical_marker_id_idx" ON "ResultObservation"("canonical_marker_id");

-- AddForeignKey
ALTER TABLE "MarkerAlias" ADD CONSTRAINT "MarkerAlias_canonical_marker_id_fkey" FOREIGN KEY ("canonical_marker_id") REFERENCES "CanonicalMarker"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultPanel" ADD CONSTRAINT "ResultPanel_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultObservation" ADD CONSTRAINT "ResultObservation_panel_id_fkey" FOREIGN KEY ("panel_id") REFERENCES "ResultPanel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultObservation" ADD CONSTRAINT "ResultObservation_canonical_marker_id_fkey" FOREIGN KEY ("canonical_marker_id") REFERENCES "CanonicalMarker"("id") ON DELETE SET NULL ON UPDATE CASCADE;
