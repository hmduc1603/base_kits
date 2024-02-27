import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';

class FireStoreKit {
  static final FireStoreKit _instance = FireStoreKit._internal();
  FireStoreKit._internal();
  factory FireStoreKit() => _instance;

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
    adjustedData["platform"] = Platform.isAndroid ? "Android" : "IOS";
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collection);
    collectionRef
        .add(adjustedData)
        .then((value) => log("addData ", name: "FireStoreKit"))
        .catchError(
            (error) => log("Failed to add user: $error", name: "FireStoreKit"));
  }
}
