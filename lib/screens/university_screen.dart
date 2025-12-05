import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UniversityScreen extends StatelessWidget {
  final String code;

  const UniversityScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('universities').doc(code);
    return Scaffold(
      appBar: AppBar(title: const Text('University')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!.data();
          if (data == null) return const Center(child: Text('Not found'));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] ?? code, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(data['city'] ?? '', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 16),
                Text(data['shortInfo'] ?? '', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text('Направления:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: docRef.collection('directions').snapshots(),
                    builder: (context, dsnap) {
                      if (dsnap.hasError) return Center(child: Text('Error: ${dsnap.error}'));
                      if (!dsnap.hasData) return const Center(child: CircularProgressIndicator());
                      final dirs = dsnap.data!.docs;
                      if (dirs.isEmpty) return const Text('Нет направлений');
                      return ListView.builder(
                        itemCount: dirs.length,
                        itemBuilder: (context, i) {
                          final d = dirs[i].data();
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(d['name'] ?? ''),
                              subtitle: Text('${d['level'] ?? ''} • ${d['entSubjects']?.join(', ') ?? ''}'),
                              trailing: Text(d['passScore']?.toString() ?? ''),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
