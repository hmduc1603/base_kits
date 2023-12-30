import 'dart:developer';

import 'package:base_kits/src/analysis/handlers/base_handler.dart';
import 'package:base_kits/src/analysis/handlers/firebase_handler.dart';

class AnalyticKit {
  static final AnalyticKit _instance = AnalyticKit._internal();
  AnalyticKit._internal();
  factory AnalyticKit() => _instance;

  final List<BaseHandler> _handlers = [];

  Future<void> init({
    required List<Type> handlers,
    String? afDevKey,
    String? afAppId,
  }) async {
    log('log app open', name: 'AnalyticKit');
    for (var e in handlers) {
      if (e == FirebaseHandler) {
        _handlers.add(FirebaseHandler()..init());
      }
    }
  }

  void logEvent({required String name, Map<String, dynamic>? params}) {
    log('log event: $name', name: 'AnalyticKit');
    log('log event params: $params', name: 'AnalyticKit');
    for (var e in _handlers) {
      e.sendEvent(name, params);
    }
  }

  void logPurchase({required String currency, required double price}) {
    log('log purchase: $currency - $price', name: 'AnalyticKit');
    for (var e in _handlers) {
      e.logPurchase(currency, price);
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
  static const showRewardAds = 'show_reward_ads';
}
