import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:base_kits/src/analysis/handlers/base_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class AppFlyerHandler extends BaseHandler {
  AppsflyerSdk? appsflyerSdk;

  void init(String? devKey, String? appId) {
    if (devKey != null && appId != null) {
      AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
        afDevKey: devKey,
        appId: appId,
        showDebug: kDebugMode,
        timeToWaitForATTUserAuthorization: 50,
      ); // Optional field
      appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
      appsflyerSdk?.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
      );
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
