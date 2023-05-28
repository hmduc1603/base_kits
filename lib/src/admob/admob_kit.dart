// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'package:base_kits/src/admob/entity/custom_banner_ad.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../base_kits.dart';
import 'ads_counting_manager.dart';

class AdmobKit {
  static final AdmobKit _instance = AdmobKit._internal();
  AdmobKit._internal();
  factory AdmobKit() => _instance;

  late AdConfig adConfig;
  late AdUnitConfig _adUnitConfig;
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  List<CustomBannerAd> bannerAds = [];
  List<String> usedBannerAdResponseIds = [];
  Completer? initCompleter;

  Future<void> preloadBannerAd({Function(BannerAd ad)? onReceivedAd}) async {
    try {
      final completer = Completer();
      await BannerAd(
        adUnitId: _adUnitConfig.bannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            onReceivedAd != null
                ? onReceivedAd(ad as BannerAd)
                : bannerAds.add(CustomBannerAd(ad: ad as BannerAd));
            completer.complete();
            log('BannerAd is Loaded!!!', name: "AdmobKit");
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            ad.dispose();
            completer.complete();
            log('BannerAd failed to load: $error', name: "AdmobKit");
          },
        ),
      ).load();
      await completer.future;
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _loadIntersitial() async {
    // InterstitialAd
    final completer = Completer();
    try {
      await InterstitialAd.load(
          adUnitId: _adUnitConfig.interstitialId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              // Keep a reference to the ad so you can show it later.
              _interstitialAd = ad;
              completer.complete();
              log('InterstitialAd is Loaded!!!', name: "AdmobKit");
            },
            onAdFailedToLoad: (LoadAdError error) {
              log('InterstitialAd failed to load: $error', name: "AdmobKit");
              completer.complete();
            },
          ));
      await completer.future;
    } catch (e) {
      log(e.toString());
      completer.complete();
    }
  }

  Future<void> preloadOpenAds() async {
    final completer = Completer();
    try {
      await AppOpenAd.load(
        adUnitId: _adUnitConfig.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            completer.complete();
            log('OpenAd is Loaded!!!', name: "AdmobKit");
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('OpenAds failed to load: $error', name: "AdmobKit");
            completer.complete();
          },
        ),
        orientation: AppOpenAd.orientationPortrait,
      );
      await completer.future;
    } catch (e) {
      log(e.toString());
      completer.complete();
    }
  }

  Future<void> init(AdConfig adConfig, AdUnitConfig adUnitConfig) async {
    initCompleter = Completer();
    _adUnitConfig = adUnitConfig;
    this.adConfig = adConfig;
    await MobileAds.instance.initialize();
    if (adConfig.enableOpenAd) {
      await preloadOpenAds();
    }
    if (adConfig.enableBannerAd) {
      await preloadBannerAd();
    }
    initCompleter?.complete();
    log('Completed initializing', name: 'AdmobKit');
  }

  void showInterstitialAd(
      {Function(bool didShow)? onComplete, VoidCallback? onReachLimit}) {
    try {
      AdsCountingManager().checkShouldShowAds(
        onShouldShowAds: (shouldShowAds) async {
          if (shouldShowAds) {
            log('showInterstitialAd', name: 'AdmobKit');
            if (_interstitialAd == null) {
              await _loadIntersitial();
            }
            _interstitialAd?.fullScreenContentCallback =
                FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                onComplete != null ? onComplete(true) : null;
                _interstitialAd?.dispose();
                _interstitialAd = null;
              },
              onAdFailedToShowFullScreenContent:
                  (InterstitialAd ad, AdError error) {
                onComplete != null ? onComplete(false) : null;
                _interstitialAd?.dispose();
                _interstitialAd = null;
              },
            );
            await _interstitialAd?.show();
            if (_interstitialAd == null) {
              onComplete != null ? onComplete(false) : null;
            } else {
              AnalyticKit().logEvent(name: AnalyticEvent.showInterstitial);
            }
          } else {
            onReachLimit != null ? onReachLimit() : null;
            onComplete != null ? onComplete(false) : null;
          }
        },
      );
    } catch (e) {
      onComplete != null ? onComplete(false) : null;
      log(e.toString());
    }
  }

  Future<void> showAppOpenAd({Function(bool didShow)? onComplete}) async {
    try {
      log('showAppOpenAd', name: 'AdmobKit');
      if (_appOpenAd == null) {
        await preloadOpenAds();
      }
      _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (AppOpenAd ad) {
          onComplete != null ? onComplete(true) : null;
          _appOpenAd?.dispose();
          _appOpenAd = null;
        },
        onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
          onComplete != null ? onComplete(false) : null;
          _appOpenAd?.dispose();
          _appOpenAd = null;
        },
      );
      await _appOpenAd?.show();
      if (_appOpenAd == null) {
        onComplete != null ? onComplete(false) : null;
      } else {
        AnalyticKit().logEvent(name: AnalyticEvent.showOpenAds);
      }
    } catch (e) {
      onComplete != null ? onComplete(false) : null;
      log(e.toString());
    }
  }

  Future<void> forceShowAppOpenAds() async {
    try {
      await AppOpenAd.load(
        adUnitId: _adUnitConfig.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            ad.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('OpenAds failed to load: $error', name: "AdmobKit");
          },
        ),
        orientation: AppOpenAd.orientationPortrait,
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  Future<void> forceShowInterstitialAds() async {
    try {
      await InterstitialAd.load(
          adUnitId: _adUnitConfig.interstitialId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              ad.show();
            },
            onAdFailedToLoad: (LoadAdError error) {
              log('InterstitialAd failed to load: $error', name: "AdmobKit");
            },
          ));
    } catch (e, s) {
      log(e.toString());
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }
}
