import 'package:flutter/material.dart';
import 'university_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DataHub Вузы Казахстана',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ЧАТБОТ БЛОК
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue.shade50,
              ),
              child: const Center(
                child: Text(
                  'Чат‑бот',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ФИЛЬТРЫ ВУЗОВ
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: true,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('Алматы'),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('Астана'),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('Технические'),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // СПИСОК ВУЗОВ
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildUniversityCard(context, 'Satbayev University', 'Алматы'),
                _buildUniversityCard(context, 'KazNU им. Аль-Фараби', 'Алматы'),
                _buildUniversityCard(context, 'ENU им. Гумилева', 'Астана'),
                _buildUniversityCard(context, 'KBTU', 'Алматы'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversityCard(BuildContext context, String name, String city) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UniversityScreen(name: name, city: city)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(city, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
