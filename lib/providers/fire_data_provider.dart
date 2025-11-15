import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/models/data_model.dart';
import 'package:notes_app/providers/notes_provider.dart';

final fireDataProvider = StreamProvider((ref) async* {
  FirebaseFirestore.instance
      .collection("accounts")
      .doc("example_user")
      .collection("notes")
      .snapshots()
      .listen(
    (snapshot) {
      for (var change in snapshot.docChanges) {
        try {
          if (change.doc.metadata.hasPendingWrites) continue;
          final data = DataModel.fromMap(change.doc.data()!);

          if (change.type == DocumentChangeType.added) {
            ref.read(notesProivder.notifier).addData(data);
          } else if (change.type == DocumentChangeType.removed) {
            ref.read(notesProivder.notifier).deleteData(data.id);
          } else if (change.type == DocumentChangeType.modified) {
            ref.read(notesProivder.notifier).addData(data);
          }
        } catch (e) {
          print("Error processing document: $e");
        }
      }
    },
    onError: (error) {
      print("Firestore sync error (offline?): $error");
    },
    cancelOnError: false,
  );
});
