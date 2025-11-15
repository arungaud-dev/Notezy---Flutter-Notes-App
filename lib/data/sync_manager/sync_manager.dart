import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/firebase_data/firebase_services.dart';
import 'package:notes_app/provider/data_provider.dart';

class SyncManager {
  final DBHelper dbHelper;
  final FirebaseServices services;

  SyncManager({required this.dbHelper, required this.services});

  Future<void> syncLocalToFirebase() async {
    final notes = await dbHelper.getUnSyncedData();
    if (notes.isEmpty) return;
    for (var data in notes) {
      await services.addDataInFire(data);
      await dbHelper.markSynced(data.id);
    }
  }

  Future<void> deleteFromFire(String id) async {
    await services.deleteNoteFromFire(id);
  }
}

// provider binding
final syncManagerProvider = Provider<SyncManager>((ref) {
  final services = ref.read(firebaseServicesProvider);
  final db = DBHelper.instance;
  return SyncManager(dbHelper: db, services: services);
});
