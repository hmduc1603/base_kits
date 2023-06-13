import 'dart:developer';

import 'package:base_kits/base_kits.dart';
import 'package:base_kits/src/analysis/handlers/base_handler.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_storage/firebase_storage_kit.dart';

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
    if (kReleaseMode) {
      FirebaseAnalytics.instance
          .logEvent(
        name: name,
        parameters: value,
      )
          .onError((error, stackTrace) {
        log(error.toString());
      });
      if (name == AnalyticEvent.purchaseSuccess && value != null) {
        FirebaseStorageKit()
            .addData(collection: AnalyticEvent.purchaseSuccess, data: value);
      }
    }
  }
}
