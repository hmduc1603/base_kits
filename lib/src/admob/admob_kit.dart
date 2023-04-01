import 'dart:async';
import 'dart:developer';
import 'package:base_kits/base_kits.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';

class AdmobKit extends IAdIdManager {
  static final AdmobKit _instance = AdmobKit._internal();
  AdmobKit._internal();
  factory AdmobKit() => _instance;

  late AdConfig _adConfig;
  EasyAdBase? bannerAd;
  StreamSubscription? _openAdEventSub;

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

  bool isInitialize = false;

  init({
    required AdConfig adConfig,
    AdmobEventListener? admobEventListener,
  }) async {
    try {
      _adConfig = adConfig;
      if (!isInitialize) {
        await EasyAds.instance.initialize(
          this,
          adMobAdRequest: const AdRequest(),
          fbTestMode: kDebugMode,
        );
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
      }
      await preloadBannerAd();
      isInitialize = true;
    } catch (e) {
      log(e.toString(), name: "AdmobKit");
    }
  }

  showAppOpenAd({Function(bool couldShow)? onComplete}) {
    if (_openAdEventSub != null) {
      onComplete != null ? onComplete(false) : null;
      return;
    }
    try {
      log('showAppOpenAd', name: 'AdmobKit');
      AnalyticKit().logEvent(name: AnalyticEvent.showOpenAds);
      EasyAds.instance.showAd(AdUnitType.appOpen, delayInSeconds: 0);
      _openAdEventSub = EasyAds.instance.onEvent.listen((event) {
        if (event.adUnitType == AdUnitType.appOpen) {
          _openAdEventSub?.cancel();
          _openAdEventSub == null;
          switch (event.type) {
            case AdEventType.adDismissed:
              onComplete != null ? onComplete(true) : null;
              break;
            default:
              onComplete != null ? onComplete(false) : null;
              break;
          }
        }
      });
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
