import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../unis/example.dart' show uploadUniversities, clearAndUploadUniversities;
import '../unis/info.dart';
import 'universities_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
              color: Colors.blueAccent.withOpacity(0.2),
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
          const Text(
            "ivan.petrov@email.com",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
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
          
          // Список избранных — динамический
          ValueListenableBuilder<Set<String>>(
            valueListenable: FavoritesService.instance,
            builder: (context, favs, _) {
              final favCodes = favs.toList();
              if (favCodes.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Нет избранных университетов'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favCodes.length,
                itemBuilder: (context, index) {
                  final code = favCodes[index];
                  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance.collection('universities').doc(code).get(),
                    builder: (context, snap) {
                      String name = code;
                      if (snap.connectionState == ConnectionState.done && snap.hasData && snap.data!.exists) {
                        final data = snap.data!.data();
                        if (data != null && data['name'] is String) name = data['name'] as String;
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.school, color: Colors.blueAccent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () {
                                  FavoritesService.instance.toggle(code);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  // Ask the user whether to clear existing docs first
                  final choice = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Upload universities'),
                      content: const Text('Do you want to clear existing universities first?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, 'no'), child: const Text('No (overwrite by code)')),
                        ElevatedButton(onPressed: () => Navigator.pop(ctx, 'yes'), child: const Text('Yes (clear then upload)')),
                      ],
                    ),
                  );

                  if (choice == null || choice == 'cancel') return;

                  try {
                    if (choice == 'yes') {
                      await clearAndUploadUniversities();
                    } else {
                      await uploadUniversities();
                    }
                    if (!mounted) return;
                    messenger.showSnackBar(const SnackBar(content: Text('Upload complete')));
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
                  }
                },
                child: const Text('Upload sample data'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UniversitiesFirestore()),
                  );
                },
                child: const Text('View live universities'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
