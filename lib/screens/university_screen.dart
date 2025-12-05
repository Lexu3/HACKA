import 'package:flutter/material.dart';

class UniversityScreen extends StatelessWidget {
  final String name;
  final String city;

  const UniversityScreen({super.key, required this.name, required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(city, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 16),
            const Text(
              'Информация о университете будет здесь...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
