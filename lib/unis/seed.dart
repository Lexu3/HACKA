import 'info.dart';

// Seed data used only by the uploader. This file is not imported by the app UI.
final List<University> seedUniversities = [
  University(
    name: "Satbayev University",
    code: "SU01",
    city: "Алматы",
    logo: null,
    hasInternational: true,
    shortInfo: "Технический университет Алматы",
    hasDormitory: true,
    hasMilitaryDepartment: false,
    price: 1000000,
    directions: [
      Direction(name: "IT", level: "Бакалавр", grantsCount: 5, entSubjects: ["Math", "Physics"], passScore: 210),
      Direction(name: "Инженерия", level: "Бакалавр", grantsCount: 3, entSubjects: ["Physics"], passScore: 195),
    ],
  ),
  University(
    name: "KazNU им. Аль-Фараби",
    code: "KN01",
    city: "Алматы",
    shortInfo: "Главный университет страны",
    hasDormitory: true,
    hasMilitaryDepartment: true,
    directions: [
      Direction(name: "Экономика", level: "Бакалавр", grantsCount: 2, entSubjects: ["Math", "Economics"], passScore: 185),
    ],
    price: 900000,
  ),
  University(
    name: "ENU им. Гумилева",
    code: "ENU01",
    city: "Астана",
    shortInfo: "Современный университет Астаны",
    hasDormitory: true,
    hasMilitaryDepartment: false,
    directions: [
      Direction(name: "Педагогика", level: "Бакалавр", grantsCount: 4, entSubjects: ["History", "Kazakh language"], passScore: 170),
    ],
    price: 850000,
  ),
  University(
    name: "Nazarbayev University",
    code: "NU01",
    city: "Астана",
    shortInfo: "Research-focused national university",
    hasDormitory: true,
    hasMilitaryDepartment: false,
    directions: [
      Direction(name: "Computer Science", level: "Бакалавр", grantsCount: 6, entSubjects: ["Math", "Informatics"], passScore: 240),
      Direction(name: "Engineering", level: "Бакалавр", grantsCount: 3, entSubjects: ["Physics", "Math"], passScore: 220),
    ],
    price: 1500000,
  ),
  University(
    name: "Kazakh-British Technical University",
    code: "KBTU01",
    city: "Алматы",
    shortInfo: "Technical and business programs with international ties",
    hasDormitory: true,
    hasMilitaryDepartment: false,
    directions: [
      Direction(name: "IT", level: "Бакалавр", grantsCount: 4, entSubjects: ["Math", "Informatics"], passScore: 200),
      Direction(name: "Business", level: "Бакалавр", grantsCount: 2, entSubjects: ["Economics"], passScore: 180),
    ],
    price: 1100000,
  ),
  University(
    name: "NARXOZ University",
    code: "NARX01",
    city: "Алматы",
    shortInfo: "Economics and management focused university",
    hasDormitory: false,
    hasMilitaryDepartment: false,
    directions: [
      Direction(name: "Economics", level: "Бакалавр", grantsCount: 3, entSubjects: ["Math", "Economics"], passScore: 175),
      Direction(name: "Finance", level: "Магистратура", grantsCount: 1, entSubjects: ["Finance"], passScore: 160),
    ],
    price: 700000,
  ),
  University(
    name: "Atyrau State University",
    code: "ASU01",
    city: "Атырау",
    shortInfo: "Regional university with strong engineering programs",
    hasDormitory: true,
    hasMilitaryDepartment: false,
    directions: [
      Direction(name: "Oil and Gas Engineering", level: "Бакалавр", grantsCount: 2, entSubjects: ["Chemistry", "Physics"], passScore: 190),
      Direction(name: "Environmental Engineering", level: "Бакалавр", grantsCount: 1, entSubjects: ["Biology", "Chemistry"], passScore: 170),
    ],
    price: 650000,
  ),
];
