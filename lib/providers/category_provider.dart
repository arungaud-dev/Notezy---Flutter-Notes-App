import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/firestore_service/firebase_service.dart';
import 'package:notes_app/data/local_data/db_helper.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Make DB dependency injectable for testing. Also keep default categories const.
class CategoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  Ref ref;
  static const List<Map<String, dynamic>> _defaultCategories = [
    {"title": "General", "color": "green"},
    {"title": "Personal", "color": "yellow"},
    {"title": "School", "color": "purple"},
  ];
  final DBHelper _db;

  /// Accept optional DB helper for easier testing; default to the singleton.
  CategoryNotifier(this.ref, {DBHelper? db})
      : _db = db ?? DBHelper.instance,
        super(List.unmodifiable(_defaultCategories));

  /// Fetch categories from DB and merge with defaults (without duplicates).
  Future<void> getCategory() async {
    try {
      final data = await _db.getCategory();
      state = List.unmodifiable(data);
    } catch (e, _) {
      rethrow;
    }
  }

  /// Adds a category if valid and not duplicate.
  /// Returns true if added, false if it was duplicate/invalid.
  Future<bool> addCategory(Map<String, dynamic> data) async {
    final services = ref.watch(firebaseServicesProvider);
    final trimmed = data["title"].trim();
    if (trimmed.isEmpty) return false;

    final alreadyExists =
        state.any((c) => c["title"].toLowerCase() == trimmed.toLowerCase());
    if (alreadyExists) return false;

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
}

// Provider with optional override for testing.
final categoryHandler =
    StateNotifierProvider<CategoryNotifier, List<Map<String, dynamic>>>(
  (ref) => CategoryNotifier(ref),
);
