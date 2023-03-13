import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class SupportManager {
  static final SupportManager _instance = SupportManager._internal();
  SupportManager._internal();
  factory SupportManager() => _instance;

  Future<void> sendEmail({required Email email}) async {
    try {
      await FlutterEmailSender.send(email);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }
}
