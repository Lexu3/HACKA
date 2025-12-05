import 'package:flutter/foundation.dart';

/// Simple in-memory favorites service. Stores university codes.
class FavoritesService extends ValueNotifier<Set<String>> {
  FavoritesService._internal() : super(<String>{});

  static final FavoritesService _instance = FavoritesService._internal();

  factory FavoritesService() => _instance;

  /// Convenience accessor for the singleton instance.
  static FavoritesService get instance => _instance;

  bool isFavorite(String code) => value.contains(code);

  void toggle(String code) {
    final newSet = Set<String>.from(value);
    if (newSet.contains(code)) {
      newSet.remove(code);
    } else {
      newSet.add(code);
    }
    value = newSet;
  }

  List<String> get favoritesList => value.toList(growable: false);
}
