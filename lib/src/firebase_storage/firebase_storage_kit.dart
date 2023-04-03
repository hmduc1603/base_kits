import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStorageKit {
  static final FirebaseStorageKit _instance = FirebaseStorageKit._internal();
  FirebaseStorageKit._internal();
  factory FirebaseStorageKit() => _instance;

  Future<void> addData(
      {required String collection, required Map<String, dynamic> data}) {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collection);
    return collectionRef
        .add(data)
        .then((value) => log("addData ", name: "FirebaseStorageKit"))
        .catchError((error) =>
            log("Failed to add user: $error", name: "FirebaseStorageKit"));
  }
}
