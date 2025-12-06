import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nova/unis/info.dart';
import '../services/favorites_service.dart';
import 'package:flutter/services.dart';
import 'university_screen.dart';
import '../widgets/floating_chat.dart';

class MainScreen extends StatefulWidget {
  final String lang;
  const MainScreen({super.key, this.lang = 'ru'});

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

  List<Map<String, dynamic>> filteredUniversities = [];

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
    // Filters are applied on snapshots when building the list.
    setState(() {});
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
      child: Stack(
        children: [
          Column(
            children: [
              _buildFiltersWidget(t),
              Expanded(child: _buildUniversityList(t)),
            ],
          ),
          // Floating chat button
          const FloatingChatButton(),
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
    final coll = FirebaseFirestore.instance.collection('universities');
    Query query = coll;

    // Server-side filters (fast): city, education, direction, reality(hasGrant)
    if (cityController.text.isNotEmpty) {
      query = query.where('city', isEqualTo: cityController.text);
    }
    // Firestore allows only one array-contains/array-contains-any per query.
    // Use direction as the primary server-side filter (if provided) and
    // apply education filtering client-side to avoid the assertion.
    if (directionController.text.isNotEmpty) {
      query = query.where('directionNames', arrayContains: directionController.text);
    }
    if (realityController.text.isNotEmpty && realityController.text.contains('Грант')) {
      query = query.where('hasGrant', isEqualTo: true);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots().cast<QuerySnapshot<Map<String, dynamic>>>(),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;

        // Remaining boolean filters applied client-side. Also apply
        // education filter client-side because Firestore forbids multiple
        // array-contains filters in a single query.
        final items = docs.where((d) {
          final data = d.data();
          // educationLevels is stored as an array on the document.
          if (educationController.text.isNotEmpty) {
            final levels = (data['educationLevels'] as List<dynamic>?)?.cast<String>() ?? [];
            if (!levels.contains(educationController.text)) return false;
          }
          if (intlYes && (data['hasInternational'] != true)) return false;
          if (intlNo && (data['hasInternational'] == true)) return false;
          if (militaryYes && (data['hasMilitaryDepartment'] != true)) return false;
          if (militaryNo && (data['hasMilitaryDepartment'] == true)) return false;
          if (dormYes && (data['hasDormitory'] != true)) return false;
          if (dormNo && (data['hasDormitory'] == true)) return false;
          return true;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final doc = items[i];
            final data = doc.data();
            final name = data['name'] ?? doc.id;
            final city = data['city'] ?? '';
            final shortInfo = data['shortInfo'] ?? '';
            final price = data['price'];
            return ValueListenableBuilder<Set<String>>(
              valueListenable: FavoritesService.instance,
              builder: (context, favs, _) {
                final isFav = favs.contains(doc.id);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UniversityScreen(code: doc.id)),
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
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("$city • $shortInfo", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text("${t['price']}: ${price ?? '-'} KZT", style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  "${t['intl_full']}: ${data['hasInternational'] == true ? t['yes'] : t['no']} • "
                                  "${t['mil_full']}: ${data['hasMilitaryDepartment'] == true ? t['yes'] : t['no']} • "
                                  "${t['dorm_full']}: ${data['hasDormitory'] == true ? t['yes'] : t['no']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Directions column: show direction names with like buttons
                          Container(
                            width: 180,
                            padding: const EdgeInsets.only(left: 8),
                            child: ValueListenableBuilder<Set<String>>(
                              valueListenable: FavoritesService.instance.directionFavorites,
                              builder: (context, dirFavs, _) {
                                final directions = (data['directionNames'] as List<dynamic>?)?.cast<String>() ?? <String>[];
                                if (directions.isEmpty) return const SizedBox.shrink();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: directions.take(6).map((dir) {
                                    // detect 3-digit passing score
                                    final scoreMatch = RegExp(r"\b(\d{3})\b").firstMatch(dir);
                                    final score = scoreMatch?.group(1);
                                    final displayName = dir;
                                    final key = '${doc.id}|$dir';
                                    final isDirFav = dirFavs.contains(key);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(displayName, style: const TextStyle(fontSize: 12)),
                                                if (score != null)
                                                  Text('баллы ЕНТ: $score', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(isDirFav ? Icons.favorite : Icons.favorite_border, color: isDirFav ? Colors.red : null, size: 20),
                                            onPressed: () {
                                              FavoritesService.instance.toggleDirection(doc.id, dir);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                            onPressed: () {
                              FavoritesService.instance.toggle(doc.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
