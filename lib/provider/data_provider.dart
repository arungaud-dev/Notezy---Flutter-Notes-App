import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/models/data_model.dart';
import 'package:notes_app/data/sync_manager/sync_manager.dart';
import 'package:notes_app/data/firebase_data/firebase_services.dart';

class DataNotifier extends StateNotifier<List<DataModel>> {
  DataNotifier() : super([]);

  static final DBHelper db = DBHelper.instance;
  final SYNCManager manager = SYNCManager();
  final FirebaseServices services = FirebaseServices(uid: "example_user");

  Future<void> getData([String? filterName]) async {
    final list = await db.getData();
    if (filterName == null) {
      state = list;
    } else {
      state = list.where((data) => data.category == filterName).toList();
    }
  }

  Future<void> addData(DataModel data, String? filter) async {
    await db.insertData(data);
    getData(filter);
    manager.syncLocalToFirebase();
  }

  Future<void> deleteData(String id, String? filter) async {
    await db.deleteData(id);
    getData(filter);
  }

  Future<void> updateData(
      String id, String title, String body, String? filter, int updated) async {
    final data = state.where((data) => data.id == id).first;
    await db.updateData(
        id,
        data.copyWith(
            title: title, body: body, updatedAt: updated, isSynced: 0));
    getData(filter);
    manager.syncLocalToFirebase();
  }

  Future<void> updateStar(String id, String? filter) async {
    final data = state.where((data) => data.id == id).first;
    final star = data.isStar == 0 ? 1 : 0;
    await db.updateData(id, data.copyWith(isStar: star, isSynced: 0));
    await manager.syncLocalToFirebase();
    getData(filter);
  }
}

final notesProivder = StateNotifierProvider<DataNotifier, List<DataModel>>(
    (ref) => DataNotifier());
