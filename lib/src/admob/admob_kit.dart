import 'dart:async';
import 'dart:developer';
import 'package:base_kits/base_kits.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';

class AdmobKit {
  static final AdmobKit _instance = AdmobKit._internal();
  AdmobKit._internal();
  factory AdmobKit() => _instance;

  late AdConfig _adConfig;
  AdmobEventListener? _admobEventListener;

  EasyBannerAd createBannerAd() {
    return const EasyBannerAd(
        adNetwork: AdNetwork.admob, adSize: AdSize.fullBanner);
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

  init({
    required AdConfig adConfig,
    AdLimitation? adLimitation,
    AdmobEventListener? admobEventListener,
  }) async {
    _adConfig = adConfig;
    if (adLimitation != null) {
      AdsCountingManager().setUpLimitation(adLimitation);
    }
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        init(adConfig: _adConfig);
      }
    });
    await EasyAds.instance.initialize(
      AdIdManager(adConfig: adConfig),
      adMobAdRequest: const AdRequest(),
      fbTestMode: kDebugMode,
    );
    EasyAds.instance.onEvent.listen((event) {
      switch (event.adUnitType) {
        case AdUnitType.appOpen:
          _admobEventListener?.onOpenAdEvent(event.type);
          break;
        case AdUnitType.banner:
          _admobEventListener?.onBannerAdEvent(event.type);
          break;
        case AdUnitType.interstitial:
          _admobEventListener?.onInterstitialAdEvent(event.type);
          break;
        case AdUnitType.rewarded:
          _admobEventListener?.onRewardAdEvent(event.type);
          break;
        default:
      }
    });
  }

  Future<void> showAppOpenAd() async {
    try {
      log('showAppOpenAd', name: 'AdmobKit');
      EasyAds.instance.showAd(AdUnitType.appOpen);
      AnalyticKit().logEvent(name: AnalyticEvent.showOpenAds);
    } catch (e) {
      log(e.toString(), name: "AdmobKit");
    }
  }
}

class AdIdManager extends IAdIdManager {
  const AdIdManager({
    required this.adConfig,
  });

  final AdConfig adConfig;

  @override
  AppAdIds? get admobAdIds => AppAdIds(
        appId: adConfig.adId,
        appOpenId: adConfig.appOpenId,
        bannerId: adConfig.bannerId,
        interstitialId: adConfig.interstitialId,
      );

  @override
  AppAdIds? get appLovinAdIds => null;

  @override
  AppAdIds? get fbAdIds => null;

  @override
  AppAdIds? get unityAdIds => null;
}
