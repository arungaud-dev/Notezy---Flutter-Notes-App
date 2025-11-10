import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/models/local_data_model.dart';

class DataNotifier extends StateNotifier<List<DataModel>> {
  DataNotifier() : super([]);

  static final DBHelper db = DBHelper.instance;

  Future<void> getData() async {
    final list = await db.getData();
    state = list;
  }

  Future<void> addData(DataModel data) async {
    await db.insertData(data);
    getData();
  }

  Future<void> deleteData(int id) async {
    await db.deleteData(id);
    getData();
  }

  Future<void> updateData(int id, DataModel data) async {
    await db.updateData(id, data);
    getData();
  }
}

final notesProivder = StateNotifierProvider<DataNotifier, List<DataModel>>(
    (ref) => DataNotifier());
