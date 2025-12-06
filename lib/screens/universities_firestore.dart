import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class UniversitiesFirestore extends StatelessWidget {
  const UniversitiesFirestore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coll = FirebaseFirestore.instance.collection('universities');
    return Scaffold(
      appBar: AppBar(title: const Text('Live Universities')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: coll.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No universities found'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final code = data['code']?.toString() ?? docs[index].id;
              final name = data['name']?.toString() ?? 'No name';
              final city = data['city']?.toString() ?? '';
              final shortInfo = data['shortInfo']?.toString();
              final price = data['price'];

              final isFav = FavoritesService.instance.isFavorite(code);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                    leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, color: Colors.blueAccent),
                  ),
                  title: Text(name),
                  subtitle: Text('$city${shortInfo != null ? ' — $shortInfo' : ''}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (price != null) Text('${price.toString()} ₸'),
                    IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                      onPressed: () => FavoritesService.instance.toggle(code),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
