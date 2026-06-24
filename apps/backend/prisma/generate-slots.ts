/**
 * Generates future schedule slots for all active labs without wiping any data.
 * Run with: npx ts-node prisma/generate-slots.ts
 *
 * Safe to run repeatedly — skips labs that already have slots in the window.
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const DEFAULT_TIME_SLOTS = [
  '08:00', '09:00', '10:00', '11:00',
  '12:00', '13:00', '14:00',
];
const DAYS = 30;

function toDateWithTime(base: Date, offsetDays: number, time: string): Date {
  const [hours, minutes] = time.split(':').map(Number);
  const date = new Date(base);
  date.setDate(date.getDate() + offsetDays);
  date.setHours(hours, minutes, 0, 0);
  return date;
}

function addMinutes(date: Date, mins: number): Date {
  return new Date(date.getTime() + mins * 60 * 1000);
}

async function main() {
  const now = new Date();
  const windowEnd = new Date(now);
  windowEnd.setDate(windowEnd.getDate() + DAYS);

  const labs = await prisma.labProfile.findMany({
    where: { onboarding_status: 'Active' },
    select: { id: true, lab_name: true },
  });

  console.log(`Found ${labs.length} active labs. Generating slots for next ${DAYS} days…`);

  for (const lab of labs) {
    // Check how many future slots this lab already has in the window
    const existing = await prisma.labScheduleSlot.count({
      where: {
        lab_profile_id: lab.id,
        starts_at: { gte: now, lt: windowEnd },
        is_active: true,
      },
    });

    if (existing > 0) {
      console.log(`  ${lab.lab_name}: already has ${existing} slots — skipping`);
      continue;
    }

    const slotData = [];
    for (let day = 1; day <= DAYS; day++) {
      for (const time of DEFAULT_TIME_SLOTS) {
        const startsAt = toDateWithTime(now, day, time);
        slotData.push({
          lab_profile_id: lab.id,
          starts_at: startsAt,
          ends_at: addMinutes(startsAt, 30),
          capacity: 1,
          is_active: true,
        });
      }
    }

    await prisma.labScheduleSlot.createMany({ data: slotData });
    console.log(`  ${lab.lab_name}: created ${slotData.length} slots`);
  }

  console.log('Done.');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
