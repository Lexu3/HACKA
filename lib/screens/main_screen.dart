import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'unis/info.dart';
import 'unis/examples.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? region;
  String? city;
  String? education;
  String? direction;
  String? reality;
  bool intlYes = false;
  bool intlNo = false;

  List<University> filteredUniversities = exampleUniversities;

  void applyFilters() {
    setState(() {
      filteredUniversities = exampleUniversities.where((u) {
        if (region != null && u.city != region) return false;
        if (city != null && u.city != city) return false;
        if (education != null &&
            !u.directions.any((d) => d.level == education)) return false;
        if (direction != null &&
            !u.directions.any((d) => d.name == direction)) return false;
        if (reality != null &&
            reality == "Грант" &&
            u.directions.every((d) => d.grantsCount == null || d.grantsCount == 0)) return false;
        if (intlYes && !u.hasInternational) return false;
        if (intlNo && u.hasInternational) return false;
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFiltersWidget(),
            Expanded(child: _buildUniversityGrid()),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.blueAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Telary", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Text("KZ / RU", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- FILTERS ----------------
  Widget _buildFiltersWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _drop("Область", region, regions, (v) => setState(() => region = v)),
          const SizedBox(height: 8),
          _drop("Город", city, cities, (v) => setState(() => city = v)),
          const SizedBox(height: 8),
          _drop("Уровень образования", education, educations, (v) => setState(() => education = v)),
          const SizedBox(height: 8),
          _drop("Направление", direction, directionsList, (v) => setState(() => direction = v)),
          const SizedBox(height: 8),
          _drop("Реалити", reality, realities, (v) => setState(() => reality = v)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Междунар. сотрудничество:", style: TextStyle(fontSize: 16)),
              Checkbox(value: intlYes, onChanged: (v) { setState(() { intlYes = v!; if (v) intlNo = false; }); }),
              const Text("Да"),
              Checkbox(value: intlNo, onChanged: (v) { setState(() { intlNo = v!; if (v) intlYes = false; }); }),
              const Text("Нет"),
            ],
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), backgroundColor: Colors.blueAccent),
              onPressed: applyFilters,
              child: const Text("НАЙТИ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drop(String title, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: InputBorder.none),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ---------------- UNIVERSITY GRID ----------------
  Widget _buildUniversityGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: filteredUniversities.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final u = filteredUniversities[index];
          return GestureDetector(
            onTap: () {
              // Переход на экран инфо о вузе
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: u.logo != null
                        ? Image.network(u.logo!, fit: BoxFit.cover, width: double.infinity)
                        : Container(color: Colors.blue.shade200, width: double.infinity),
                  ),
                  const SizedBox(height: 8),
                  Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("${u.city} • ${u.shortInfo ?? ''}", style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Text("Цена: ${u.price ?? '-'} KZT", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
