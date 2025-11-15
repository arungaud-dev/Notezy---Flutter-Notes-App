import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/models/data_model.dart';
import 'package:notes_app/provider/auth_state_provider.dart';

class FirebaseServices {
  // final String? uid;
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // FirebaseServices({required this.uid, required this.ref});
  FirebaseServices(this.ref);

  Future<void> addDataInFire(DataModel data) async {
    final uid = ref.watch(uidProvider);
    try {
      await _firestore
          .collection("accounts")
          .doc(uid)
          .collection("notes")
          .doc(data.id)
          .set(data.toMap());
    } catch (e) {
      debugPrint(
          "A ERROR IN DATA ADDING IN FIREBASE PLEASE CHECK DATABASE FILE");
    }
  }

  Future<List<DataModel>> getDataFromFire(int lastUpdate) async {
    final uid = ref.watch(uidProvider);
    try {
      final notes = await _firestore
          .collection("accounts")
          .doc(uid)
          .collection("notes")
          .where("updatedAt", isGreaterThan: lastUpdate)
          .get();
      final docs = notes.docs;

      return docs
          .map((data) => DataModel(
              id: data["id"],
              title: data["title"],
              body: data["body"],
              category: data["category"],
              isStar: data["isStar"],
              createdAt: data["createdAt"],
              updatedAt: data["updatedAt"],
              isSynced: data["isSynced"]))
          .toList();
    } catch (e) {
      debugPrint(
          "A ERROR IN DATA ADDING IN FIREBASE PLEASE CHECK DATABASE FILE: ${e.toString()}");
      return [];
    }
  }

  Future<void> deleteNoteFromFire(String id) async {
    final uid = ref.watch(uidProvider);
    try {
      await _firestore
          .collection("accounts")
          .doc(uid)
          .collection("notes")
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint("A ERROR IN DATA DELETING ON FIREBASE");
    }
  }
}

// 1) Provider that exposes the service
final firebaseServicesProvider = Provider<FirebaseServices>((ref) {
  return FirebaseServices(ref);
});
