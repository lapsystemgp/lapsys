-- CreateEnum
CREATE TYPE "LabHistorySharing" AS ENUM ('SAME_LAB_ONLY', 'FULL_HISTORY_AUTHORIZED');

-- AlterTable
ALTER TABLE "PatientProfile" ADD COLUMN     "lab_history_sharing" "LabHistorySharing" NOT NULL DEFAULT 'SAME_LAB_ONLY';
