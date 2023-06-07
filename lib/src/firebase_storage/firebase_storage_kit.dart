import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';

class FirebaseStorageKit {
  static final FirebaseStorageKit _instance = FirebaseStorageKit._internal();
  FirebaseStorageKit._internal();
  factory FirebaseStorageKit() => _instance;

  Future<String> _getAppVersion() async {
    try {
      final version = (await PackageInfo.fromPlatform()).version;
      return version;
    } catch (e) {
      log(e.toString());
      return "null";
    }
  }

  Future<void> addData(
      {required String collection, required Map<String, dynamic> data}) async {
    final adjustedData = data;
    adjustedData["created_date"] = DateTime.now();
    adjustedData["version"] = await _getAppVersion();
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collection);
    collectionRef
        .add(adjustedData)
        .then((value) => log("addData ", name: "FirebaseStorageKit"))
        .catchError((error) =>
            log("Failed to add user: $error", name: "FirebaseStorageKit"));
  }
}
