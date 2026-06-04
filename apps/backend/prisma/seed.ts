import {
  Prisma,
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
import * as fs from "node:fs";
import * as path from "node:path";

const prisma = new PrismaClient();

// ---------------------------------------------------------------------------
// Lab data — 21 labs across 11 Egyptian cities
// catalogTier: 'full' | 'extended' | 'standard' | 'basic'
// ---------------------------------------------------------------------------
const labSeedData = [
  // ── Cairo (5 labs) ──────────────────────────────────────────────────────
  {
    name: "Al Borg Laboratories",
    city: "Cairo",
    address: "10 Mohi El Din Abu El Ezz Street, Mohandessin, Cairo",
    phone: "+20 2 2404 4455",
    latitude: 30.0595,
    longitude: 31.2049,
    accreditation: "NABL, CAP, ISO",
    turnaroundTime: "12 hours",
    homeCollection: true,
    homeTestKit: true,
    timeSlots: ["07:00", "09:00", "10:30", "12:00", "14:00", "15:30", "17:00"],
    catalogTier: "full" as const,
    priceMultiplier: 1.25,
  },
  {
    name: "El Mokhtabar",
    city: "Cairo",
    address: "45 Tahrir Square, Downtown Cairo",
    phone: "+20 2 3347 1234",
    latitude: 30.0444,
    longitude: 31.2357,
    accreditation: "NABL, CAP",
    turnaroundTime: "24 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["08:00", "10:00", "12:00", "14:00", "16:00"],
    catalogTier: "full" as const,
    priceMultiplier: 1.1,
  },
  {
    name: "Cairo Scan Medical Lab",
    city: "Cairo",
    address: "78 El Merghany Street, Heliopolis, Cairo",
    phone: "+20 2 2690 5555",
    latitude: 30.0875,
    longitude: 31.3276,
    accreditation: "NABL, ISO",
    turnaroundTime: "24 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["08:00", "10:00", "12:00", "14:00", "16:00"],
    catalogTier: "extended" as const,
    priceMultiplier: 1.2,
  },
  {
    name: "Alfa Laboratories",
    city: "Cairo",
    address: "55 Road 9, Maadi, Cairo",
    phone: "+20 2 2516 7890",
    latitude: 29.9602,
    longitude: 31.2569,
    accreditation: "NABL, CAP, ISO, JCI",
    turnaroundTime: "6 hours",
    homeCollection: true,
    homeTestKit: true,
    timeSlots: ["07:00", "09:00", "10:30", "12:00", "14:00", "15:30", "17:00"],
    catalogTier: "full" as const,
    priceMultiplier: 1.3,
  },
  {
    name: "Royal Lab",
    city: "Cairo",
    address: "15 Mustafa El Nahas Street, Nasr City, Cairo",
    phone: "+20 2 2260 3344",
    latitude: 30.0626,
    longitude: 31.3428,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "11:00", "14:00", "16:00"],
    catalogTier: "standard" as const,
    priceMultiplier: 1.05,
  },
  // ── Giza (2 labs) ────────────────────────────────────────────────────────
  {
    name: "Pyramids Medical Lab",
    city: "Giza",
    address: "32 Shehab Street, Dokki, Giza",
    phone: "+20 2 3748 1100",
    latitude: 30.0444,
    longitude: 31.2000,
    accreditation: "NABL, CAP",
    turnaroundTime: "24 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["08:00", "10:00", "12:00", "14:00", "16:00"],
    catalogTier: "extended" as const,
    priceMultiplier: 1.1,
  },
  {
    name: "Giza Central Diagnostics",
    city: "Giza",
    address: "89 Pyramids Avenue, Haram, Giza",
    phone: "+20 2 3851 2200",
    latitude: 29.9765,
    longitude: 31.1313,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "12:00", "15:00"],
    catalogTier: "basic" as const,
    priceMultiplier: 0.95,
  },
  // ── Alexandria (3 labs) ──────────────────────────────────────────────────
  {
    name: "Al Borg Alexandria",
    city: "Alexandria",
    address: "12 Abu Qir Street, Smouha, Alexandria",
    phone: "+20 3 4856 7777",
    latitude: 31.2156,
    longitude: 29.9553,
    accreditation: "NABL, CAP, ISO",
    turnaroundTime: "12 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["08:00", "10:00", "12:00", "14:00", "16:00"],
    catalogTier: "full" as const,
    priceMultiplier: 1.2,
  },
  {
    name: "Nile Delta Diagnostics",
    city: "Alexandria",
    address: "45 Victor Emmanuel Street, Roushdy, Alexandria",
    phone: "+20 3 5432 1111",
    latitude: 31.2399,
    longitude: 29.9629,
    accreditation: "NABL, ISO",
    turnaroundTime: "24 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["08:00", "10:00", "12:00", "14:00", "16:00"],
    catalogTier: "extended" as const,
    priceMultiplier: 1.05,
  },
  {
    name: "Alexandria Medical Center Lab",
    city: "Alexandria",
    address: "8 Stanley Bridge, Stanley, Alexandria",
    phone: "+20 3 3929 4455",
    latitude: 31.2472,
    longitude: 29.9772,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "11:00", "14:00", "16:00"],
    catalogTier: "standard" as const,
    priceMultiplier: 1.0,
  },
  // ── Ismailia (2 labs) ────────────────────────────────────────────────────
  {
    name: "Canal Medical Lab",
    city: "Ismailia",
    address: "22 Sultan Hussein Street, Ismailia",
    phone: "+20 64 3911 2233",
    latitude: 30.5965,
    longitude: 32.2715,
    accreditation: "NABL, CAP",
    turnaroundTime: "24 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["08:00", "10:00", "12:00", "14:00", "16:00"],
    catalogTier: "extended" as const,
    priceMultiplier: 1.05,
  },
  {
    name: "Ismailia Diagnostics Center",
    city: "Ismailia",
    address: "5 El Guish Road, Ismailia",
    phone: "+20 64 3225 6677",
    latitude: 30.5875,
    longitude: 32.2632,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "12:00", "15:00"],
    catalogTier: "basic" as const,
    priceMultiplier: 0.9,
  },
  // ── Port Said (1 lab) ────────────────────────────────────────────────────
  {
    name: "Port Said Medical Lab",
    city: "Port Said",
    address: "17 El Galaa Street, Port Said",
    phone: "+20 66 3320 5544",
    latitude: 31.2653,
    longitude: 32.3019,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["09:00", "11:00", "14:00", "16:00"],
    catalogTier: "standard" as const,
    priceMultiplier: 1.0,
  },
  // ── Suez (1 lab) ─────────────────────────────────────────────────────────
  {
    name: "Suez Canal Diagnostics",
    city: "Suez",
    address: "34 Port Tewfik Road, Suez",
    phone: "+20 62 3197 3322",
    latitude: 29.9668,
    longitude: 32.5498,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "12:00", "15:00"],
    catalogTier: "basic" as const,
    priceMultiplier: 0.9,
  },
  // ── Mansoura (2 labs) ────────────────────────────────────────────────────
  {
    name: "Delta Medical Lab",
    city: "Mansoura",
    address: "12 El Gomhoreya Street, Mansoura",
    phone: "+20 50 2245 7788",
    latitude: 31.0409,
    longitude: 31.3785,
    accreditation: "NABL, CAP",
    turnaroundTime: "24 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["08:00", "10:00", "12:00", "14:00", "16:00"],
    catalogTier: "extended" as const,
    priceMultiplier: 1.0,
  },
  {
    name: "Mansoura Diagnostics Center",
    city: "Mansoura",
    address: "78 El Nasr Street, Mansoura",
    phone: "+20 50 2278 3344",
    latitude: 31.0353,
    longitude: 31.3842,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "12:00", "15:00"],
    catalogTier: "basic" as const,
    priceMultiplier: 0.85,
  },
  // ── Tanta (1 lab) ─────────────────────────────────────────────────────────
  {
    name: "Tanta Central Lab",
    city: "Tanta",
    address: "5 El Bahr Street, Tanta",
    phone: "+20 40 3316 1122",
    latitude: 30.7865,
    longitude: 31.0004,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["09:00", "11:00", "14:00", "16:00"],
    catalogTier: "standard" as const,
    priceMultiplier: 0.9,
  },
  // ── Zagazig (1 lab) ──────────────────────────────────────────────────────
  {
    name: "Zagazig Medical Diagnostics",
    city: "Zagazig",
    address: "22 El Thawra Street, Zagazig",
    phone: "+20 55 2282 9900",
    latitude: 30.5877,
    longitude: 31.5020,
    accreditation: "NABL",
    turnaroundTime: "72 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "12:00", "15:00"],
    catalogTier: "basic" as const,
    priceMultiplier: 0.85,
  },
  // ── Assiut (1 lab) ───────────────────────────────────────────────────────
  {
    name: "Upper Egypt Diagnostics",
    city: "Assiut",
    address: "15 El Nil Street, Assiut",
    phone: "+20 88 2312 5566",
    latitude: 27.1809,
    longitude: 31.1837,
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    homeCollection: true,
    homeTestKit: false,
    timeSlots: ["09:00", "11:00", "14:00", "16:00"],
    catalogTier: "standard" as const,
    priceMultiplier: 0.85,
  },
  // ── Luxor (1 lab) ────────────────────────────────────────────────────────
  {
    name: "Pharaohs Medical Lab",
    city: "Luxor",
    address: "8 Karnak Temple Road, Luxor",
    phone: "+20 95 2373 4455",
    latitude: 25.6872,
    longitude: 32.6396,
    accreditation: "NABL",
    turnaroundTime: "72 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "12:00", "15:00"],
    catalogTier: "basic" as const,
    priceMultiplier: 0.8,
  },
  // ── Aswan (1 lab) ─────────────────────────────────────────────────────────
  {
    name: "Nubia Medical Center",
    city: "Aswan",
    address: "3 Corniche El Nil Street, Aswan",
    phone: "+20 97 2313 2244",
    latitude: 24.0889,
    longitude: 32.8998,
    accreditation: "NABL",
    turnaroundTime: "72 hours",
    homeCollection: false,
    homeTestKit: false,
    timeSlots: ["09:00", "12:00", "15:00"],
    catalogTier: "basic" as const,
    priceMultiplier: 0.8,
  },
];

// ---------------------------------------------------------------------------
// Test catalog — 49 tests ordered from most essential to specialist
// BASIC tier: indices 0-13 (14 tests)
// STANDARD tier: indices 0-27 (28 tests)
// EXTENDED tier: indices 0-38 (39 tests)
// FULL tier: all 49
// ---------------------------------------------------------------------------
const testCatalog = [
  // ── Core / Basic (0-13) ──────────────────────────────────────────────────
  {
    name: "Complete Blood Count (CBC)",
    category: "Blood Tests",
    description: "Measures red blood cells, white blood cells, hemoglobin, hematocrit, and platelets to screen for a wide range of conditions",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 18,
    basePrice: 350,
  },
  {
    name: "CPC (Complete Patient Check)",
    category: "Blood Tests",
    description: "Comprehensive annual health screening bundle including CBC, glucose, lipid profile, liver and kidney function markers — the complete preventive check panel",
    preparation: "Fasting for 10-12 hours required",
    turnaroundTime: "24 hours",
    parametersCount: 25,
    basePrice: 750,
  },
  {
    name: "Fasting Blood Glucose",
    category: "Diabetes",
    description: "Measures blood sugar level after overnight fast; used to screen for diabetes and prediabetes",
    preparation: "Fasting for 8-12 hours required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 80,
  },
  {
    name: "HbA1c (Glycated Hemoglobin)",
    category: "Diabetes",
    description: "Measures average blood sugar over the past 2-3 months; key indicator for diabetes monitoring and diagnosis",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 380,
  },
  {
    name: "Lipid Profile",
    category: "Cholesterol & Heart",
    description: "Measures total cholesterol, LDL, HDL, and triglycerides to assess cardiovascular risk",
    preparation: "Fasting for 9-12 hours required",
    turnaroundTime: "24 hours",
    parametersCount: 8,
    basePrice: 520,
  },
  {
    name: "Thyroid Panel (TSH, T3, T4)",
    category: "Hormone Tests",
    description: "Complete thyroid function assessment measuring TSH, total T3, and total T4",
    preparation: "No fasting required; best collected in the morning",
    turnaroundTime: "48 hours",
    parametersCount: 3,
    basePrice: 520,
  },
  {
    name: "Liver Function Test (LFT)",
    category: "Liver & Kidney",
    description: "Evaluates liver health by measuring enzymes (ALT, AST, ALP), bilirubin, albumin, and total protein",
    preparation: "Fasting for 8-12 hours recommended",
    turnaroundTime: "24 hours",
    parametersCount: 12,
    basePrice: 450,
  },
  {
    name: "Kidney Function Test (KFT)",
    category: "Liver & Kidney",
    description: "Assesses kidney function through creatinine, urea, uric acid, and electrolytes",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 10,
    basePrice: 420,
  },
  {
    name: "ESR (Erythrocyte Sedimentation Rate)",
    category: "Blood Tests",
    description: "Measures how quickly red blood cells settle; elevated ESR indicates inflammation or infection",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 120,
  },
  {
    name: "CRP (C-Reactive Protein)",
    category: "Blood Tests",
    description: "Detects inflammation and monitors inflammatory conditions, infections, and response to treatment",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 280,
  },
  {
    name: "Urine Analysis (Complete)",
    category: "Infection & Microbiology",
    description: "Comprehensive urine exam checking physical, chemical, and microscopic properties to detect UTIs, kidney disease, and metabolic disorders",
    preparation: "Mid-stream urine sample; first morning sample preferred",
    turnaroundTime: "24 hours",
    parametersCount: 15,
    basePrice: 120,
  },
  {
    name: "Stool Analysis",
    category: "Infection & Microbiology",
    description: "Examines stool for parasites, bacteria, blood, and digestive abnormalities",
    preparation: "Fresh stool sample required",
    turnaroundTime: "48 hours",
    parametersCount: 8,
    basePrice: 100,
  },
  {
    name: "Uric Acid",
    category: "Blood Tests",
    description: "Measures uric acid levels to diagnose and monitor gout, kidney stones, and kidney disease",
    preparation: "Fasting for 4-8 hours recommended",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 180,
  },
  {
    name: "Random Blood Glucose",
    category: "Diabetes",
    description: "Blood sugar test taken at any time of day, regardless of when the patient last ate",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 80,
  },
  // ── Standard additions (14-27) ───────────────────────────────────────────
  {
    name: "Vitamin D Test",
    category: "Vitamin Tests",
    description: "Measures 25-hydroxyvitamin D level in blood; low levels linked to bone disease, immune dysfunction, and fatigue",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 700,
  },
  {
    name: "Vitamin B12",
    category: "Vitamin Tests",
    description: "Measures Vitamin B12 (cobalamin) level; deficiency causes anemia, fatigue, and neurological symptoms",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 550,
  },
  {
    name: "Vitamin B9 (Folic Acid)",
    category: "Vitamin Tests",
    description: "Measures folate level; important for red blood cell formation and neural tube development in pregnancy",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 450,
  },
  {
    name: "Iron Studies (Ferritin, Serum Iron, TIBC)",
    category: "Vitamin Tests",
    description: "Comprehensive iron status assessment measuring ferritin, serum iron, and total iron-binding capacity",
    preparation: "Fasting for 8-12 hours required; morning sample preferred",
    turnaroundTime: "48 hours",
    parametersCount: 3,
    basePrice: 600,
  },
  {
    name: "Hepatitis B Surface Antigen (HBsAg)",
    category: "Hepatitis",
    description: "Detects current Hepatitis B virus infection; positive result indicates active or chronic HBV",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 200,
  },
  {
    name: "Hepatitis C Antibody (Anti-HCV)",
    category: "Hepatitis",
    description: "Screens for Hepatitis C infection by detecting antibodies against the HCV virus",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 250,
  },
  {
    name: "Calcium (Total)",
    category: "Vitamin Tests",
    description: "Measures total calcium level in blood; important for bone health, muscle function, and nerve signaling",
    preparation: "Fasting for 8-12 hours recommended",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 150,
  },
  {
    name: "Magnesium",
    category: "Vitamin Tests",
    description: "Measures magnesium level; low levels linked to muscle cramps, fatigue, and cardiac arrhythmias",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 160,
  },
  {
    name: "D-Dimer",
    category: "Blood Tests",
    description: "Detects blood clot fragments; elevated levels may indicate deep vein thrombosis, pulmonary embolism, or DIC",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 450,
  },
  {
    name: "Prothrombin Time (PT/INR)",
    category: "Blood Tests",
    description: "Measures how long it takes blood to clot; used to monitor anticoagulant therapy and assess bleeding disorders",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 3,
    basePrice: 200,
  },
  {
    name: "Rheumatoid Factor (RF)",
    category: "Immunology",
    description: "Detects antibodies associated with rheumatoid arthritis and other autoimmune conditions",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 250,
  },
  {
    name: "COVID-19 PCR",
    category: "Infection & Microbiology",
    description: "Molecular test detecting SARS-CoV-2 genetic material; the gold standard for COVID-19 diagnosis",
    preparation: "No fasting required; nasopharyngeal swab collected",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 750,
  },
  {
    name: "TSH Ultra Sensitive",
    category: "Hormone Tests",
    description: "High-sensitivity thyroid-stimulating hormone test for detecting subtle thyroid dysfunction",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 350,
  },
  {
    name: "Insulin Level (Fasting)",
    category: "Diabetes",
    description: "Measures fasting insulin to evaluate insulin resistance, hypoglycemia, and pancreatic function",
    preparation: "Fasting for 8-12 hours required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 450,
  },
  // ── Extended additions (28-38) ───────────────────────────────────────────
  {
    name: "Complete Metabolic Panel",
    category: "Cholesterol & Heart",
    description: "Comprehensive blood chemistry panel including electrolytes, glucose, kidney and liver markers in one draw",
    preparation: "Fasting for 8-12 hours required",
    turnaroundTime: "24 hours",
    parametersCount: 16,
    basePrice: 850,
  },
  {
    name: "LDH (Lactate Dehydrogenase)",
    category: "Blood Tests",
    description: "Enzyme test used to detect tissue damage from heart attack, anemia, liver disease, and cancer",
    preparation: "No fasting required",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 230,
  },
  {
    name: "Hepatitis A IgM (Anti-HAV IgM)",
    category: "Hepatitis",
    description: "Detects recent Hepatitis A infection by measuring IgM antibodies; elevated during acute HAV infection",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 300,
  },
  {
    name: "Hepatitis B Core Antibody (Anti-HBc)",
    category: "Hepatitis",
    description: "Detects antibodies to Hepatitis B core antigen, indicating past or current HBV infection",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 280,
  },
  {
    name: "Free T3 / Free T4",
    category: "Hormone Tests",
    description: "Measures free (unbound) thyroid hormones for a more accurate assessment of thyroid function",
    preparation: "No fasting required; morning collection preferred",
    turnaroundTime: "48 hours",
    parametersCount: 2,
    basePrice: 600,
  },
  {
    name: "DHEA-S (Dehydroepiandrosterone Sulfate)",
    category: "Hormone Tests",
    description: "Measures adrenal androgen levels; used to evaluate adrenal function and androgen excess conditions",
    preparation: "No fasting required; morning sample required",
    turnaroundTime: "72 hours",
    parametersCount: 1,
    basePrice: 650,
  },
  {
    name: "Testosterone (Total)",
    category: "Hormone Tests",
    description: "Measures total testosterone level; used to diagnose hypogonadism, infertility, and hormonal disorders",
    preparation: "Morning sample required (7-10 AM); no fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 550,
  },
  {
    name: "Prolactin",
    category: "Hormone Tests",
    description: "Measures the hormone prolactin; elevated levels can indicate pituitary tumors, infertility, or galactorrhea",
    preparation: "Morning sample required; rest 30 minutes before collection",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 500,
  },
  {
    name: "Cortisol (Morning)",
    category: "Hormone Tests",
    description: "Measures morning cortisol level to assess adrenal gland function and screen for Cushing's or Addison's disease",
    preparation: "Sample must be collected between 7-9 AM; no fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 550,
  },
  {
    name: "PSA (Prostate-Specific Antigen)",
    category: "Tumor Markers",
    description: "Screens for prostate cancer and monitors treatment response; elevated levels warrant further investigation",
    preparation: "No fasting required; avoid ejaculation 48h before test",
    turnaroundTime: "48 hours",
    parametersCount: 1,
    basePrice: 450,
  },
  {
    name: "COVID-19 Rapid Antigen",
    category: "Infection & Microbiology",
    description: "Rapid test detecting SARS-CoV-2 antigen proteins; results available within 15-30 minutes",
    preparation: "No fasting required; nasopharyngeal swab collected",
    turnaroundTime: "1 hour",
    parametersCount: 1,
    basePrice: 200,
  },
  // ── Full tier additions (39-48) ──────────────────────────────────────────
  {
    name: "CA-125",
    category: "Tumor Markers",
    description: "Tumor marker mainly used to monitor ovarian cancer treatment; may be elevated in endometriosis and pelvic disease",
    preparation: "No fasting required",
    turnaroundTime: "72 hours",
    parametersCount: 1,
    basePrice: 600,
  },
  {
    name: "CA 19-9",
    category: "Tumor Markers",
    description: "Tumor marker used to monitor pancreatic, gallbladder, and bile duct cancers",
    preparation: "No fasting required",
    turnaroundTime: "72 hours",
    parametersCount: 1,
    basePrice: 750,
  },
  {
    name: "CEA (Carcinoembryonic Antigen)",
    category: "Tumor Markers",
    description: "Tumor marker used to monitor colorectal, lung, breast, and other cancers after treatment",
    preparation: "No fasting required; avoid smoking 24h before",
    turnaroundTime: "72 hours",
    parametersCount: 1,
    basePrice: 500,
  },
  {
    name: "AFP (Alpha-Fetoprotein)",
    category: "Tumor Markers",
    description: "Tumor marker for hepatocellular carcinoma and germ cell tumors; also used in prenatal screening",
    preparation: "No fasting required",
    turnaroundTime: "72 hours",
    parametersCount: 1,
    basePrice: 550,
  },
  {
    name: "Anti-Nuclear Antibody (ANA)",
    category: "Immunology",
    description: "Screens for autoimmune diseases including lupus, Sjögren's syndrome, and rheumatoid arthritis",
    preparation: "No fasting required",
    turnaroundTime: "72 hours",
    parametersCount: 1,
    basePrice: 650,
  },
  {
    name: "Toxoplasmosis IgG / IgM",
    category: "Immunology",
    description: "Detects Toxoplasma gondii antibodies; IgM indicates recent infection, IgG indicates past immunity",
    preparation: "No fasting required",
    turnaroundTime: "48 hours",
    parametersCount: 2,
    basePrice: 380,
  },
  {
    name: "Semen Analysis",
    category: "Reproductive Health",
    description: "Evaluates sperm count, motility, morphology, and volume for male fertility assessment",
    preparation: "2-5 days of sexual abstinence required; deliver sample within 1 hour",
    turnaroundTime: "24 hours",
    parametersCount: 12,
    basePrice: 350,
  },
  {
    name: "Malaria Film (Thick & Thin)",
    category: "Infection & Microbiology",
    description: "Microscopic examination of blood film to detect and identify malaria parasites and their species",
    preparation: "No fasting required; blood collected during fever episode if possible",
    turnaroundTime: "24 hours",
    parametersCount: 1,
    basePrice: 150,
  },
  {
    name: "Blood Culture",
    category: "Infection & Microbiology",
    description: "Detects bacteria or fungi in the blood to diagnose septicemia and guide antibiotic therapy",
    preparation: "No fasting required; blood collected before antibiotic therapy",
    turnaroundTime: "72 hours",
    parametersCount: 1,
    basePrice: 600,
  },
  {
    name: "Cardiac Enzymes (Troponin I/T)",
    category: "Cholesterol & Heart",
    description: "Measures cardiac troponin levels to diagnose heart attack and assess myocardial injury",
    preparation: "No fasting required; urgent test — results priority",
    turnaroundTime: "6 hours",
    parametersCount: 3,
    basePrice: 650,
  },
];

// Catalog tier slice boundaries
const BASIC_LIMIT = 14;
const STANDARD_LIMIT = 28;
const EXTENDED_LIMIT = 39;

function getTestsForTier(tier: "full" | "extended" | "standard" | "basic") {
  if (tier === "full") return testCatalog;
  if (tier === "extended") return testCatalog.slice(0, EXTENDED_LIMIT);
  if (tier === "standard") return testCatalog.slice(0, STANDARD_LIMIT);
  return testCatalog.slice(0, BASIC_LIMIT);
}

function tieredPrice(basePrice: number, multiplier: number): number {
  return Math.round((basePrice * multiplier) / 10) * 10;
}

// ---------------------------------------------------------------------------
// FAQ entries
// ---------------------------------------------------------------------------
const faqEntries = [
  {
    question: "Do I need to fast before a blood test?",
    answer: "It depends on the test. Lipid profile, fasting glucose, and liver function tests require 8-12 hours of fasting. CBC and thyroid tests generally do not require fasting.",
    category: "Preparation",
    tags: ["fasting", "preparation", "blood tests"],
  },
  {
    question: "How long does it take to get results?",
    answer: "Most routine blood tests are ready in 24 hours. Specialized tests (hormones, tumor markers) may take 48-72 hours. Rapid antigen tests give results in under an hour.",
    category: "Results",
    tags: ["results", "turnaround time"],
  },
  {
    question: "Can I book a home collection?",
    answer: "Yes. Many labs offer home collection for an additional EGP 100 fee. Filter labs by 'Home Collection' to see which labs offer this service in your area.",
    category: "Booking",
    tags: ["home collection", "booking"],
  },
  {
    question: "What is a CPC (Complete Patient Check)?",
    answer: "The CPC is a comprehensive annual health screening bundle. It covers CBC, blood glucose, lipid profile, liver and kidney function — everything needed for a full preventive checkup in one visit.",
    category: "Tests",
    tags: ["CPC", "comprehensive", "annual checkup"],
  },
  {
    question: "How do I prepare for a thyroid panel?",
    answer: "No fasting is required. For the most accurate TSH reading, have the sample collected in the morning (before 10 AM). Do not take thyroid medication before the test unless your doctor advises otherwise.",
    category: "Preparation",
    tags: ["thyroid", "TSH", "preparation"],
  },
  {
    question: "Is my medical data private?",
    answer: "Yes. Your test results are only accessible to you and the lab that conducted the test. Results are never shared with other labs or third parties without your explicit consent.",
    category: "Privacy",
    tags: ["privacy", "data", "security"],
  },
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// Canonical markers (unchanged from original)
// ---------------------------------------------------------------------------
async function seedCanonicalMarkers() {
  const markers = [
    { code: "GLUCOSE_FASTING", display_name: "Fasting glucose", category: "chemistry", default_unit: "mg/dL" },
    { code: "GLUCOSE_RANDOM", display_name: "Random glucose", category: "chemistry", default_unit: "mg/dL" },
    { code: "HBA1C", display_name: "HbA1c", category: "diabetes", default_unit: "%" },
    { code: "TSH", display_name: "TSH", category: "thyroid", default_unit: "mIU/L" },
    { code: "FT4", display_name: "Free T4", category: "thyroid", default_unit: "pmol/L" },
    { code: "FT3", display_name: "Free T3", category: "thyroid", default_unit: "pmol/L" },
    { code: "CREATININE", display_name: "Creatinine", category: "chemistry", default_unit: "mg/dL" },
  ];

  for (const m of markers) {
    await prisma.canonicalMarker.upsert({
      where: { code: m.code },
      create: m,
      update: { display_name: m.display_name, category: m.category, default_unit: m.default_unit },
    });
  }

  const glucose = await prisma.canonicalMarker.findUniqueOrThrow({ where: { code: "GLUCOSE_FASTING" } });
  const hba1c = await prisma.canonicalMarker.findUniqueOrThrow({ where: { code: "HBA1C" } });
  const tsh = await prisma.canonicalMarker.findUniqueOrThrow({ where: { code: "TSH" } });

  const aliases = [
    { canonical_marker_id: glucose.id, alias_normalized: "fasting glucose" },
    { canonical_marker_id: glucose.id, alias_normalized: "fasting blood sugar" },
    { canonical_marker_id: glucose.id, alias_normalized: "fbs" },
    { canonical_marker_id: hba1c.id, alias_normalized: "glycated hemoglobin" },
    { canonical_marker_id: hba1c.id, alias_normalized: "hba1c" },
    { canonical_marker_id: tsh.id, alias_normalized: "thyroid stimulating hormone" },
  ];

  for (const row of aliases) {
    await prisma.markerAlias.upsert({
      where: { alias_normalized: row.alias_normalized },
      create: row,
      update: { canonical_marker_id: row.canonical_marker_id },
    });
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main() {
  const samplePdfUrl = ensureSamplePdf();

  // Wipe all tables in dependency order
  await prisma.bookingStatusEvent.deleteMany();
  await prisma.review.deleteMany();
  await prisma.resultSummary.deleteMany();
  await prisma.resultObservation.deleteMany();
  await prisma.resultPanel.deleteMany();
  await prisma.resultFile.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.markerAlias.deleteMany();
  await prisma.canonicalMarker.deleteMany();
  await prisma.labScheduleSlot.deleteMany();
  await prisma.labTest.deleteMany();
  await prisma.patientProfile.deleteMany();
  await prisma.labProfile.deleteMany();
  await prisma.faqEntry.deleteMany();
  await prisma.user.deleteMany();

  const passwordHash = await bcrypt.hash("password123", 10);

  // ── Admin ──────────────────────────────────────────────────────────────
  await prisma.user.create({
    data: { email: "admin@testly.com", password_hash: passwordHash, role: Role.Admin },
  });

  // ── Demo patient (Mazen) ────────────────────────────────────────────────
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

  // ── Additional patient users for seeding reviews ────────────────────────
  const ahmedUser = await prisma.user.create({
    data: {
      email: "ahmed.khalil@testly.com",
      password_hash: passwordHash,
      role: Role.Patient,
      patient_profile: {
        create: {
          full_name: "Ahmed Khalil",
          phone: "+20 12 3456 7890",
          address: "25 El Nasr Road, Nasr City, Cairo",
        },
      },
    },
    include: { patient_profile: true },
  });

  const fatimaUser = await prisma.user.create({
    data: {
      email: "fatima.hassan@testly.com",
      password_hash: passwordHash,
      role: Role.Patient,
      patient_profile: {
        create: {
          full_name: "Fatima Hassan",
          phone: "+20 11 9876 5432",
          address: "7 Roushdy Street, Alexandria",
        },
      },
    },
    include: { patient_profile: true },
  });

  const omarUser = await prisma.user.create({
    data: {
      email: "omar.samir@testly.com",
      password_hash: passwordHash,
      role: Role.Patient,
      patient_profile: {
        create: {
          full_name: "Omar Samir",
          phone: "+20 10 5544 3322",
          address: "14 Maadi Road, Maadi, Cairo",
        },
      },
    },
    include: { patient_profile: true },
  });

  // ── Pending / Rejected demo lab accounts ───────────────────────────────
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
          city: "Cairo",
          home_collection: true,
          accreditation: "NABL",
          turnaround_time: "24 hours",
          onboarding_status: LabOnboardingStatus.PendingReview,
        },
      },
    },
  });

  await prisma.user.create({
    data: {
      email: "rejectedlab@testly.com",
      password_hash: passwordHash,
      role: Role.LabStaff,
      lab_profile: {
        create: {
          lab_name: "Rejected Lab Example",
          phone: "+20 11 8888 8888",
          address: "Alexandria, Egypt",
          city: "Alexandria",
          home_collection: false,
          accreditation: "None",
          turnaround_time: "72 hours",
          onboarding_status: LabOnboardingStatus.Rejected,
        },
      },
    },
  });

  // ── Create 21 active labs ───────────────────────────────────────────────
  const labProfiles: Array<{
    profile: Awaited<ReturnType<typeof prisma.labProfile.findFirstOrThrow>>;
    data: (typeof labSeedData)[number];
  }> = [];

  for (const lab of labSeedData) {
    const emailSlug = lab.name.toLowerCase().replace(/\s+/g, "").replace(/[()]/g, "");
    const user = await prisma.user.create({
      data: {
        email: `${emailSlug}@testly.com`,
        password_hash: passwordHash,
        role: Role.LabStaff,
        lab_profile: {
          create: {
            lab_name: lab.name,
            phone: lab.phone,
            address: lab.address,
            city: lab.city,
            accreditation: lab.accreditation,
            turnaround_time: lab.turnaroundTime,
            home_collection: lab.homeCollection,
            home_test_kit: lab.homeTestKit,
            onboarding_status: LabOnboardingStatus.Active,
            latitude: lab.latitude,
            longitude: lab.longitude,
          },
        },
      },
      include: { lab_profile: true },
    });

    if (user.lab_profile) {
      labProfiles.push({ profile: user.lab_profile, data: lab });
    }
  }

  // ── Create lab tests (per tier, per-lab pricing) ────────────────────────
  for (const { profile, data } of labProfiles) {
    const tests = getTestsForTier(data.catalogTier);
    await prisma.labTest.createMany({
      data: tests.map((t) => ({
        lab_profile_id: profile.id,
        name: t.name,
        category: t.category,
        price_egp: tieredPrice(t.basePrice, data.priceMultiplier),
        description: t.description,
        preparation: t.preparation,
        turnaround_time: t.turnaroundTime,
        parameters_count: t.parametersCount,
        is_active: true,
      })),
    });
  }

  await seedCanonicalMarkers();

  // ── Create schedule slots for the next 7 days ───────────────────────────
  const baseDate = new Date();
  const slotData: Parameters<typeof prisma.labScheduleSlot.createMany>[0]['data'] = [];

  for (const { profile, data } of labProfiles) {
    for (let day = 1; day <= 7; day++) {
      for (const time of data.timeSlots) {
        slotData.push({
          lab_profile_id: profile.id,
          starts_at: toDateWithTime(baseDate, day, time),
          ends_at: addMinutes(toDateWithTime(baseDate, day, time), 30),
          capacity: 1,
          is_active: true,
        });
      }
    }
  }

  await prisma.labScheduleSlot.createMany({ data: slotData });

  const scheduleSlots = await prisma.labScheduleSlot.findMany({
    where: { lab_profile_id: { in: labProfiles.map(({ profile }) => profile.id) } },
  });

  // ── Demo bookings for Mazen ─────────────────────────────────────────────
  const patientProfileId = patientUser.patient_profile?.id;
  if (!patientProfileId || labProfiles.length < 2) return;

  const primaryLab = labProfiles[0]; // Al Borg Cairo
  const secondaryLab = labProfiles[1]; // El Mokhtabar

  const primaryTest = await prisma.labTest.findFirst({ where: { lab_profile_id: primaryLab.profile.id } });
  const secondaryTest = await prisma.labTest.findFirst({ where: { lab_profile_id: secondaryLab.profile.id } });

  if (!primaryTest || !secondaryTest) return;

  const bookingOneSlot = scheduleSlots.find((s) => s.lab_profile_id === primaryLab.profile.id);
  const bookingTwoSlot = scheduleSlots.find((s) => s.lab_profile_id === secondaryLab.profile.id);

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
      { booking_id: bookingOne.id, status: BookingStatus.Pending, note: "Booking created", actor_user_id: patientUser.id },
      { booking_id: bookingOne.id, status: BookingStatus.Confirmed, note: "Lab confirmed booking", actor_user_id: primaryLab.profile.user_id },
      { booking_id: bookingTwo.id, status: BookingStatus.Pending, note: "Booking created", actor_user_id: patientUser.id },
    ],
  });

  await prisma.resultFile.create({
    data: {
      booking_id: bookingOne.id,
      status: ResultStatus.Uploaded,
      file_name: "cbc-results.pdf",
      file_url: samplePdfUrl,
      mime_type: "application/pdf",
      size_bytes: 220_000,
      uploaded_by_user_id: primaryLab.profile.user_id,
    },
  });

  await prisma.resultSummary.create({
    data: {
      booking_id: bookingOne.id,
      summary: "CBC within normal ranges. No abnormalities detected.",
      highlights: { hemoglobin: "13.4 g/dL", wbc: "6.1 x10^9/L", platelets: "250 x10^9/L" },
    },
  });

  const glucoseMarker = await prisma.canonicalMarker.findUniqueOrThrow({ where: { code: "GLUCOSE_FASTING" } });
  const hba1cMarker = await prisma.canonicalMarker.findUniqueOrThrow({ where: { code: "HBA1C" } });

  await prisma.resultPanel.create({
    data: {
      booking_id: bookingOne.id,
      name: "Metabolic panel",
      test_date: bookingOne.scheduled_at,
      sort_order: 0,
      observations: {
        create: [
          {
            canonical_marker_id: glucoseMarker.id,
            raw_name: "Fasting glucose",
            value_numeric: new Prisma.Decimal(102),
            unit: "mg/dL",
            ref_low: new Prisma.Decimal(70),
            ref_high: new Prisma.Decimal(100),
            value_in_canonical_unit: new Prisma.Decimal(102),
            comparable_unit: "mg/dL",
            is_comparable: true,
          },
          {
            canonical_marker_id: hba1cMarker.id,
            raw_name: "HbA1c",
            value_numeric: new Prisma.Decimal(5.4),
            unit: "%",
            ref_low: new Prisma.Decimal(4),
            ref_high: new Prisma.Decimal(5.6),
            value_in_canonical_unit: new Prisma.Decimal(5.4),
            comparable_unit: "%",
            is_comparable: true,
          },
        ],
      },
    },
  });

  // Past completed booking
  const pastScheduled = toDateWithTime(baseDate, -200, "09:00");
  const bookingPast = await prisma.booking.create({
    data: {
      patient_profile_id: patientProfileId,
      lab_profile_id: secondaryLab.profile.id,
      lab_test_id: secondaryTest.id,
      booking_type: BookingType.LabVisit,
      status: BookingStatus.Completed,
      scheduled_at: pastScheduled,
      total_price_egp: secondaryTest.price_egp,
      payment_method: PaymentMethod.CashLabVisit,
      payment_status: PaymentStatus.Paid,
      payment_reference: "SEED-HISTORY-LAB",
      payment_paid_at: pastScheduled,
    },
  });

  await prisma.bookingStatusEvent.createMany({
    data: [
      { booking_id: bookingPast.id, status: BookingStatus.Pending, note: "Booking created", actor_user_id: patientUser.id },
      { booking_id: bookingPast.id, status: BookingStatus.Confirmed, note: "Lab confirmed", actor_user_id: secondaryLab.profile.user_id },
      { booking_id: bookingPast.id, status: BookingStatus.Completed, note: "Visit completed", actor_user_id: secondaryLab.profile.user_id },
    ],
  });

  await prisma.resultFile.create({
    data: {
      booking_id: bookingPast.id,
      status: ResultStatus.Delivered,
      file_name: "follow-up-metabolic.pdf",
      file_url: samplePdfUrl,
      mime_type: "application/pdf",
      size_bytes: 198_000,
      uploaded_by_user_id: secondaryLab.profile.user_id,
    },
  });

  await prisma.resultSummary.create({
    data: {
      booking_id: bookingPast.id,
      summary: "Follow-up chemistry: glucose slightly elevated; recommend dietary review.",
    },
  });

  await prisma.resultPanel.create({
    data: {
      booking_id: bookingPast.id,
      name: "Chemistry",
      test_date: addMinutes(pastScheduled, 60 * 6),
      sort_order: 0,
      observations: {
        create: [
          {
            canonical_marker_id: glucoseMarker.id,
            raw_name: "Glucose",
            value_numeric: new Prisma.Decimal("5.4"),
            unit: "mmol/L",
            ref_low: new Prisma.Decimal("3.9"),
            ref_high: new Prisma.Decimal("5.5"),
            value_in_canonical_unit: new Prisma.Decimal("5.4").mul(new Prisma.Decimal(18)),
            comparable_unit: "mg/dL",
            is_comparable: true,
            comparability_note: "Converted from mmol/L to mg/dL.",
          },
        ],
      },
    },
  });

  // Cancelled booking
  const failedScheduled = toDateWithTime(baseDate, -5, "11:00");
  const failedBooking = await prisma.booking.create({
    data: {
      patient_profile_id: patientProfileId,
      lab_profile_id: primaryLab.profile.id,
      lab_test_id: primaryTest.id,
      booking_type: BookingType.LabVisit,
      status: BookingStatus.Cancelled,
      scheduled_at: failedScheduled,
      total_price_egp: primaryTest.price_egp,
      payment_method: PaymentMethod.Online,
      payment_status: PaymentStatus.Failed,
      payment_reference: "SEED-FAILED-PAYMOB",
    },
  });

  await prisma.bookingStatusEvent.createMany({
    data: [
      { booking_id: failedBooking.id, status: BookingStatus.Pending, note: "Booking initiated", actor_user_id: patientUser.id },
      { booking_id: failedBooking.id, status: BookingStatus.Cancelled, note: "Payment failed, booking cancelled automatically", actor_user_id: null },
    ],
  });

  // ── Past bookings for review patients ───────────────────────────────────
  // Helper to find a lab by name and get its first test
  async function getLabAndTest(labName: string) {
    const lp = labProfiles.find((l) => l.data.name === labName);
    if (!lp) return null;
    const test = await prisma.labTest.findFirst({ where: { lab_profile_id: lp.profile.id } });
    return test ? { lab: lp, test } : null;
  }

  // Ahmed: Al Borg Cairo (5★), El Mokhtabar (4★), Canal Medical Lab (4★)
  const ahmedPatientId = ahmedUser.patient_profile!.id;
  const ahmedBookingsData = [
    { labName: "Al Borg Laboratories", offsetDays: -120, rating: 5, comment: "Outstanding service — phlebotomist was gentle and results arrived before the promised time. Highly recommend." },
    { labName: "El Mokhtabar", offsetDays: -80, rating: 4, comment: "Good lab, well-equipped. Wait time was a bit long but the staff were professional." },
    { labName: "Canal Medical Lab", offsetDays: -40, rating: 4, comment: "Convenient location in Ismailia. Friendly staff and clear results report." },
  ];

  for (const bData of ahmedBookingsData) {
    const entry = await getLabAndTest(bData.labName);
    if (!entry) continue;
    const scheduledAt = toDateWithTime(baseDate, bData.offsetDays, "10:00");
    const booking = await prisma.booking.create({
      data: {
        patient_profile_id: ahmedPatientId,
        lab_profile_id: entry.lab.profile.id,
        lab_test_id: entry.test.id,
        booking_type: BookingType.LabVisit,
        status: BookingStatus.Completed,
        scheduled_at: scheduledAt,
        total_price_egp: entry.test.price_egp,
        payment_method: PaymentMethod.CashLabVisit,
        payment_status: PaymentStatus.Paid,
        payment_reference: `SEED-AHMED-${bData.labName.slice(0, 5).toUpperCase()}`,
        payment_paid_at: scheduledAt,
      },
    });
    await prisma.resultFile.create({
      data: {
        booking_id: booking.id,
        status: ResultStatus.Delivered,
        file_name: `result-ahmed-${booking.id.slice(0, 6)}.pdf`,
        file_url: samplePdfUrl,
        mime_type: "application/pdf",
        size_bytes: 185_000,
        uploaded_by_user_id: entry.lab.profile.user_id,
      },
    });
    await prisma.review.create({
      data: {
        booking_id: booking.id,
        patient_profile_id: ahmedPatientId,
        lab_profile_id: entry.lab.profile.id,
        rating: bData.rating,
        comment: bData.comment,
        status: ReviewStatus.Published,
      },
    });
  }

  // Fatima: Cairo Scan (5★), Al Borg Alexandria (3★), Delta Medical Lab (4★)
  const fatimaPatientId = fatimaUser.patient_profile!.id;
  const fatimaBookingsData = [
    { labName: "Cairo Scan Medical Lab", offsetDays: -95, rating: 5, comment: "Excellent modern facilities. The automated machines and fast results were impressive." },
    { labName: "Al Borg Alexandria", offsetDays: -55, rating: 3, comment: "Results came late by about 12 hours. The lab itself was clean but the communication could be better." },
    { labName: "Delta Medical Lab", offsetDays: -25, rating: 4, comment: "Very professional team in Mansoura. Good value for the comprehensive panel." },
  ];

  for (const bData of fatimaBookingsData) {
    const entry = await getLabAndTest(bData.labName);
    if (!entry) continue;
    const scheduledAt = toDateWithTime(baseDate, bData.offsetDays, "09:00");
    const booking = await prisma.booking.create({
      data: {
        patient_profile_id: fatimaPatientId,
        lab_profile_id: entry.lab.profile.id,
        lab_test_id: entry.test.id,
        booking_type: BookingType.LabVisit,
        status: BookingStatus.Completed,
        scheduled_at: scheduledAt,
        total_price_egp: entry.test.price_egp,
        payment_method: PaymentMethod.CashLabVisit,
        payment_status: PaymentStatus.Paid,
        payment_reference: `SEED-FATIMA-${bData.labName.slice(0, 5).toUpperCase()}`,
        payment_paid_at: scheduledAt,
      },
    });
    await prisma.resultFile.create({
      data: {
        booking_id: booking.id,
        status: ResultStatus.Delivered,
        file_name: `result-fatima-${booking.id.slice(0, 6)}.pdf`,
        file_url: samplePdfUrl,
        mime_type: "application/pdf",
        size_bytes: 192_000,
        uploaded_by_user_id: entry.lab.profile.user_id,
      },
    });
    await prisma.review.create({
      data: {
        booking_id: booking.id,
        patient_profile_id: fatimaPatientId,
        lab_profile_id: entry.lab.profile.id,
        rating: bData.rating,
        comment: bData.comment,
        status: ReviewStatus.Published,
      },
    });
  }

  // Omar: Alfa Laboratories (5★), Pyramids Medical Lab (4★)
  const omarPatientId = omarUser.patient_profile!.id;
  const omarBookingsData = [
    { labName: "Alfa Laboratories", offsetDays: -110, rating: 5, comment: "By far the best lab experience I've had. JCI-accredited quality — results delivered to the app in 5 hours." },
    { labName: "Pyramids Medical Lab", offsetDays: -60, rating: 4, comment: "Great experience in Dokki. Home collection was smooth and the phlebotomist was on time." },
  ];

  for (const bData of omarBookingsData) {
    const entry = await getLabAndTest(bData.labName);
    if (!entry) continue;
    const scheduledAt = toDateWithTime(baseDate, bData.offsetDays, "08:00");
    const booking = await prisma.booking.create({
      data: {
        patient_profile_id: omarPatientId,
        lab_profile_id: entry.lab.profile.id,
        lab_test_id: entry.test.id,
        booking_type: BookingType.LabVisit,
        status: BookingStatus.Completed,
        scheduled_at: scheduledAt,
        total_price_egp: entry.test.price_egp,
        payment_method: PaymentMethod.CashLabVisit,
        payment_status: PaymentStatus.Paid,
        payment_reference: `SEED-OMAR-${bData.labName.slice(0, 5).toUpperCase()}`,
        payment_paid_at: scheduledAt,
      },
    });
    await prisma.resultFile.create({
      data: {
        booking_id: booking.id,
        status: ResultStatus.Delivered,
        file_name: `result-omar-${booking.id.slice(0, 6)}.pdf`,
        file_url: samplePdfUrl,
        mime_type: "application/pdf",
        size_bytes: 175_000,
        uploaded_by_user_id: entry.lab.profile.user_id,
      },
    });
    await prisma.review.create({
      data: {
        booking_id: booking.id,
        patient_profile_id: omarPatientId,
        lab_profile_id: entry.lab.profile.id,
        rating: bData.rating,
        comment: bData.comment,
        status: ReviewStatus.Published,
      },
    });
  }

  // Mazen's review on bookingOne
  await prisma.review.create({
    data: {
      booking_id: bookingOne.id,
      patient_profile_id: patientProfileId,
      lab_profile_id: primaryLab.profile.id,
      rating: 5,
      comment: "Fast service and very clear results report. The home test kit option was a great convenience.",
      status: ReviewStatus.Published,
    },
  });

  // ── Recompute rating_average / review_count from actual reviews ─────────
  for (const { profile } of labProfiles) {
    const agg = await prisma.review.aggregate({
      where: { lab_profile_id: profile.id, status: ReviewStatus.Published },
      _avg: { rating: true },
      _count: { _all: true },
    });
    await prisma.labProfile.update({
      where: { id: profile.id },
      data: {
        rating_average: agg._avg.rating ?? null,
        review_count: agg._count._all,
      },
    });
  }

  // ── FAQ entries ─────────────────────────────────────────────────────────
  await prisma.faqEntry.createMany({
    data: faqEntries.map((e) => ({
      question: e.question,
      answer: e.answer,
      category: e.category,
      tags: e.tags,
      is_active: true,
    })),
  });

  console.log(`✓ Seeded ${labProfiles.length} labs across ${new Set(labProfiles.map((l) => l.data.city)).size} cities`);
  console.log(`✓ Seeded ${testCatalog.length} tests in catalog`);
  console.log(`✓ Seeded ${scheduleSlots.length} schedule slots (7 days)`);
}

function buildMinimalPdf(): Buffer {
  const header = Buffer.from('%PDF-1.4\n');
  const obj1 = Buffer.from('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n');
  const obj2 = Buffer.from('2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n');
  const obj3 = Buffer.from('3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] >>\nendobj\n');

  const off1 = header.length;
  const off2 = off1 + obj1.length;
  const off3 = off2 + obj2.length;
  const xrefOffset = off3 + obj3.length;

  const xref = Buffer.from(
    'xref\n' +
    '0 4\n' +
    '0000000000 65535 f \r\n' +
    `${String(off1).padStart(10, '0')} 00000 n \r\n` +
    `${String(off2).padStart(10, '0')} 00000 n \r\n` +
    `${String(off3).padStart(10, '0')} 00000 n \r\n` +
    'trailer\n<< /Size 4 /Root 1 0 R >>\nstartxref\n' +
    `${xrefOffset}\n` +
    '%%EOF\n'
  );

  return Buffer.concat([header, obj1, obj2, obj3, xref]);
}

function ensureSamplePdf(): string {
  const uploadsDir = path.resolve(process.cwd(), 'uploads', 'results');
  fs.mkdirSync(uploadsDir, { recursive: true });
  const filePath = path.join(uploadsDir, 'sample-result.pdf');
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, buildMinimalPdf());
  }
  return '/results/files/sample-result.pdf';
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
