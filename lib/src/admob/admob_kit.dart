// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'package:base_kits/src/admob/entity/custom_banner_ad.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../base_kits.dart';
import 'ads_counting_manager.dart';

export '/src/admob/entity/ad_test.dart';

class AdmobKit {
  static final AdmobKit _instance = AdmobKit._internal();
  AdmobKit._internal();
  factory AdmobKit() => _instance;

  late AdConfig adConfig;
  late AdUnitConfig _adUnitConfig;
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  List<CustomBannerAd> bannerAds = [];
  Completer? initCompleter;

  Future<BannerAd?> forceShowBannerAd() async {
    try {
      final completer = Completer<BannerAd?>();
      await BannerAd(
        adUnitId: _adUnitConfig.bannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            completer.complete(ad as BannerAd);
            log('Force show: BannerAd is Loaded!!!', name: "AdmobKit");
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            ad.dispose();
            completer.complete(null);
            log('Force show:  BannerAd failed to load: $error',
                name: "AdmobKit");
          },
        ),
      ).load();
      return completer.future;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  BannerAd? getPreloadedBannerAd() {
    final index = bannerAds.indexWhere((e) => !e.didShow && e.ad != null);
    if (index == -1) {
      return null;
    } else {
      bannerAds[index].didShow = true;
      return bannerAds.toList()[index].ad;
    }
  }

  Future<void> preloadBannerAd() async {
    if (!adConfig.enableBannerAd) {
      return;
    }
    try {
      final completer = Completer();
      await BannerAd(
        adUnitId: _adUnitConfig.bannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            bannerAds.add(CustomBannerAd(ad: ad as BannerAd));
            completer.complete();
            log('BannerAd is Loaded!!!', name: "AdmobKit");
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            bannerAds.add(CustomBannerAd(ad: null));
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

  Future<void> preloadIntersitial() async {
    if (!adConfig.enableInterstitialAd) {
      return;
    }
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
    if (!adConfig.enableOpenAd) {
      return;
    }
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
    await Future.wait([
      preloadOpenAds(),
      preloadIntersitial(),
      preloadBannerAd(),
    ]);
    initCompleter?.complete();
    log('Completed initializing', name: 'AdmobKit');
  }

  void showInterstitialAd(
      {Function(bool didShow)? onComplete, VoidCallback? onReachLimit}) {
    if (!adConfig.enableInterstitialAd) {
      onComplete != null ? onComplete(false) : null;
      return;
    }
    try {
      AdsCountingManager().checkShouldShowAds(
        onShouldShowAds: (shouldShowAds) async {
          if (shouldShowAds) {
            log('showInterstitialAd', name: 'AdmobKit');
            if (_interstitialAd == null) {
              await preloadIntersitial();
            }
            _interstitialAd?.fullScreenContentCallback =
                FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                onComplete != null ? onComplete(true) : null;
                _interstitialAd?.dispose();
                _interstitialAd = null;
                preloadIntersitial();
              },
              onAdFailedToShowFullScreenContent:
                  (InterstitialAd ad, AdError error) {
                onComplete != null ? onComplete(false) : null;
                _interstitialAd?.dispose();
                _interstitialAd = null;
                preloadIntersitial();
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
    if (!adConfig.enableOpenAd) {
      onComplete != null ? onComplete(false) : null;
      return;
    }
    try {
      log('showAppOpenAd', name: 'AdmobKit');
      if (_appOpenAd == null) {
        await preloadOpenAds();
      }
      _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          log('Open Ad: onAdShowedFullScreenContent', name: 'AdmobKit');
          onComplete != null ? onComplete(true) : null;
        },
        onAdDismissedFullScreenContent: (AppOpenAd ad) {
          log('Open Ad: onAdDismissedFullScreenContent', name: 'AdmobKit');
          _appOpenAd?.dispose();
          _appOpenAd = null;
          preloadOpenAds();
        },
        onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
          log('Open Ad: onAdFailedToShowFullScreenContent', name: 'AdmobKit');
          onComplete != null ? onComplete(false) : null;
          _appOpenAd?.dispose();
          _appOpenAd = null;
          preloadOpenAds();
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
    if (!adConfig.enableOpenAd) {
      return;
    }
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
    if (!adConfig.enableInterstitialAd) {
      return;
    }
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
