import 'package:cloud_firestore/cloud_firestore.dart';
import 'info.dart'; // твои модели University и Direction

// расширения прямо здесь
extension UniversityMap on University {
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "code": code,
      "city": city,
      "logo": logo,
      "hasInternational": hasInternational,
      "shortInfo": shortInfo,
      "hasDormitory": hasDormitory,
      "hasMilitaryDepartment": hasMilitaryDepartment,
      "price": price,
      "directions": directions.map((d) => d.toMap()).toList(),
    };
  }
}

extension DirectionMap on Direction {
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "level": level,
      "grantsCount": grantsCount,
    };
  }
}

// твой список университетов
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

// Firestore
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> uploadUniversities() async {
  for (var uni in exampleUniversities) {
    await _firestore.collection('universities').doc(uni.code).set(uni.toMap());
    print("Added ${uni.name}");
  }
  print("Все университеты загружены!");
}

void main() async {
  await uploadUniversities();
}
