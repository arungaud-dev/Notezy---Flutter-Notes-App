import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/models/note_model.dart';
import 'package:notes_app/providers/auth_state_provider.dart';
import 'package:notes_app/providers/notes_provider.dart';

final fireDataProvider = Provider.autoDispose((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) {
    return;
  }
  final sub = FirebaseFirestore.instance
      .collection('accounts')
      .doc(uid)
      .collection('notes')
      .snapshots()
      .listen((snap) {
    for (final change in snap.docChanges) {
      if (change.doc.metadata.hasPendingWrites) continue;

      final m = Map<String, dynamic>.from(change.doc.data() ?? {});

      m['id'] = m['id'] ?? change.doc.id;

      final d = NoteModel.fromMap(m);

      final n = ref.read(notesProvider.notifier);
      if (change.type == DocumentChangeType.added) {
        n.addData(d);
      } else if (change.type == DocumentChangeType.modified) {
        n.updateData(d.id, d.title, d.body, d.createdAt, d.updatedAt, d.isStar,
            d.category, d.isSynced);
      } else if (change.type == DocumentChangeType.removed) {
        n.deleteData(d.id);
      }
    }
  });
  ref.onDispose(() => sub.cancel());
});

// final fireDataProvider = StreamProvider((ref) async* {
//   FirebaseFirestore.instance
//       .collection("accounts")
//       .doc("example_user")
//       .collection("notes")
//       .snapshots()
//       .listen(
//     (snapshot) {
//       for (var change in snapshot.docChanges) {
//         try {
//           if (change.doc.metadata.hasPendingWrites) continue;
//           final data = DataModel.fromMap(change.doc.data()!);
//
//           if (change.type == DocumentChangeType.added) {
//             ref.read(notesProivder.notifier).addData(data);
//           } else if (change.type == DocumentChangeType.removed) {
//             ref.read(notesProivder.notifier).deleteData(data.id);
//           } else if (change.type == DocumentChangeType.modified) {
//             ref.read(notesProivder.notifier).addData(data);
//           }
//         } catch (e) {
//           print("Error processing document: $e");
//         }
//       }
//     },
//     onError: (error) {
//       print("Firestore sync error (offline?): $error");
//     },
//     cancelOnError: false,
//   );
// });
