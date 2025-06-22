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
    required bool isPremium,
    String? body,
    List<String>? attachmentPaths,
  }) async {
    try {
      await FlutterEmailSender.send(Email(
        subject: subject,
        recipients: recipients,
        body: await _prepareDefaultBody(isPremium: isPremium, body: body),
        attachmentPaths: attachmentPaths,
      ));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  Future<String> _prepareDefaultBody({
    required bool isPremium,
    String? body,
  }) async {
    final appInfo = await PackageInfo.fromPlatform();
    return 'App Version: ${appInfo.version}\nPremium:$isPremium\n';
  }
}
