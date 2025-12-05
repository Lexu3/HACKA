import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'info.dart'; 
import 'seed.dart';

// расширения прямо здесь
extension UniversityMap on University {
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "code": code,
      "city": city,
      "logo": logo,
      "hasInternational": hasInternational,
      "shortInfo": shortInfo,
      "hasDormitory": hasDormitory,
      "hasMilitaryDepartment": hasMilitaryDepartment,
      "price": price,
      // Directions are stored in a subcollection `directions`.
    };
  }
}

extension DirectionMap on Direction {
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "level": level,
      "description": description,
      "entSubjects": entSubjects,
      "passScore": passScore,
      "grantsCount": grantsCount,
    };
  }
}

// The uploader uses seed data from `seed.dart` so the runtime app no longer
// depends on an in-code list of universities. `seedUniversities` is only
// imported by the uploader and not used by the UI.
final List<University> exampleUniversities = seedUniversities;

// Firestore
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> uploadUniversities() async {
  final coll = _firestore.collection('universities');
  for (var uni in exampleUniversities) {
    final docRef = coll.doc(uni.code);
    // Compute helper fields for fast filtering in Firestore
    final directionNames = uni.directions.map((d) => d.name).toSet().toList();
    final educationLevels = uni.directions.map((d) => d.level).toSet().toList();
    final hasGrant = uni.directions.any((d) => (d.grantsCount ?? 0) > 0);

    // Write university document without embedded directions, but with helper arrays
    await docRef.set({
      ...uni.toMap(),
      'directionNames': directionNames,
      'educationLevels': educationLevels,
      'hasGrant': hasGrant,
    });

    // Write each direction as a document in the subcollection
    final directionsColl = docRef.collection('directions');
    for (var dir in uni.directions) {
      // create an id-safe key from the direction name
      final rawId = dir.name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_').toLowerCase();
      final isOnlyUnderscores = rawId.replaceAll('_', '').isEmpty;
      try {
        if (rawId.isEmpty || isOnlyUnderscores) {
          // fallback to auto-generated id when sanitized id would be invalid/reserved
          await directionsColl.add(dir.toMap());
        } else {
          await directionsColl.doc(rawId).set(dir.toMap());
        }
      } catch (e) {
        // If an invalid-argument error occurs for a particular id, fallback to auto-id
        try {
          await directionsColl.add(dir.toMap());
        } catch (_) {
          // ignore and continue with next direction
        }
      }
    }

    debugPrint("Added ${uni.name}");
  }
  debugPrint("Все университеты загружены!");
}

/// Deletes all documents in the `universities` collection, then uploads
/// the `exampleUniversities` list. Use with caution.
Future<void> clearAndUploadUniversities() async {
  final coll = _firestore.collection('universities');
  final snapshot = await coll.get();
  for (final doc in snapshot.docs) {
    // delete subcollection 'directions' documents first
    final dirsSnap = await coll.doc(doc.id).collection('directions').get();
    for (final d in dirsSnap.docs) {
      await coll.doc(doc.id).collection('directions').doc(d.id).delete();
    }
    // then delete the university doc
    await coll.doc(doc.id).delete();
  }

  await uploadUniversities();
}

void main() async {
  await uploadUniversities();
}
