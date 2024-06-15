import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ReportManager {
  static final ReportManager _instance = ReportManager._internal();
  ReportManager._internal();
  factory ReportManager() => _instance;

  Future<void> report(
      {required String userEmail,
      required String sendToEmail,
      required String msg,
      required bool isPremium}) async {
    CollectionReference report =
        FirebaseFirestore.instance.collection('report');
    final defaultBody = await _prepareDefaultBody(isPremium: isPremium);
    await report
        .add({
          'created_date': Timestamp.now(),
          'email': userEmail,
          'msg': msg,
          'info': defaultBody,
          'to': sendToEmail,
          'message': {
            "subject": "[Report Problem] $userEmail",
            "html": "<p>$defaultBody</p><p>$msg</p>"
          }
        })
        .then((value) => log("did reported: $userEmail - $msg}"))
        .catchError((error) => log("Failed to add user: $error"));
  }

  Future<String> _prepareDefaultBody({
    required bool isPremium,
  }) async {
    final appInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      return 'Device: ${deviceInfo.model}\nApp Version: ${appInfo.version}\nPremium:$isPremium\n';
    } else {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      return 'Device: ${deviceInfo.model}\nApp Version: ${appInfo.version}\nPremium:$isPremium\n';
    }
  }
}
