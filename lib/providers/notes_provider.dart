import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/models/note_model.dart';
import 'package:notes_app/data/sync_manager/sync_manager.dart';
import 'package:notes_app/providers/category_provider.dart';

class DataNotifier extends StateNotifier<List<NoteModel>> {
  final Ref ref;
  late final SyncManager manager;

  DataNotifier(this.ref) : super([]) {
    manager = ref.read(syncManagerProvider);
  }

  static final DBHelper db = DBHelper.instance;
  static List<NoteModel>? data;

  Future<void> getDataForUi() async {
    final filter = ref.read(categoryProvider);
    if (data != null && filter != null) {
      state = data!.where((data) => data.category == filter).toList();
    } else if (data != null && filter == null) {
      state = data!;
    } else if (data == null && filter == null) {
      getData("From Top");
    }
  }

  Future<void> getData(String h1) async {
    final notes = await db.getData();

    data = notes;
    getDataForUi();
    ref.read(isLoadingProvider.notifier).state = false;
  }

  Future<void> addData(NoteModel data) async {
    try {
      await db.insertData(data);
      await getData("add");
      try {
        final syncMgr = ref.read(syncManagerProvider);
        // call the sync and await it; catch any error inside
        final maybeFuture = syncMgr.syncLocalToFirebase();
        await Future.value(maybeFuture);
      } catch (e, st) {
        debugPrint(
            'DataNotifier.addData: manager.syncLocalToFirebase FAILED: $e\n$st');
      }
    } catch (e, st) {
      debugPrint('DataNotifier.addData ERROR: $e\n$st');
    }
  }

  Future<void> deleteData(String id) async {
    await db.deleteData(id);
    getData("delete");
    manager.deleteFromFire(id);
  }

  Future<void> updateData(
      String id,
      String? title,
      String? body,
      String? createdAt,
      int? updatedAt,
      int? isStar,
      String? category,
      int? isSynced) async {
    final data = state.where((data) => data.id == id).first;
    await db.updateData(
        id,
        data.copyWith(
            title: title,
            body: body,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isStar: isStar,
            category: category,
            isSynced: isSynced));
    getData("update");
    manager.syncLocalToFirebase();
  }

  Future<void> updateStar(String id) async {
    final data = state.where((data) => data.id == id).first;
    final star = data.isStar == 0 ? 1 : 0;
    await db.updateData(id, data.copyWith(isStar: star, isSynced: 0));
    getData("update");
    manager.syncLocalToFirebase();
  }
}

final notesProvider = StateNotifierProvider<DataNotifier, List<NoteModel>>(
    (ref) => DataNotifier(ref));

final isLoadingProvider = StateProvider<bool>((ref) => true);
