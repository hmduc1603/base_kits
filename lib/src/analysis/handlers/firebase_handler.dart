import 'dart:developer';

import 'package:base_kits/base_kits.dart';
import 'package:base_kits/src/analysis/handlers/base_handler.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase/firestore_kit.dart';

class FirebaseHandler extends BaseHandler {
  Future<void> init() async {
    if (kReleaseMode) {
      await FirebaseAnalytics.instance.logAppOpen();
    }
  }

  @override
  void logPurchase(String currency, double price) {
    if (kReleaseMode) {
      FirebaseAnalytics.instance.logPurchase(
        currency: currency,
        value: price,
      );
    }
  }

  @override
  void sendEvent(String name, Map<String, dynamic>? value) {
    try {
      if (kReleaseMode) {
        FirebaseAnalytics.instance
            .logEvent(
          name: name,
          parameters: value?.cast(),
        )
            .onError((error, stackTrace) {
          log(error.toString());
        });
        if (name == AnalyticEvent.purchaseSuccess && value != null) {
          FireStoreKit()
              .addData(collection: AnalyticEvent.purchaseSuccess, data: value);
        }
      }
    } catch (e) {
      log(e.toString(), name: "FirebaseHandler");
    }
  }
}
