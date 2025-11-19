import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/models/note_model.dart';
import 'package:notes_app/data/sync_manager/sync_manager.dart';
import 'package:notes_app/providers/category_provider.dart';

class DataNotifier extends AsyncNotifier<List<NoteModel>> {
  final DBHelper db = DBHelper.instance;
  List<NoteModel>? _cachedAllNotes;

  SyncManager get manager => ref.read(syncManagerProvider);

  @override
  Future<List<NoteModel>> build() async {
    _cachedAllNotes ??= await db.getData();

    ref.listen(selectedCategoryProvider, (previous, next) {
      _applyFilter(next);
    });

    final filter = ref.read(selectedCategoryProvider);
    if (filter != null) {
      return _cachedAllNotes!.where((note) => note.category == filter).toList();
    }

    return _cachedAllNotes!;
  }

  void _applyFilter(String? filter) {
    if (_cachedAllNotes == null) return;

    if (filter != null) {
      state = AsyncData(
        _cachedAllNotes!.where((note) => note.category == filter).toList(),
      );
    } else {
      state = AsyncData(_cachedAllNotes!);
    }
  }

  Future<void> _updateCacheAndRefresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _cachedAllNotes = await db.getData();

      final filter = ref.read(selectedCategoryProvider);
      if (filter != null) {
        return _cachedAllNotes!
            .where((note) => note.category == filter)
            .toList();
      }
      return _cachedAllNotes!;
    });
  }

  Future<void> addData(NoteModel noteData) async {
    try {
      await db.insertData(noteData);

      try {
        await manager.syncLocalToFirebase();
      } catch (e, st) {
        debugPrint('Sync failed: $e\n$st');
      }

      await _updateCacheAndRefresh();
    } catch (e, st) {
      debugPrint('Add data error: $e\n$st');
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteData(String id) async {
    try {
      // Optimistic delete - instant UI update
      final currentNotes = state.value;
      if (currentNotes != null) {
        final updatedNotes = currentNotes.where((n) => n.id != id).toList();
        state = AsyncData(updatedNotes);
        _cachedAllNotes = _cachedAllNotes?.where((n) => n.id != id).toList();
      }

      // Background operations
      await db.deleteData(id);
      await manager.deleteFromFire(id);
    } catch (e, st) {
      debugPrint('Delete error: $e\n$st');
      // Error pe fresh data fetch karo
      await _updateCacheAndRefresh();
    }
  }

  Future<void> updateData({
    required String id,
    String? title,
    String? body,
    String? createdAt,
    int? updatedAt,
    int? isStar,
    String? category,
    int? isSynced,
  }) async {
    try {
      final currentNotes = state.value;
      if (currentNotes == null) return;

      final noteToUpdate = currentNotes.firstWhere((note) => note.id == id);
      final updatedNote = noteToUpdate.copyWith(
        title: title,
        body: body,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isStar: isStar,
        category: category,
        isSynced: isSynced,
      );

      // Optimistic update - instant UI
      final updatedNotes = currentNotes.map((n) {
        if (n.id == id) return updatedNote;
        return n;
      }).toList();

      final filter = ref.read(selectedCategoryProvider);
      if (filter != null) {
        state = AsyncData(
          updatedNotes.where((note) => note.category == filter).toList(),
        );
      } else {
        state = AsyncData(updatedNotes);
      }

      _cachedAllNotes = updatedNotes;

      // Background operations
      await db.updateData(id, updatedNote);
      await manager.syncLocalToFirebase();
    } catch (e, st) {
      debugPrint('Update error: $e\n$st');
      await _updateCacheAndRefresh();
    }
  }

  Future<void> updateStar(String id) async {
    try {
      final currentNotes = state.value;
      if (currentNotes == null) return;

      final note = currentNotes.firstWhere((n) => n.id == id);
      final newStarValue = note.isStar == 0 ? 1 : 0;

      // ⚡ INSTANT UI UPDATE - zero lag!
      final updatedNotes = currentNotes.map((n) {
        if (n.id == id) {
          return n.copyWith(isStar: newStarValue);
        }
        return n;
      }).toList();

      // Filter apply karke state update
      final filter = ref.read(selectedCategoryProvider);
      if (filter != null) {
        state = AsyncData(
          updatedNotes.where((note) => note.category == filter).toList(),
        );
      } else {
        state = AsyncData(updatedNotes);
      }

      // Cache update
      _cachedAllNotes = updatedNotes;

      // Background operations
      await db.updateData(
        id,
        note.copyWith(isStar: newStarValue, isSynced: 0),
      );

      await manager.syncLocalToFirebase();
    } catch (e, st) {
      debugPrint('Update star error: $e\n$st');
      await _updateCacheAndRefresh();
    }
  }

  Future<void> forceRefresh() async {
    _cachedAllNotes = null;
    await _updateCacheAndRefresh();
  }
}

final notesProvider = AsyncNotifierProvider<DataNotifier, List<NoteModel>>(
  () => DataNotifier(),
);
