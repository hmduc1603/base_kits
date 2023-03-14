import 'dart:async';
import 'dart:developer';
import 'package:base_kits/base_kits.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';

class AdmobKit extends IAdIdManager {
  static final AdmobKit _instance = AdmobKit._internal();
  AdmobKit._internal();
  factory AdmobKit() => _instance;

  late AdConfig _adConfig;
  EasyAdBase? bannerAd;

  EasyBannerAd createBannerAd() {
    return const EasyBannerAd(
        adNetwork: AdNetwork.admob, adSize: AdSize.fullBanner);
  }

  Future<void> preloadBannerAd() async {
    bannerAd = EasyAds.instance
        .createBanner(adNetwork: AdNetwork.admob, adSize: AdSize.banner);
    await bannerAd?.load();
  }

  Future<void> showInterstitialAd({
    VoidCallback? readyToShow,
    VoidCallback? reachLimitation,
  }) async {
    try {
      AdsCountingManager().checkShouldShowAds(
        onShouldShowAds: (shouldShowAds) {
          if (shouldShowAds) {
            readyToShow != null ? readyToShow() : null;
            EasyAds.instance.showAd(AdUnitType.interstitial);
          } else {
            reachLimitation != null ? reachLimitation() : null;
          }
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> showRewardAds() async {
    try {
      EasyAds.instance.showAd(AdUnitType.rewarded);
    } catch (e) {
      log(e.toString());
    }
  }

  setupAdLimitation(
    AdLimitation? adLimitation,
  ) {
    if (adLimitation != null) {
      AdsCountingManager().setUpLimitation(adLimitation);
    }
  }

  init({
    required AdConfig adConfig,
    AdmobEventListener? admobEventListener,
  }) async {
    try {
      _adConfig = adConfig;
      await EasyAds.instance.initialize(
        this,
        adMobAdRequest: const AdRequest(),
        fbTestMode: kDebugMode,
      );
      await preloadBannerAd();
      EasyAds.instance.onEvent.listen((event) {
        switch (event.adUnitType) {
          case AdUnitType.appOpen:
            admobEventListener?.onOpenAdEvent(event.type);
            break;
          case AdUnitType.banner:
            admobEventListener?.onBannerAdEvent(event.type);
            break;
          case AdUnitType.interstitial:
            admobEventListener?.onInterstitialAdEvent(event.type);
            break;
          case AdUnitType.rewarded:
            admobEventListener?.onRewardAdEvent(event.type);
            break;
          default:
        }
      });
    } catch (e) {
      log(e.toString(), name: "AdmobKit");
    }
  }

  Future<void> showAppOpenAd() async {
    try {
      log('showAppOpenAd', name: 'AdmobKit');
      EasyAds.instance.showAd(AdUnitType.appOpen, delayInSeconds: 0);
      AnalyticKit().logEvent(name: AnalyticEvent.showOpenAds);
    } catch (e) {
      log(e.toString(), name: "AdmobKit");
    }
  }

  @override
  AppAdIds? get admobAdIds => AppAdIds(
        appId: _adConfig.adId,
        appOpenId: _adConfig.appOpenId,
        bannerId: _adConfig.bannerId,
        interstitialId: _adConfig.interstitialId,
      );

  @override
  AppAdIds? get appLovinAdIds => null;

  @override
  AppAdIds? get fbAdIds => null;

  @override
  AppAdIds? get unityAdIds => null;
}
