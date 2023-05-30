import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../firebase_storage/firebase_storage_kit.dart';

class AnalyticKit {
  static final AnalyticKit _instance = AnalyticKit._internal();
  AnalyticKit._internal();
  factory AnalyticKit() => _instance;

  Future<void> init() async {
    log('log app open', name: 'AnalyticKit');
    if (kReleaseMode) {
      await FirebaseAnalytics.instance.logAppOpen();
    }
  }

  void logEvent({required String name, Map<String, dynamic>? params}) {
    log('log event: $name', name: 'AnalyticKit');
    log('log event params: $params', name: 'AnalyticKit');
    if (kReleaseMode) {
      FirebaseAnalytics.instance
          .logEvent(
        name: name,
      )
          .onError((error, stackTrace) {
        log(error.toString());
      });
      if (name == AnalyticEvent.purchaseSuccess && params != null) {
        FirebaseStorageKit()
            .addData(collection: AnalyticEvent.purchaseSuccess, data: params);
      }
    }
  }
}

class AnalyticEvent {
  static const purchaseSuccess = 'purchase_success';
  static const purchaseCancel = 'purchase_cancel';
  static const purchaseRestore = 'purchase_restore';
  static const showOpenAds = 'show_open_ads';
  static const showInterstitial = 'show_interstitial_ads';
  static const showBannerAds = 'show_banner_ads';
}
