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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:notes_app/data/local_data/db_helper.dart';
// import 'package:notes_app/data/models/note_model.dart';
// import 'package:notes_app/data/sync_manager/sync_manager.dart';
// import 'package:notes_app/providers/category_provider.dart';
//
// class DataNotifier extends StateNotifier<List<NoteModel>> {
//   final Ref ref;
//   late final SyncManager manager;
//
//   DataNotifier(this.ref) : super([]) {
//     manager = ref.read(syncManagerProvider);
//   }
//
//   static final DBHelper db = DBHelper.instance;
//   static List<NoteModel>? data;
//
//   Future<void> getDataForUi() async {
//     final filter = ref.read(selectedCategoryProvider);
//     if (data != null && filter != null) {
//       state = data!.where((data) => data.category == filter).toList();
//     } else if (data != null && filter == null) {
//       state = data!;
//     } else if (data == null && filter == null) {
//       getData("From Top");
//     }
//   }
//
//   Future<void> getData(String h1) async {
//     final notes = await db.getData();
//
//     data = notes;
//     getDataForUi();
//     ref.read(isLoadingProvider.notifier).state = false;
//   }
//
//   Future<void> addData(NoteModel data) async {
//     try {
//       await db.insertData(data);
//       await getData("add");
//       try {
//         final syncMgr = ref.read(syncManagerProvider);
//         // call the sync and await it; catch any error inside
//         final maybeFuture = syncMgr.syncLocalToFirebase();
//         await Future.value(maybeFuture);
//       } catch (e, st) {
//         debugPrint(
//             'DataNotifier.addData: manager.syncLocalToFirebase FAILED: $e\n$st');
//       }
//     } catch (e, st) {
//       debugPrint('DataNotifier.addData ERROR: $e\n$st');
//     }
//   }
//
//   Future<void> deleteData(String id) async {
//     await db.deleteData(id);
//     getData("delete");
//     manager.deleteFromFire(id);
//   }
//
//   Future<void> updateData(
//       {required String id,
//       String? title,
//       String? body,
//       String? createdAt,
//       int? updatedAt,
//       int? isStar,
//       String? category,
//       int? isSynced}) async {
//     final data = state.where((data) => data.id == id).first;
//     await db.updateData(
//         id,
//         data.copyWith(
//             title: title,
//             body: body,
//             createdAt: createdAt,
//             updatedAt: updatedAt,
//             isStar: isStar,
//             category: category,
//             isSynced: isSynced));
//     getData("update");
//     manager.syncLocalToFirebase();
//   }
//
//   Future<void> updateStar(String id) async {
//     final data = state.where((data) => data.id == id).first;
//     final star = data.isStar == 0 ? 1 : 0;
//     await db.updateData(id, data.copyWith(isStar: star, isSynced: 0));
//     getData("update");
//     manager.syncLocalToFirebase();
//   }
// }
//
// final notesProvider = StateNotifierProvider<DataNotifier, List<NoteModel>>(
//     (ref) => DataNotifier(ref));
//
// final isLoadingProvider = StateProvider<bool>((ref) => true);
