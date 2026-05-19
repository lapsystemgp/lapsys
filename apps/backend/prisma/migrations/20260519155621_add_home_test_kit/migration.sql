-- CreateEnum
CREATE TYPE "KitStatus" AS ENUM ('AwaitingShipment', 'Shipped', 'Delivered', 'SampleReceived');

-- AlterEnum
ALTER TYPE "BookingType" ADD VALUE 'HomeTestKit';

-- AlterEnum
ALTER TYPE "PaymentMethod" ADD VALUE 'CashOnDelivery';

-- AlterTable
ALTER TABLE "Booking" ADD COLUMN     "kit_delivered_at" TIMESTAMP(3),
ADD COLUMN     "kit_shipped_at" TIMESTAMP(3),
ADD COLUMN     "kit_status" "KitStatus",
ADD COLUMN     "kit_tracking_number" TEXT,
ADD COLUMN     "sample_received_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "LabProfile" ADD COLUMN     "home_test_kit" BOOLEAN NOT NULL DEFAULT false;
