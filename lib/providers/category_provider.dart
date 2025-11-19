import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Make DB dependency injectable for testing. Also keep default categories const.
class CategoryNotifier extends StateNotifier<List<String>> {
  static const List<String> _defaultCategories = [
    "General",
    "Personal",
    "School",
  ];

  final DBHelper _db;

  // Accept optional DB helper for easier testing; default to the singleton.
  CategoryNotifier({DBHelper? db})
      : _db = db ?? DBHelper.instance,
        super(List.unmodifiable(_defaultCategories));

  /// Fetch categories from DB and merge with defaults (without duplicates).
  Future<void> getCategory() async {
    try {
      final data = await _db.getCategory(); // assume returns List<String>
      // Merge preserving order and avoiding duplicates (case-insensitive).
      final merged = <String>[];
      for (var c in _defaultCategories) {
        merged.add(c);
      }
      for (var item in data) {
        final exists = merged.any((m) => m.toLowerCase() == item.toLowerCase());
        if (!exists) merged.add(item);
      }
      // Make state unmodifiable to prevent outside mutation.
      state = List.unmodifiable(merged);
    } catch (e, _) {
      // Log or rethrow as needed — for now we rethrow to let UI decide.
      // You could also expose an error state via another provider.
      // print('getCategory failed: $e\n$st');
      rethrow;
    }
  }

  /// Adds a category if valid and not duplicate.
  /// Returns true if added, false if it was duplicate/invalid.
  Future<bool> addCategory(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return false;

    final alreadyExists =
        state.any((c) => c.toLowerCase() == trimmed.toLowerCase());
    if (alreadyExists) return false;

    // Optimistic update: update local state first, then persist.
    final newList = [...state, trimmed];
    state = List.unmodifiable(newList);

    try {
      await _db.addCategory(trimmed);
      return true;
    } catch (e) {
      // Rollback on error
      state = List.unmodifiable(state
          .where((c) => c.toLowerCase() != trimmed.toLowerCase())
          .toList());
      rethrow;
    }
  }
}

// Provider with optional override for testing.
final categoryHandler = StateNotifierProvider<CategoryNotifier, List<String>>(
  (ref) => CategoryNotifier(),
);
