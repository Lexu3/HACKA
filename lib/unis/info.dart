class University {
  final String name;
  final String code;
  final String city;
  final String? logo;
  final bool hasInternational;
  final String? shortInfo;
  final bool hasDormitory;
  final bool hasMilitaryDepartment;
  final List<Direction> directions;
  final int? price;
  final bool isFavorite;

  const University({
    required this.name,
    required this.code,
    required this.city,
    this.logo,
    this.hasInternational = false,
    this.shortInfo,
    this.hasDormitory = false,
    this.hasMilitaryDepartment = false,
    this.directions = const [],
    this.price,
    this.isFavorite = false,
  });

  University copyWith({bool? isFavorite}) {
    return University(
      name: name,
      code: code,
      city: city,
      logo: logo,
      hasInternational: hasInternational,
      shortInfo: shortInfo,
      hasDormitory: hasDormitory,
      hasMilitaryDepartment: hasMilitaryDepartment,
      directions: directions,
      price: price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class Direction {
  final String name;
  final String level;
  final String? description;
  final List<String>? entSubjects;
  final int? passScore;
  final int? grantsCount;

  const Direction({
    required this.name,
    required this.level,
    this.passScore,
    this.description,
    this.entSubjects,
    this.grantsCount,
  });
}

// ---------------- Категории для фильтров ----------------
const List<String> regions = ["Алматы", "Астана"];
const List<String> cities = ["Алматы", "Астана"];
const List<String> educations = ["Бакалавр", "Магистратура"];
const List<String> directionsList = ["IT", "Экономика", "Педагогика"];
const List<String> realities = ["Грант", "Платно"];
