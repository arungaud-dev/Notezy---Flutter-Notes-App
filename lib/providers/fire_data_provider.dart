import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/models/note_model.dart';
import 'package:notes_app/providers/auth_state_provider.dart';
import 'package:notes_app/providers/notes_provider.dart';

final fireDataProvider = Provider.autoDispose<
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?>(
  (ref) {
    final uid = ref.watch(uidProvider);
    if (uid == null) {
      return null;
    }

    final collectionRef = FirebaseFirestore.instance
        .collection('accounts')
        .doc(uid)
        .collection('notes');

    final sub = collectionRef.snapshots().listen(
      (snap) {
        final notifier = ref.read(notesProvider.notifier);
        for (final change in snap.docChanges) {
          // Ignore local pending writes if you handle optimistic updates separately.
          if (change.doc.metadata.hasPendingWrites) continue;

          // Use firestore doc id as authoritative id
          final docId = change.doc.id;
          final map = Map<String, dynamic>.from(change.doc.data() ?? {});
          map['id'] = docId;

          final data = NoteModel.fromMap(map);

          switch (change.type) {
            case DocumentChangeType.added:
              notifier.addData(data);
              break;
            case DocumentChangeType.modified:
              notifier.updateData(
                id: data.id,
                title: data.title,
                body: data.body,
                createdAt: data.createdAt,
                updatedAt: data.updatedAt,
                isStar: data.isStar,
                category: data.category,
                isSynced: data.isSynced,
              );
              break;
            case DocumentChangeType.removed:
              notifier.deleteData(data.id);
              break;
          }
        }
      },
      onError: (err, stack) {
        // Optional: report to Sentry / logging provider
        // print('Firestore notes stream error: $err');
      },
    );

    ref.onDispose(() {
      sub.cancel();
    });

    return sub;
  },
);

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:notes_app/data/models/note_model.dart';
// import 'package:notes_app/providers/auth_state_provider.dart';
// import 'package:notes_app/providers/notes_provider.dart';
//
// final fireDataProvider = Provider.autoDispose((ref) {
//   final uid = ref.watch(uidProvider);
//   if (uid == null) {
//     return;
//   }
//   final sub = FirebaseFirestore.instance
//       .collection('accounts')
//       .doc(uid)
//       .collection('notes')
//       .snapshots()
//       .listen((snap) {
//     for (final change in snap.docChanges) {
//       if (change.doc.metadata.hasPendingWrites) continue;
//
//       final map = Map<String, dynamic>.from(change.doc.data() ?? {});
//
//       map['id'] = map['id'] ?? change.doc.id;
//
//       final data = NoteModel.fromMap(map);
//
//       final notifier = ref.read(notesProvider.notifier);
//
//       switch (change.type) {
//         case DocumentChangeType.added:
//           notifier.addData(data);
//           break;
//
//         case DocumentChangeType.modified:
//           notifier.updateData(
//             data.id,
//             data.title,
//             data.body,
//             data.createdAt,
//             data.updatedAt,
//             data.isStar,
//             data.category,
//             data.isSynced,
//           );
//           break;
//
//         case DocumentChangeType.removed:
//           notifier.deleteData(data.id);
//           break;
//       }
//     }
//   });
//   ref.onDispose(() => sub.cancel());
// });
