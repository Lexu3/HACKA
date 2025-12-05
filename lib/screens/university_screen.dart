import 'package:flutter/material.dart';

class Direction {
  final String name;
  final String level;
  final int? grantsCount;

  const Direction({required this.name, required this.level, this.grantsCount});
}

class University {
  final String name;
  final String code;
  final String city;
  final String? logo;
  final String? img;

  final bool hasInternational;
  final String? shortInfo;
  final bool hasDormitory;
  final bool hasMilitaryDepartment;
  final List<Direction> directions;
  final int? price;

  const University({
    required this.name,
    required this.code,
    required this.city,
    this.logo,
    this.img,
    this.hasInternational = false,
    this.shortInfo,
    this.hasDormitory = false,
    this.hasMilitaryDepartment = false,
    this.directions = const [],
    this.price,
  });
}

class UniversityScreen extends StatelessWidget {
  final University university;

  const UniversityScreen({super.key, required this.university});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Стрелка назад
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (university.logo != null)
                      Image.asset(
                        university.logo!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        university.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------- IMAGE ----------------
              if (university.img != null)
                Image.asset(
                  university.img!,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 12),

              // ---------------- BASIC INFO ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Город: ${university.city}", style: const TextStyle(fontSize: 16)),
                    Text(
                        "Международное сотрудничество: ${university.hasInternational ? "Да" : "Нет"}",
                        style: const TextStyle(fontSize: 16)),
                    Text("Общежитие: ${university.hasDormitory ? "Есть" : "Нет"}",
                        style: const TextStyle(fontSize: 16)),
                    Text("Военная кафедра: ${university.hasMilitaryDepartment ? "Есть" : "Нет"}",
                        style: const TextStyle(fontSize: 16)),
                    Text("Цена: ${university.price ?? '-'} KZT",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---------------- DIRECTIONS ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const Text(
                  "Направления:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: university.directions
                        .map(
                          (d) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "${d.name} (${d.level})",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ---------------- SHORT INFO ----------------
              if (university.shortInfo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      university.shortInfo!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
