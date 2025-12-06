import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Favorites service backed by Firestore. Stores university codes per local user.
class FavoritesService extends ValueNotifier<Set<String>> {
  FavoritesService._internal() : super(<String>{}) {
    _init();
  }

  static final FavoritesService _instance = FavoritesService._internal();

  factory FavoritesService() => _instance;

  static FavoritesService get instance => _instance;

  final _docRef = FirebaseFirestore.instance.collection('users').doc('local_user');

  /// Direction favorites are stored as strings in the form `uniCode|directionName`.
  final ValueNotifier<Set<String>> directionFavorites = ValueNotifier(<String>{});

  Future<void> _init() async {
    // Listen to backend changes and keep local sets in sync.
    _docRef.snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data();
        final favs = (data?['favorites'] as List<dynamic>?)?.cast<String>() ?? <String>[];
        value = Set<String>.from(favs);
        final dirFavs = (data?['favoriteDirections'] as List<dynamic>?)?.cast<String>() ?? <String>[];
        directionFavorites.value = Set<String>.from(dirFavs);
      } else {
        // Ensure doc exists with empty arrays.
        _docRef.set({'favorites': <String>[], 'favoriteDirections': <String>[]}, SetOptions(merge: true));
        value = <String>{};
        directionFavorites.value = <String>{};
      }
    }, onError: (_) {
      // Keep current in-memory state on error.
    });
  }

  bool isFavorite(String code) => value.contains(code);

  Future<void> toggle(String code) async {
    final current = Set<String>.from(value);
    final willAdd = !current.contains(code);

    // Optimistically update local value for snappy UI.
    if (willAdd) {
      current.add(code);
      value = current;
    } else {
      current.remove(code);
      value = current;
    }

    try {
      if (willAdd) {
        await _docRef.update({'favorites': FieldValue.arrayUnion([code])});
      } else {
        await _docRef.update({'favorites': FieldValue.arrayRemove([code])});
      }
    } catch (e) {
      // Revert on failure and try to recover by fetching latest from server.
      final snap = await _docRef.get();
      if (snap.exists) {
        final favs = (snap.data()?['favorites'] as List<dynamic>?)?.cast<String>() ?? <String>[];
        value = Set<String>.from(favs);
      }
    }
  }

  // ---------------- Direction favorites ----------------
  String _dirKey(String uniCode, String direction) => '$uniCode|$direction';

  bool isDirectionFavorite(String uniCode, String direction) {
    return directionFavorites.value.contains(_dirKey(uniCode, direction));
  }

  Future<void> toggleDirection(String uniCode, String direction) async {
    final key = _dirKey(uniCode, direction);
    final current = Set<String>.from(directionFavorites.value);
    final willAdd = !current.contains(key);

    if (willAdd) {
      current.add(key);
      directionFavorites.value = current;
    } else {
      current.remove(key);
      directionFavorites.value = current;
    }
    // Fire the update to Firestore but don't await it synchronously to avoid
    // blocking the UI. If it fails, refresh the local state from the server.
    if (willAdd) {
      _docRef.update({'favoriteDirections': FieldValue.arrayUnion([key])}).catchError((_) => _refreshDirectionFavorites());
    } else {
      _docRef.update({'favoriteDirections': FieldValue.arrayRemove([key])}).catchError((_) => _refreshDirectionFavorites());
    }
  }

  Future<void> _refreshDirectionFavorites() async {
    try {
      final snap = await _docRef.get();
      if (snap.exists) {
        final dirFavs = (snap.data()?['favoriteDirections'] as List<dynamic>?)?.cast<String>() ?? <String>[];
        directionFavorites.value = Set<String>.from(dirFavs);
      }
    } catch (_) {
      // Ignore refresh errors to avoid blocking the UI.
    }
  }

  List<String> get favoritesList => value.toList(growable: false);

  List<String> get favoriteDirectionsList => directionFavorites.value.toList(growable: false);
}
