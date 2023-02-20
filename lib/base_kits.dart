library base_kits;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

export 'src/analysis/analytic_kit.dart';
export 'src/store/store_kit.dart';
export 'package:in_app_purchase/in_app_purchase.dart';
export 'src/admob/entity/ad_config.dart';
export 'src/admob/admob_kit.dart';

class BaseKits {
  init() async {
    //Firebase
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }
}
