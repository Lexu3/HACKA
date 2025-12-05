import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nova/unis/info.dart';
import 'package:nova/unis/example.dart';
import 'package:flutter/services.dart';
import 'university_screen.dart';

class MainScreen extends StatefulWidget {
  final String lang;
  const MainScreen({super.key, required this.lang});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, dynamic> texts = {};

  String? city;
  String? education;
  String? direction;
  String? reality;
  bool intlYes = false;
  bool intlNo = false;
  bool militaryYes = false;
  bool militaryNo = false;
  bool dormYes = false;
  bool dormNo = false;

  List<University> filteredUniversities = exampleUniversities;

  final cityController = TextEditingController();
  final educationController = TextEditingController();
  final directionController = TextEditingController();
  final realityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTranslations();
  }

  Future<void> loadTranslations() async {
    final data = await rootBundle.loadString('assets/translations.json');
    setState(() {
      texts = jsonDecode(data);
    });
  }

  void applyFilters() {
    setState(() {
      filteredUniversities = exampleUniversities.where((u) {
        if (cityController.text.isNotEmpty && u.city != cityController.text) return false;
        if (educationController.text.isNotEmpty &&
            !u.directions.any((d) => d.level == educationController.text)) return false;
        if (directionController.text.isNotEmpty &&
            !u.directions.any((d) => d.name == directionController.text)) return false;
        if (realityController.text.isNotEmpty &&
            realityController.text.contains("Грант") &&
            u.directions.every((d) => d.grantsCount == null || d.grantsCount == 0)) return false;

        if (intlYes && !u.hasInternational) return false;
        if (intlNo && u.hasInternational) return false;

        if (militaryYes && !u.hasMilitaryDepartment) return false;
        if (militaryNo && u.hasMilitaryDepartment) return false;

        if (dormYes && !u.hasDormitory) return false;
        if (dormNo && u.hasDormitory) return false;

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
  // если тексты ещё не подгрузились, показываем прогресс
  if (texts.isEmpty) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  final t = texts[widget.lang]!;

  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
          _buildFiltersWidget(t),
          Expanded(child: _buildUniversityList(t)),
        ],
      ),
    ),
  );
}


  Widget _buildFiltersWidget(Map t) {
    return ExpansionTile(
      title: Text(t["filters"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _field(t["city"], cityController, cities)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(t["education"], educationController, educations)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field(t["direction"], directionController, directionsList)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(t["reality"], realityController, realities)),
                ],
              ),
              const SizedBox(height: 12),
              _checkRow(t["intl"], intlYes, intlNo, (v) { intlYes = v; intlNo = false; }, (v) { intlNo = v; intlYes = false; }, t),
              _checkRow(t["military"], militaryYes, militaryNo, (v) { militaryYes = v; militaryNo = false; }, (v) { militaryNo = v; militaryYes = false; }, t),
              _checkRow(t["dorm"], dormYes, dormNo, (v) { dormYes = v; dormNo = false; }, (v) { dormNo = v; dormYes = false; }, t),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: applyFilters,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  child: Text(t["find"], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _checkRow(String title, bool yes, bool no, Function(bool) setYes, Function(bool) setNo, Map t) {
    return Row(
      children: [
        Text("$title:", style: const TextStyle(fontSize: 16)),
        Checkbox(value: yes, onChanged: (v) => setState(() => setYes(v!))),
        Text(t["yes"]),
        Checkbox(value: no, onChanged: (v) => setState(() => setNo(v!))),
        Text(t["no"]),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (v) {
            return items.where((o) => o.toLowerCase().contains(v.text.toLowerCase()));
          },
          onSelected: (s) => controller.text = s,
          fieldViewBuilder: (c, textController, node, _) {
            textController.text = controller.text;
            return TextField(
              controller: textController,
              focusNode: node,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) => controller.text = v,
            );
          },
        ),
      ],
    );
  }

  Widget _buildUniversityList(Map t) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredUniversities.length,
      itemBuilder: (_, i) {
        final u = filteredUniversities[i];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UniversityScreen(name: u.name, city: u.city),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    color: Colors.blue.shade100,
                    child: u.logo != null ? Image.network(u.logo!, fit: BoxFit.cover) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text("${u.city} • ${u.shortInfo ?? ''}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("${t["price"]}: ${u.price ?? '-'} KZT", style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("${t["stip"]}: ${u.directions.map((d) => d.grantsCount).where((c) => c != null).join(', ')}", style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          "${t["intl_full"]}: ${u.hasInternational ? t["yes"] : t["no"]} • "
                          "${t["mil_full"]}: ${u.hasMilitaryDepartment ? t["yes"] : t["no"]} • "
                          "${t["dorm_full"]}: ${u.hasDormitory ? t["yes"] : t["no"]}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
