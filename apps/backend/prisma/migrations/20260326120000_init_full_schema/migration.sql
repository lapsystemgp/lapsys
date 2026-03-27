-- CreateEnum
CREATE TYPE "Role" AS ENUM ('Patient', 'LabStaff', 'Admin');

-- CreateEnum
CREATE TYPE "LabOnboardingStatus" AS ENUM ('PendingReview', 'Active', 'Rejected', 'Suspended');

-- CreateEnum
CREATE TYPE "BookingType" AS ENUM ('LabVisit', 'HomeCollection');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('Pending', 'Confirmed', 'Rejected', 'Cancelled', 'Completed');

-- CreateEnum
CREATE TYPE "ResultStatus" AS ENUM ('Pending', 'Uploaded', 'Delivered');

-- CreateEnum
CREATE TYPE "ReviewStatus" AS ENUM ('Pending', 'Published', 'Rejected');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'Patient',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PatientProfile" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "full_name" TEXT,
    "phone" TEXT,
    "address" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PatientProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LabProfile" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "lab_name" TEXT NOT NULL,
    "phone" TEXT,
    "address" TEXT NOT NULL,
    "accreditation" TEXT,
    "turnaround_time" TEXT,
    "home_collection" BOOLEAN NOT NULL DEFAULT false,
    "onboarding_status" "LabOnboardingStatus" NOT NULL DEFAULT 'PendingReview',
    "rating_average" DOUBLE PRECISION,
    "review_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LabProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LabTest" (
    "id" TEXT NOT NULL,
    "lab_profile_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "price_egp" INTEGER NOT NULL,
    "description" TEXT,
    "preparation" TEXT,
    "turnaround_time" TEXT,
    "parameters_count" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LabTest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LabScheduleSlot" (
    "id" TEXT NOT NULL,
    "lab_profile_id" TEXT NOT NULL,
    "starts_at" TIMESTAMP(3) NOT NULL,
    "ends_at" TIMESTAMP(3) NOT NULL,
    "capacity" INTEGER NOT NULL DEFAULT 1,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LabScheduleSlot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Booking" (
    "id" TEXT NOT NULL,
    "patient_profile_id" TEXT NOT NULL,
    "lab_profile_id" TEXT NOT NULL,
    "lab_test_id" TEXT NOT NULL,
    "booking_type" "BookingType" NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'Pending',
    "scheduled_at" TIMESTAMP(3) NOT NULL,
    "home_address" TEXT,
    "total_price_egp" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "schedule_slot_id" TEXT,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingStatusEvent" (
    "id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "status" "BookingStatus" NOT NULL,
    "note" TEXT,
    "actor_user_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookingStatusEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ResultFile" (
    "id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "status" "ResultStatus" NOT NULL DEFAULT 'Pending',
    "file_name" TEXT NOT NULL,
    "file_url" TEXT NOT NULL,
    "mime_type" TEXT NOT NULL,
    "size_bytes" INTEGER NOT NULL,
    "uploaded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "uploaded_by_user_id" TEXT,

    CONSTRAINT "ResultFile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ResultSummary" (
    "id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "highlights" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ResultSummary_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Review" (
    "id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "patient_profile_id" TEXT NOT NULL,
    "lab_profile_id" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "status" "ReviewStatus" NOT NULL DEFAULT 'Pending',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FaqEntry" (
    "id" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "answer" TEXT NOT NULL,
    "category" TEXT,
    "tags" TEXT[],
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FaqEntry_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "PatientProfile_user_id_key" ON "PatientProfile"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "LabProfile_user_id_key" ON "LabProfile"("user_id");

-- CreateIndex
CREATE INDEX "LabScheduleSlot_lab_profile_id_starts_at_idx" ON "LabScheduleSlot"("lab_profile_id", "starts_at");

-- CreateIndex
CREATE UNIQUE INDEX "Booking_schedule_slot_id_key" ON "Booking"("schedule_slot_id");

-- CreateIndex
CREATE INDEX "Booking_lab_profile_id_scheduled_at_idx" ON "Booking"("lab_profile_id", "scheduled_at");

-- CreateIndex
CREATE INDEX "Booking_patient_profile_id_scheduled_at_idx" ON "Booking"("patient_profile_id", "scheduled_at");

-- CreateIndex
CREATE INDEX "BookingStatusEvent_booking_id_created_at_idx" ON "BookingStatusEvent"("booking_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "ResultFile_booking_id_key" ON "ResultFile"("booking_id");

-- CreateIndex
CREATE UNIQUE INDEX "ResultSummary_booking_id_key" ON "ResultSummary"("booking_id");

-- CreateIndex
CREATE UNIQUE INDEX "Review_booking_id_key" ON "Review"("booking_id");

-- AddForeignKey
ALTER TABLE "PatientProfile" ADD CONSTRAINT "PatientProfile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LabProfile" ADD CONSTRAINT "LabProfile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LabTest" ADD CONSTRAINT "LabTest_lab_profile_id_fkey" FOREIGN KEY ("lab_profile_id") REFERENCES "LabProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LabScheduleSlot" ADD CONSTRAINT "LabScheduleSlot_lab_profile_id_fkey" FOREIGN KEY ("lab_profile_id") REFERENCES "LabProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_patient_profile_id_fkey" FOREIGN KEY ("patient_profile_id") REFERENCES "PatientProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_lab_profile_id_fkey" FOREIGN KEY ("lab_profile_id") REFERENCES "LabProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_lab_test_id_fkey" FOREIGN KEY ("lab_test_id") REFERENCES "LabTest"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_schedule_slot_id_fkey" FOREIGN KEY ("schedule_slot_id") REFERENCES "LabScheduleSlot"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingStatusEvent" ADD CONSTRAINT "BookingStatusEvent_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingStatusEvent" ADD CONSTRAINT "BookingStatusEvent_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultFile" ADD CONSTRAINT "ResultFile_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultFile" ADD CONSTRAINT "ResultFile_uploaded_by_user_id_fkey" FOREIGN KEY ("uploaded_by_user_id") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultSummary" ADD CONSTRAINT "ResultSummary_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Review" ADD CONSTRAINT "Review_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Review" ADD CONSTRAINT "Review_patient_profile_id_fkey" FOREIGN KEY ("patient_profile_id") REFERENCES "PatientProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Review" ADD CONSTRAINT "Review_lab_profile_id_fkey" FOREIGN KEY ("lab_profile_id") REFERENCES "LabProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

