import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/firestore_service/firebase_service.dart';
import 'package:notes_app/data/local_data/db_helper.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Make DB dependency injectable for testing. Also keep default categories const.
class CategoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  Ref ref;
  static const List<Map<String, dynamic>> _defaultCategories = [
    {"title": "General"},
    {"title": "Personal"},
    {"title": "School"},
  ];
  final DBHelper _db;

  /// Accept optional DB helper for easier testing; default to the singleton.
  CategoryNotifier(this.ref, {DBHelper? db})
      : _db = db ?? DBHelper.instance,
        super(List.unmodifiable(_defaultCategories));

  /// Fetch categories from DB and merge with defaults (without duplicates).
  Future<void> getCategory() async {
    try {
      final data = await _db.getCategory(); // assume returns List<String>
      // // Merge preserving order and avoiding duplicates (case-insensitive).
      // final List<Map<String,dynamic>> merged = [];
      // for (var c in _defaultCategories) {
      //   merged.add(c);
      // }
      // for (var item in data) {
      //   final exists = merged.any((m) => m.toLowerCase() == item["title"].toLowerCase());
      //   if (!exists) merged.add(item["title"]);
      // }
      // // Make state unmodifiable to prevent outside mutation.
      state = List.unmodifiable(data);
    } catch (e, _) {
      // Log or rethrow as needed — for now we rethrow to let UI decide.
      // You could also expose an error state via another provider.
      // print('getCategory failed: $e\n$st');
      rethrow;
    }
  }
  // Fetch categories from DB and merge with defaults (without duplicates).
  // Future<void> getCategory() async {
  //   try {
  //     final data = await _db.getCategory(); // assume returns List<String>
  //     // Merge preserving order and avoiding duplicates (case-insensitive).
  //     final merged = <String>[];
  //     for (var c in _defaultCategories) {
  //       merged.add(c);
  //     }
  //     for (var item in data) {
  //       final exists = merged.any((m) => m.toLowerCase() == item.toLowerCase());
  //       if (!exists) merged.add(item);
  //     }
  //     // Make state unmodifiable to prevent outside mutation.
  //     state = List.unmodifiable(merged);
  //   } catch (e, _) {
  //     // Log or rethrow as needed — for now we rethrow to let UI decide.
  //     // You could also expose an error state via another provider.
  //     // print('getCategory failed: $e\n$st');
  //     rethrow;
  //   }
  // }

  /// Adds a category if valid and not duplicate.
  /// Returns true if added, false if it was duplicate/invalid.
  Future<bool> addCategory(Map<String, dynamic> data) async {
    final services = ref.watch(firebaseServicesProvider);
    final trimmed = data["title"].trim();
    if (trimmed.isEmpty) return false;

    final alreadyExists =
        state.any((c) => c["title"].toLowerCase() == trimmed.toLowerCase());
    if (alreadyExists) return false;

    // Optimistic update: update local state first, then persist.
    final newList = [...state, data];
    state = List.unmodifiable(newList);

    try {
      await services.addCategoryInFire(data);
      await _db.addCategory(data);
      return true;
    } catch (e) {
      // Rollback on error
      state = List.unmodifiable(state
          .where((c) => c["title"].toLowerCase() != trimmed.toLowerCase())
          .toList());
      rethrow;
    }
  }
  // Future<bool> addCategory(String title) async {
  //   final trimmed = title.trim();
  //   if (trimmed.isEmpty) return false;
  //
  //   final alreadyExists =
  //       state.any((c) => c.toLowerCase() == trimmed.toLowerCase());
  //   if (alreadyExists) return false;
  //
  //   // Optimistic update: update local state first, then persist.
  //   final newList = [...state, trimmed];
  //   state = List.unmodifiable(newList);
  //
  //   try {
  //     await _db.addCategory(trimmed);
  //     return true;
  //   } catch (e) {
  //     // Rollback on error
  //     state = List.unmodifiable(state
  //         .where((c) => c.toLowerCase() != trimmed.toLowerCase())
  //         .toList());
  //     rethrow;
  //   }
  // }
}

// Provider with optional override for testing.
final categoryHandler =
    StateNotifierProvider<CategoryNotifier, List<Map<String, dynamic>>>(
  (ref) => CategoryNotifier(ref),
);
