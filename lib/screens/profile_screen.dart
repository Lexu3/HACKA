import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../theme.dart';
import '../services/favorites_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/floating_chat.dart';
import 'university_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildProfileInfo(),
                const SizedBox(height: 24),
                _buildFavorites(context),
              ],
            ),
          ),
          const FloatingChatButton(),
        ],
      ),
    );
  }

  // ---------------------- HEADER ----------------------
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 28),
          ),
          const Text(
            "Профиль",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  // -------------------- ПРОФИЛЬ INFO --------------------
  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Аватар
          Container(
            width: 100,
            height: 100,
              decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withAlpha((0.2 * 255).round()),
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.blueAccent),
          ),
          const SizedBox(height: 16),
          
          // Имя
          const Text(
            "Иван Петров",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Email
            Text(
              "ivan.petrov@email.com",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F6B4A),
              ),
            ),
          const SizedBox(height: 24),
          
          // Кнопка редактирования
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            onPressed: () {},
            child: const Text(
              "Редактировать профиль",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- ИЗБРАННЫЕ --------------------
  Widget _buildFavorites(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Избранные университеты",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Two-column layout: left = universities, right = directions
          ValueListenableBuilder<Set<String>>(
            valueListenable: FavoritesService.instance,
            builder: (context, favs, _) {
              final favCodes = favs.toList();
              return ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesService.instance.directionFavorites,
                builder: (context, dirFavs, __) {
                  // Parse direction keys into pairs (uniCode, directionName)
                  final dirPairs = dirFavs.map((k) {
                    final parts = k.split('|');
                    final uni = parts.isNotEmpty ? parts.first : '';
                    final dir = parts.length > 1 ? parts.sublist(1).join('|') : '';
                    return MapEntry(uni, dir);
                  }).toList();

                  // Collect unique university codes we need names for
                  final neededCodes = <String>{...favCodes};
                  neededCodes.addAll(dirPairs.map((e) => e.key));

                  if (neededCodes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Нет избранных университетов или направлений'),
                    );
                  }

                  // Fetch all needed university docs once
                  return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                    future: Future.wait(neededCodes.map((c) => FirebaseFirestore.instance.collection('universities').doc(c).get())),
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data ?? [];
                      final names = <String, String>{};
                      for (final d in docs) {
                        if (d.exists) {
                          final data = d.data();
                          names[d.id] = (data != null && data['name'] is String) ? data['name'] as String : d.id;
                        }
                      }

                      return SizedBox(
                        height: 320,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column: favorite universities (half width)
                            Expanded(
                              flex: 1,
                              child: ListView.builder(
                                itemCount: favCodes.length,
                                itemBuilder: (context, i) {
                                  final code = favCodes[i];
                                  final name = names[code] ?? code;
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => UniversityScreen(code: code)),
                                      );
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.blueAccent.withAlpha((0.2 * 255).round()),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.school, color: Colors.blueAccent),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(FavoritesService.instance.isFavorite(code) ? Icons.favorite : Icons.favorite_border, color: FavoritesService.instance.isFavorite(code) ? Colors.red : null),
                                              onPressed: () => FavoritesService.instance.toggle(code),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Right column: favorite directions (half width)
                            Expanded(
                              flex: 1,
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Избранные направления', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: dirPairs.length,
                                          itemBuilder: (context, j) {
                                            final pair = dirPairs[j];
                                            final uniCode = pair.key;
                                            final dirName = pair.value;
                                            final uniName = names[uniCode] ?? uniCode;
                                            final scoreMatch = RegExp(r"\b(\d{3})\b").firstMatch(dirName);
                                            final score = scoreMatch?.group(1);
                                            final key = '$uniCode|$dirName';
                                            final isDirFav = FavoritesService.instance.directionFavorites.value.contains(key);
                                            return Card(
                                              margin: const EdgeInsets.only(bottom: 8.0),
                                              child: InkWell(
                                                onTap: () {
                                                  // Navigate to the university page
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => UniversityScreen(code: uniCode)),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text('$uniName — $dirName', style: const TextStyle(fontSize: 13)),
                                                            if (score != null) Text('баллы ЕНТ: $score', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(isDirFav ? Icons.favorite : Icons.favorite_border, color: isDirFav ? Colors.red : null),
                                                        onPressed: () => FavoritesService.instance.toggleDirection(uniCode, dirName),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
