import 'dart:developer';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:base_kits/src/analysis/handlers/base_handler.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AppFlyerHandler extends BaseHandler {
  AppsflyerSdk? appsflyerSdk;

  Future<void> init(String? devKey, String? appId) async {
    try {
      if (devKey != null && appId != null) {
        AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
          afDevKey: devKey,
          appId: appId,
          showDebug: kDebugMode,
          timeToWaitForATTUserAuthorization: 50,
        ); // Optional field
        appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
        await appsflyerSdk?.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true,
        );
        appsflyerSdk?.getAppsFlyerUID().then((value) {
          FirebaseAnalytics.instance.setUserId(id: value);
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void logPurchase(String currency, double price) {
    appsflyerSdk?.logEvent("af_revenue", {
      "af_currency": currency,
      "af_revenue": price,
    });
  }

  @override
  void sendEvent(String name, Map<String, dynamic>? value) {
    appsflyerSdk?.logEvent(name, value);
  }
}
