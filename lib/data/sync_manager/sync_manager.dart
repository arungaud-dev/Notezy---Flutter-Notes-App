import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/firebase_data/firebase_services.dart';

class SYNCManager {
  final DBHelper dbHelper = DBHelper.instance;
  final FirebaseServices services = FirebaseServices(uid: "example_user");

  Future<void> syncLocalToFirebase() async {
    final notes = await dbHelper.getUnSyncedData();
    if (notes.isEmpty) return;
    for (var data in notes) {
      await services.addDataInFire(data);
      await dbHelper.markSynced(data.id);
    }
  }
}
