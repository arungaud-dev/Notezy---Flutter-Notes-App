import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/models/data_model.dart';
import 'package:notes_app/data/sync_manager/sync_manager.dart';
import 'package:notes_app/provider/category_provider.dart';

class DataNotifier extends StateNotifier<List<DataModel>> {
  final Ref ref;
  late final SyncManager manager;

  DataNotifier(this.ref) : super([]) {
    manager = ref.read(syncManagerProvider); // initialize once
  }

  static final DBHelper db = DBHelper.instance;
  static List<DataModel>? data;

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
    debugPrint(
        "----------------------------------------------------GET METHOD CALLED FROM: $h1");
  }

  Future<void> addData(DataModel data, String? filter) async {
    debugPrint(
        '??????????????????????????????????DataNotifier.addData: ENTER -> ${data.title}');

    try {
      // 1) insert locally
      debugPrint(
          '?????????????????????????????????DataNotifier.addData: inserting locally -> ${data.title}');
      await db.insertData(data);
      debugPrint(
          '??????????????????????????????????DataNotifier.addData: local insert done -> ${data.title}');

      // 2) refresh local cache & UI (await so state updated)
      await getData("add");
      debugPrint(
          '???????????????????????????????????DataNotifier.addData: getData finished -> state length=${state.length}');

      // 3) fetch manager fresh from provider (avoid holding any widget Ref)
      try {
        final syncMgr = ref.read(syncManagerProvider);
        debugPrint(
            '??????????????????????????????????DataNotifier.addData: obtained syncManager -> $syncMgr');

        // call the sync and await it; catch any error inside
        final maybeFuture = syncMgr.syncLocalToFirebase();
        await Future.value(maybeFuture);
        debugPrint(
            '????????????????????????????????DataNotifier.addData: manager.syncLocalToFirebase completed');
      } catch (e, st) {
        debugPrint(
            'DataNotifier.addData: manager.syncLocalToFirebase FAILED: $e\n$st');
      }

      debugPrint(
          '???????????????????????????????????DataNotifier.addData: EXIT success -> ${data.title}');
    } catch (e, st) {
      debugPrint(
          '?????????????????????????????????DataNotifier.addData ERROR: $e\n$st');
    }
  }

  // Future<void> addData(DataModel data, String? filter) async {
  //   await db.insertData(data);
  //   getData("add");
  //   manager.syncLocalToFirebase();
  // }

  Future<void> deleteData(String id, String? filter) async {
    await db.deleteData(id);
    getData("delete");
    manager.deleteFromFire(id);
  }

  Future<void> updateData(
      String id, String title, String body, String? filter, int updated) async {
    final data = state.where((data) => data.id == id).first;
    await db.updateData(
        id,
        data.copyWith(
            title: title, body: body, updatedAt: updated, isSynced: 0));
    getData("update");
    manager.syncLocalToFirebase();
  }

  Future<void> updateStar(String id, String? filter) async {
    final data = state.where((data) => data.id == id).first;
    final star = data.isStar == 0 ? 1 : 0;
    await db.updateData(id, data.copyWith(isStar: star, isSynced: 0));
    getData("update");
    manager.syncLocalToFirebase();
  }
}

final notesProivder = StateNotifierProvider<DataNotifier, List<DataModel>>(
    (ref) => DataNotifier(ref));
