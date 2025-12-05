import 'info.dart';

final List<University> exampleUniversities = [
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
      Direction(name: "IT", level: "Бакалавр", grantsCount: 5),
      Direction(name: "Инженерия", level: "Бакалавр", grantsCount: 3),
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
      Direction(name: "Экономика", level: "Бакалавр", grantsCount: 2),
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
      Direction(name: "Педагогика", level: "Бакалавр", grantsCount: 4),
    ],
    price: 850000,
  ),
];
