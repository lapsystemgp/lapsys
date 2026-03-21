export interface Lab {
  id: number;
  name: string;
  rating: number;
  reviews: number;
  distance: number;
  price: number;
  homeCollection: boolean;
  timeSlots: string[];
  address: string;
  accreditation: string;
  turnaroundTime: string;
  image: string;
  testsAvailable: number;
}

export interface LabTest {
  id: number;
  name: string;
  category: string;
  price: number;
  description: string;
  preparation: string;
  turnaround: string;
  parameters: number;
}

export const labs: Lab[] = [
  {
    id: 1,
    name: "Alaf labs",
    rating: 4.8,
    reviews: 342,
    distance: 1.2,
    price: 450,
    homeCollection: true,
    timeSlots: ["9:00 AM", "11:00 AM", "2:00 PM", "4:00 PM"],
    address: "12 Nile Corniche, Downtown Cairo",
    accreditation: "NABL, CAP",
    turnaroundTime: "24 hours",
    image: "🏥",
    testsAvailable: 45,
  },
  {
    id: 2,
    name: "Al mokhtabar",
    rating: 4.6,
    reviews: 218,
    distance: 2.5,
    price: 380,
    homeCollection: true,
    timeSlots: ["8:00 AM", "10:00 AM", "1:00 PM", "3:00 PM"],
    address: "45 Tahrir Street, Garden City, Cairo",
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    image: "🔬",
    testsAvailable: 38,
  },
  {
    id: 3,
    name: "Daman labs",
    rating: 4.9,
    reviews: 567,
    distance: 3.8,
    price: 520,
    homeCollection: true,
    timeSlots: ["9:30 AM", "12:00 PM", "3:00 PM", "5:00 PM"],
    address: "78 El Merghany Street, Heliopolis, Cairo",
    accreditation: "NABL, CAP, ISO",
    turnaroundTime: "12 hours",
    image: "⚕️",
    testsAvailable: 52,
  },
  {
    id: 4,
    name: "Makka lab",
    rating: 4.3,
    reviews: 156,
    distance: 0.8,
    price: 350,
    homeCollection: false,
    timeSlots: ["8:30 AM", "11:30 AM", "2:30 PM"],
    address: "32 Ramses Street, Downtown Cairo",
    accreditation: "NABL",
    turnaroundTime: "48 hours",
    image: "💉",
    testsAvailable: 30,
  },
  {
    id: 5,
    name: "Future lab",
    rating: 4.7,
    reviews: 423,
    distance: 4.2,
    price: 580,
    homeCollection: true,
    timeSlots: ["7:00 AM", "10:00 AM", "1:00 PM", "4:00 PM", "6:00 PM"],
    address: "55 Road 9, Maadi, Cairo",
    accreditation: "NABL, CAP, ISO, JCI",
    turnaroundTime: "6 hours",
    image: "🏨",
    testsAvailable: 65,
  },
  {
    id: 6,
    name: "Canal labs",
    rating: 4.5,
    reviews: 289,
    distance: 2.1,
    price: 420,
    homeCollection: true,
    timeSlots: ["9:00 AM", "12:00 PM", "3:00 PM", "5:00 PM"],
    address: "89 Syria Street, Mohandessin, Giza",
    accreditation: "NABL, CAP",
    turnaroundTime: "24 hours",
    image: "🩺",
    testsAvailable: 42,
  },
];

export const labTests: LabTest[] = [
  {
    id: 1,
    name: "Complete Blood Count (CBC)",
    category: "Blood Tests",
    price: 450,
    description: "Measures red blood cells, white blood cells, hemoglobin, and platelets",
    preparation: "No fasting required",
    turnaround: "24 hours",
    parameters: 18,
  },
  {
    id: 2,
    name: "Lipid Profile",
    category: "Blood Tests",
    price: 650,
    description: "Tests for cholesterol levels and heart disease risk",
    preparation: "Fasting for 9-12 hours required",
    turnaround: "24 hours",
    parameters: 8,
  },
  {
    id: 3,
    name: "Thyroid Panel (TSH, T3, T4)",
    category: "Hormone Tests",
    price: 580,
    description: "Complete thyroid function assessment",
    preparation: "No fasting required, best taken in morning",
    turnaround: "48 hours",
    parameters: 3,
  },
  {
    id: 4,
    name: "Liver Function Test (LFT)",
    category: "Blood Tests",
    price: 520,
    description: "Evaluates liver health and function",
    preparation: "Fasting for 8-12 hours recommended",
    turnaround: "24 hours",
    parameters: 12,
  },
  {
    id: 5,
    name: "Kidney Function Test",
    category: "Blood Tests",
    price: 490,
    description: "Assesses kidney health and function",
    preparation: "No fasting required",
    turnaround: "24 hours",
    parameters: 10,
  },
  {
    id: 6,
    name: "HbA1c (Diabetes)",
    category: "Diabetes",
    price: 420,
    description: "Measures average blood sugar over 3 months",
    preparation: "No fasting required",
    turnaround: "24 hours",
    parameters: 1,
  },
  {
    id: 7,
    name: "Vitamin D Test",
    category: "Vitamin Tests",
    price: 850,
    description: "Measures Vitamin D levels in blood",
    preparation: "No fasting required",
    turnaround: "48 hours",
    parameters: 1,
  },
  {
    id: 8,
    name: "Vitamin B12",
    category: "Vitamin Tests",
    price: 680,
    description: "Tests for Vitamin B12 deficiency",
    preparation: "No fasting required",
    turnaround: "48 hours",
    parameters: 1,
  },
];

export const getLabById = (id: number) => labs.find((lab) => lab.id === id);
export const getTestById = (id: number) => labTests.find((test) => test.id === id);
