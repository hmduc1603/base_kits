import 'dart:developer';

import 'package:base_kits/src/admob/admob_kit.dart';
import 'package:base_kits/src/local/local_storage.dart';
import 'entity/ads_counter.dart';

class AdsCountingManager {
  static final AdsCountingManager _instance = AdsCountingManager._internal();
  AdsCountingManager._internal();
  factory AdsCountingManager() => _instance;

  int count = 0;

  void checkShouldShowAds(
      {required Function(bool shouldShowAds) onShouldShowAds}) {
    bool shouldShowAds = false;
    final adsCounter = LocalStorage().adsCounter;
    if (adsCounter == null) {
      increaseCounter();
      if (AdmobKit().adConfig.adLimitation.dailyInterstitialLimitation > 0) {
        shouldShowAds = true;
      }
    } else {
      if (adsCounter.updatedDate.day == DateTime.now().day) {
        if (adsCounter.adsCounting <
            AdmobKit().adConfig.adLimitation.dailyInterstitialLimitation) {
          if (AdmobKit()
                  .adConfig
                  .adLimitation
                  .showInterstitialAfterEveryNumber ==
              0) {
            shouldShowAds = true;
            increaseCounter(adsCounter: adsCounter);
          } else {
            if (count == 0 ||
                count %
                        AdmobKit()
                            .adConfig
                            .adLimitation
                            .showInterstitialAfterEveryNumber ==
                    0) {
              shouldShowAds = true;
              increaseCounter(adsCounter: adsCounter);
            }
          }
          count += 1;
        }
      } else {
        // reset to new day
        adsCounter.resetToNewDay();
        count += 1;
        shouldShowAds = true;
        increaseCounter(adsCounter: adsCounter);
      }
    }
    onShouldShowAds(shouldShowAds);
    log('Should show ads: $shouldShowAds', name: 'AdsCountingManager');
  }

  void increaseCounter({AdsCounter? adsCounter}) {
    if (adsCounter == null) {
      LocalStorage().setAdsCounter(AdsCounter(
        updatedDate: DateTime.now(),
        adsCounting: 1,
      ));
    } else {
      adsCounter.adsCounting += 1;
      adsCounter.updatedDate = DateTime.now();
      LocalStorage().setAdsCounter(adsCounter);
    }
  }
}
