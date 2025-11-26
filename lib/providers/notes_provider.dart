import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/models/note_model.dart';
import 'package:notes_app/data/models/read_note.dart';
import 'package:notes_app/data/sync_manager/sync_manager.dart';
import 'package:notes_app/providers/category_provider.dart';

class DataNotifier extends AsyncNotifier<List<NoteWithCategory>> {
  final DBHelper db = DBHelper.instance;
  List<NoteWithCategory>? _cachedAllNotes;

  SyncManager get manager => ref.read(syncManagerProvider);

  @override
  Future<List<NoteWithCategory>> build() async {
    _cachedAllNotes ??= await db.getRaw();

    ref.listen(selectedCategoryProvider, (previous, next) {
      _applyFilter(next);
    });

    final filter = ref.read(selectedCategoryProvider);
    if (filter != null) {
      return _cachedAllNotes!
          .where((note) => note.categoryTitle == filter)
          .toList();
    }

    return _cachedAllNotes!;
  }

  void _applyFilter(String? filter) {
    if (_cachedAllNotes == null) return;

    if (filter != null) {
      state = AsyncData(
        _cachedAllNotes!.where((note) => note.categoryTitle == filter).toList(),
      );
    } else {
      state = AsyncData(_cachedAllNotes!);
    }
  }

  Future<void> _updateCacheAndRefresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _cachedAllNotes = await db.getRaw();

      final filter = ref.read(selectedCategoryProvider);
      if (filter != null) {
        return _cachedAllNotes!
            .where((note) => note.categoryTitle == filter)
            .toList();
      }
      return _cachedAllNotes!;
    });
  }

  Future<void> addData(NoteModel noteData, String funID) async {
    bool shouldAdd = true;
    if (_cachedAllNotes != null && _cachedAllNotes!.isNotEmpty) {
      for (final element in _cachedAllNotes!) {
        if (element.noteID == noteData.id &&
            element.updatedAt == noteData.updatedAt) {
          return;
        }
      }
    }

    if (_cachedAllNotes != null && _cachedAllNotes!.isNotEmpty) {
      try {
        final existingNote = _cachedAllNotes!.firstWhere(
          (element) => element.noteID == noteData.id,
        );
        if (existingNote != null) {
          if (existingNote.updatedAt == noteData.updatedAt) {
            shouldAdd = false;
          }
        }
      } catch (e) {
        debugPrint("Exception in firstWhere: ${e.toString()}");
      }
    }

    if (!shouldAdd) return;
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
      final currentNotes = state.value;
      if (currentNotes != null) {
        final updatedNotes = currentNotes.where((n) => n.noteID != id).toList();
        state = AsyncData(updatedNotes);
        _cachedAllNotes =
            _cachedAllNotes?.where((n) => n.noteID != id).toList();
      }
      await db.deleteData(id);
      await manager.deleteFromFire(id);
    } catch (e, st) {
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
      if (_cachedAllNotes == null) return;

      final originalNote = _cachedAllNotes!.firstWhere((n) => n.noteID == id);

      final updatedNoteObject = originalNote.copyWith(
        noteTitle: title,
        body: body,
        createdAt: createdAt,
        isStar: isStar,
        categoryTitle: category,
        isSynced: isSynced,
      );

      final dbModelCheck = originalNote.copyWithFor(
          id: id,
          title: title,
          body: body,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isStar: isStar,
          category: category,
          isSynced: 0);

      _cachedAllNotes = _cachedAllNotes!.map((n) {
        if (n.noteID == id) return updatedNoteObject;
        return n;
      }).toList();

      final filter = ref.read(selectedCategoryProvider);

      if (filter != null) {
        state = AsyncData(
          _cachedAllNotes!
              .where((note) => note.categoryTitle == filter)
              .toList(),
        );
      } else {
        state = AsyncData(_cachedAllNotes!);
      }

      await db.updateData(id, dbModelCheck);
      await manager.syncLocalToFirebase();
    } catch (e, st) {
      debugPrint('Update error: $e\n$st');
      await _updateCacheAndRefresh();
    }
  }

  Future<void> updateStar(String id) async {
    try {
      if (_cachedAllNotes == null) return;

      final note = _cachedAllNotes!.firstWhere((n) => n.noteID == id);
      final newStarValue = note.isStar == 0 ? 1 : 0;

      _cachedAllNotes = _cachedAllNotes!.map((n) {
        if (n.noteID == id) {
          return n.copyWith(isStar: newStarValue);
        } else {
          return n;
        }
      }).toList();

      final filter = ref.read(selectedCategoryProvider);
      if (filter != null) {
        state = AsyncData(
          _cachedAllNotes!
              .where((note) => note.categoryTitle == filter)
              .toList(),
        );
      } else {
        state = AsyncData(_cachedAllNotes!);
      }

      final notes = NoteModel(
          id: note.noteID,
          title: note.noteTitle,
          body: note.body,
          createdAt: note.createdAt,
          updatedAt: note.updatedAt,
          isStar: newStarValue,
          category: note.categoryTitle,
          isSynced: 0);
      // Background operations
      await db.updateData(id, notes);

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

final notesProvider =
    AsyncNotifierProvider<DataNotifier, List<NoteWithCategory>>(
  () => DataNotifier(),
);
