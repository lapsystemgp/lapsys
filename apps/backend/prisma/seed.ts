import {
  PrismaClient,
  BookingStatus,
  BookingType,
  LabOnboardingStatus,
  PaymentMethod,
  PaymentStatus,
  ResultStatus,
  ReviewStatus,
  Role,
} from "@prisma/client";
import * as bcrypt from "bcrypt";

const prisma = new PrismaClient();

const labSeedData = [
  {
    name: "Alaf labs",
    rating: 4.8,
    reviews: 342,
    distance: 1.2,
    price: 450,
    homeCollection: true,
    timeSlots: ["09:00", "11:00", "14:00", "16:00"],
    address: "12 Nile Corniche, Downtown Cairo",
    accreditation: "NABL, CAP",
    turnaroundTime: "24 hours",
  },
  {
    name: "Al mokhtabar",
    rating: 4.6,
    reviews: 218,
    distance: 2.5,
    price: 380,
    homeCollection: true,
    timeSlots: ["08:00", "10:00", "13:00", "15:00"],
    address: "45 Tahrir Street, Garden City, Cairo",
    accreditation: "NABL",
    turnaroundTime: "48 hours",
  },
  {
    name: "Daman labs",
    rating: 4.9,
    reviews: 567,
    distance: 3.8,
    price: 520,
    homeCollection: true,
    timeSlots: ["09:30", "12:00", "15:00", "17:00"],
    address: "78 El Merghany Street, Heliopolis, Cairo",
    accreditation: "NABL, CAP, ISO",
    turnaroundTime: "12 hours",
  },
  {
    name: "Makka lab",
    rating: 4.3,
    reviews: 156,
    distance: 0.8,
    price: 350,
    homeCollection: false,
    timeSlots: ["08:30", "11:30", "14:30"],
    address: "32 Ramses Street, Downtown Cairo",
    accreditation: "NABL",
    turnaroundTime: "48 hours",
  },
  {
    name: "Future lab",
    rating: 4.7,
    reviews: 423,
    distance: 4.2,
    price: 580,
    homeCollection: true,
    timeSlots: ["07:00", "10:00", "13:00", "16:00", "18:00"],
    address: "55 Road 9, Maadi, Cairo",
    accreditation: "NABL, CAP, ISO, JCI",
    turnaroundTime: "6 hours",
  },
  {
    name: "Canal labs",
    rating: 4.5,
    reviews: 289,
    distance: 2.1,
    price: 420,
    homeCollection: true,
    timeSlots: ["09:00", "12:00", "15:00", "17:00"],
    address: "89 Syria Street, Mohandessin, Giza",
    accreditation: "NABL, CAP",
    turnaroundTime: "24 hours",
  },
];

const testCatalog = [
  {
    name: "Complete Blood Count (CBC)",
    category: "Blood Tests",
    price: 450,
    description: "Measures red blood cells, white blood cells, hemoglobin, and platelets",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 18,
  },
  {
    name: "Lipid Profile",
    category: "Blood Tests",
    price: 650,
    description: "Tests for cholesterol levels and heart disease risk",
    preparation: "Fasting for 9-12 hours required",
    turnaroundTime: "24 hours",
    parametersCount: 8,
  },
  {
    name: "Thyroid Panel (TSH, T3, T4)",
    category: "Hormone Tests",
    price: 580,
    description: "Complete thyroid function assessment",
    preparation: "No fasting required, best taken in morning",
    turnaroundTime: "48 hours",
    parametersCount: 3,
  },
  {
    name: "Liver Function Test (LFT)",
    category: "Blood Tests",
    price: 520,
    description: "Evaluates liver health and function",
    preparation: "Fasting for 8-12 hours recommended",
    turnaroundTime: "24 hours",
    parametersCount: 12,
  },
  {
    name: "Kidney Function Test",
    category: "Blood Tests",
    price: 490,
    description: "Assesses kidney health and function",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 10,
  },
  {
    name: "HbA1c (Diabetes)",
    category: "Diabetes",
    price: 420,
    description: "Measures average blood sugar over 3 months",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
  },
  {
    name: "Vitamin D Test",
    category: "Vitamin Tests",
    price: 850,
    description: "Measures Vitamin D levels in blood",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
  },
  {
    name: "Vitamin B12",
    category: "Vitamin Tests",
    price: 680,
    description: "Tests for Vitamin B12 deficiency",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
  },
];

const faqEntries = [
  {
    question: "Do I need to fast for a CBC test?",
    answer: "CBC tests typically do not require fasting. Some labs may still ask for fasting, so confirm before your visit.",
    category: "Preparation",
    tags: ["CBC", "fasting", "blood tests"],
  },
  {
    question: "How long does it take to get results?",
    answer: "Most labs deliver results within 24-48 hours. Some specialized tests can take longer.",
    category: "Results",
    tags: ["results", "turnaround"],
  },
  {
    question: "Can I book a home collection?",
    answer: "Yes. Many labs offer home collection for an additional fee. You can filter labs that provide this service.",
    category: "Booking",
    tags: ["home collection", "booking"],
  },
];

function toDateWithTime(base: Date, offsetDays: number, time: string) {
  const [hours, minutes] = time.split(":").map(Number);
  const date = new Date(base);
  date.setDate(date.getDate() + offsetDays);
  date.setHours(hours, minutes, 0, 0);
  return date;
}

function addMinutes(date: Date, minutes: number) {
  return new Date(date.getTime() + minutes * 60 * 1000);
}

async function main() {
  await prisma.bookingStatusEvent.deleteMany();
  await prisma.review.deleteMany();
  await prisma.resultSummary.deleteMany();
  await prisma.resultFile.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.labScheduleSlot.deleteMany();
  await prisma.labTest.deleteMany();
  await prisma.patientProfile.deleteMany();
  await prisma.labProfile.deleteMany();
  await prisma.faqEntry.deleteMany();
  await prisma.user.deleteMany();

  const passwordHash = await bcrypt.hash("password123", 10);

  await prisma.user.create({
    data: {
      email: "admin@testly.com",
      password_hash: passwordHash,
      role: Role.Admin,
    },
  });

  const patientUser = await prisma.user.create({
    data: {
      email: "patient@testly.com",
      password_hash: passwordHash,
      role: Role.Patient,
      patient_profile: {
        create: {
          full_name: "Mazen Amir",
          phone: "+20 10 1234 5678",
          address: "12 Nile Corniche, Downtown Cairo",
        },
      },
    },
    include: { patient_profile: true },
  });

  await prisma.user.create({
    data: {
      email: "pendinglab@testly.com",
      password_hash: passwordHash,
      role: Role.LabStaff,
      lab_profile: {
        create: {
          lab_name: "Pending Lab (Demo)",
          phone: "+20 11 9999 9999",
          address: "Cairo, Egypt",
          home_collection: true,
          accreditation: "NABL",
          turnaround_time: "24 hours",
          onboarding_status: LabOnboardingStatus.PendingReview,
        },
      },
    },
  });

  const labProfiles = [];
  for (let index = 0; index < labSeedData.length; index += 1) {
    const lab = labSeedData[index];
    const emailSlug = lab.name.toLowerCase().replace(/\s+/g, "");
    const user = await prisma.user.create({
      data: {
        email: `${emailSlug}@testly.com`,
        password_hash: passwordHash,
        role: Role.LabStaff,
        lab_profile: {
          create: {
            lab_name: lab.name,
            phone: "+20 11 0000 0000",
            address: lab.address,
            accreditation: lab.accreditation,
            turnaround_time: lab.turnaroundTime,
            home_collection: lab.homeCollection,
            onboarding_status: LabOnboardingStatus.Active,
            rating_average: lab.rating,
            review_count: lab.reviews,
          },
        },
      },
      include: { lab_profile: true },
    });

    if (user.lab_profile) {
      labProfiles.push({
        ...lab,
        profile: user.lab_profile,
      });
    }
  }

  for (const lab of labProfiles) {
    await prisma.labTest.createMany({
      data: testCatalog.map((test) => ({
        lab_profile_id: lab.profile.id,
        name: test.name,
        category: test.category,
        price_egp: test.price,
        description: test.description,
        preparation: test.preparation,
        turnaround_time: test.turnaroundTime,
        parameters_count: test.parametersCount,
        is_active: true,
      })),
    });
  }

  const baseDate = new Date();
  const scheduleSlots = [];
  for (const lab of labProfiles) {
    for (const time of lab.timeSlots) {
      const slot = await prisma.labScheduleSlot.create({
        data: {
          lab_profile_id: lab.profile.id,
          starts_at: toDateWithTime(baseDate, 1, time),
          ends_at: addMinutes(toDateWithTime(baseDate, 1, time), 30),
          capacity: 1,
          is_active: true,
        },
      });
      scheduleSlots.push(slot);
    }
  }

  const patientProfileId = patientUser.patient_profile?.id;
  if (!patientProfileId || labProfiles.length === 0) {
    return;
  }

  const primaryLab = labProfiles[0];
  const secondaryLab = labProfiles[1];
  const primaryTest = await prisma.labTest.findFirst({
    where: { lab_profile_id: primaryLab.profile.id },
  });
  const secondaryTest = await prisma.labTest.findFirst({
    where: { lab_profile_id: secondaryLab.profile.id },
  });

  if (!primaryTest || !secondaryTest) {
    return;
  }

  const bookingOneSlot = scheduleSlots.find((slot) => slot.lab_profile_id === primaryLab.profile.id);
  const bookingTwoSlot = scheduleSlots.find((slot) => slot.lab_profile_id === secondaryLab.profile.id);

  const bookingOne = await prisma.booking.create({
    data: {
      patient_profile_id: patientProfileId,
      lab_profile_id: primaryLab.profile.id,
      lab_test_id: primaryTest.id,
      booking_type: BookingType.LabVisit,
      status: BookingStatus.Confirmed,
      scheduled_at: bookingOneSlot?.starts_at ?? toDateWithTime(baseDate, 2, "10:00"),
      total_price_egp: primaryTest.price_egp,
      payment_method: PaymentMethod.CashLabVisit,
      payment_status: PaymentStatus.Paid,
      payment_reference: "SEED-DEMO-CASH-LAB",
      payment_paid_at: new Date(),
      schedule_slot_id: bookingOneSlot?.id,
    },
  });

  const bookingTwo = await prisma.booking.create({
    data: {
      patient_profile_id: patientProfileId,
      lab_profile_id: secondaryLab.profile.id,
      lab_test_id: secondaryTest.id,
      booking_type: BookingType.HomeCollection,
      status: BookingStatus.Pending,
      scheduled_at: bookingTwoSlot?.starts_at ?? toDateWithTime(baseDate, 3, "14:00"),
      home_address: "28 El Nozha Street, Apartment 3C, Heliopolis, Cairo",
      total_price_egp: secondaryTest.price_egp + 100,
      payment_method: PaymentMethod.CashHomeCollection,
      payment_status: PaymentStatus.Pending,
      schedule_slot_id: bookingTwoSlot?.id,
    },
  });

  await prisma.bookingStatusEvent.createMany({
    data: [
      {
        booking_id: bookingOne.id,
        status: BookingStatus.Pending,
        note: "Booking created",
        actor_user_id: patientUser.id,
      },
      {
        booking_id: bookingOne.id,
        status: BookingStatus.Confirmed,
        note: "Lab confirmed booking",
        actor_user_id: primaryLab.profile.user_id,
      },
      {
        booking_id: bookingTwo.id,
        status: BookingStatus.Pending,
        note: "Booking created",
        actor_user_id: patientUser.id,
      },
    ],
  });

  await prisma.resultFile.create({
    data: {
      booking_id: bookingOne.id,
      status: ResultStatus.Uploaded,
      file_name: "cbc-results.pdf",
      file_url: "https://example.com/results/cbc-results.pdf",
      mime_type: "application/pdf",
      size_bytes: 220_000,
      uploaded_by_user_id: primaryLab.profile.user_id,
    },
  });

  await prisma.resultSummary.create({
    data: {
      booking_id: bookingOne.id,
      summary: "CBC within normal ranges. No abnormalities detected.",
      highlights: {
        hemoglobin: "13.4 g/dL",
        wbc: "6.1 x10^9/L",
        platelets: "250 x10^9/L",
      },
    },
  });

  await prisma.review.create({
    data: {
      booking_id: bookingOne.id,
      patient_profile_id: patientProfileId,
      lab_profile_id: primaryLab.profile.id,
      rating: 5,
      comment: "Fast service and clear results.",
      status: ReviewStatus.Published,
    },
  });

  await prisma.faqEntry.createMany({
    data: faqEntries.map((entry) => ({
      question: entry.question,
      answer: entry.answer,
      category: entry.category,
      tags: entry.tags,
      is_active: true,
    })),
  });
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
