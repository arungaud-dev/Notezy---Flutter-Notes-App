import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/models/local_data_model.dart';

class DataNotifier extends StateNotifier<List<DataModel>> {
  DataNotifier() : super([]);

  static final DBHelper db = DBHelper.instance;

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
  }

  Future<void> deleteData(int id, String? filter) async {
    await db.deleteData(id);
    getData(filter);
  }

  Future<void> updateData(
      int id, String title, String body, String? filter) async {
    final data = state.where((data) => data.id == id).first;
    await db.updateData(id, data.copyWith(title: title, body: body));
    getData(filter);
    debugPrint(
        "-------------------------------------------------: UPDATE METHOD CALLED, ID: $id DATA: ${data.toMap()}");
  }

  Future<void> updateStar(int id, String? filter) async {
    final data = state.where((data) => data.id == id).first;
    final star = data.isStar == 0 ? 1 : 0;
    await db.updateData(id, data.copyWith(isStar: star));
    getData(filter);
    debugPrint(
        "-------------------------------------------------: UPDATE METHOD CALLED, DATA: ${data.toMap()}");
  }
}

final notesProivder = StateNotifierProvider<DataNotifier, List<DataModel>>(
    (ref) => DataNotifier());
