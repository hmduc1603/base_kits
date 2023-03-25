import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SupportManager {
  static final SupportManager _instance = SupportManager._internal();
  SupportManager._internal();
  factory SupportManager() => _instance;

  Future<void> sendEmail({
    required String subject,
    required List<String> recipients,
  }) async {
    try {
      await FlutterEmailSender.send(Email(
        subject: subject,
        recipients: recipients,
        body: await _prepareDefaultBody(),
      ));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  Future<String> _prepareDefaultBody() async {
    final appInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      return 'Device: ${deviceInfo.model}\nApp Version: ${appInfo.version}\n';
    } else {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      return 'Device: ${deviceInfo.model}\nApp Version: ${appInfo.version}\n';
    }
  }
}
