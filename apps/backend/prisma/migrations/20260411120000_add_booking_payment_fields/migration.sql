-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('Online', 'CashHomeCollection', 'CashLabVisit');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('Pending', 'Paid', 'Failed', 'Refunded');

-- AlterTable
ALTER TABLE "Booking" ADD COLUMN     "payment_method" "PaymentMethod" NOT NULL DEFAULT 'Online',
ADD COLUMN     "payment_status" "PaymentStatus" NOT NULL DEFAULT 'Pending',
ADD COLUMN     "payment_reference" TEXT,
ADD COLUMN     "payment_paid_at" TIMESTAMP(3),
ADD COLUMN     "payment_failed_at" TIMESTAMP(3),
ADD COLUMN     "payment_failure_reason" TEXT;
