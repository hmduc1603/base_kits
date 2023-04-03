import 'dart:async';
import 'dart:developer';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../base_kits.dart';

class AdmobKit {
  static final AdmobKit _instance = AdmobKit._internal();
  AdmobKit._internal();
  factory AdmobKit() => _instance;

  late AdConfig _adConfig;
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;

  Future<void> _loadIntersitial() async {
    // InterstitialAd
    final completer = Completer();
    try {
      await InterstitialAd.load(
          adUnitId: _adConfig.interstitialId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              // Keep a reference to the ad so you can show it later.
              _interstitialAd = ad;
              completer.complete();
            },
            onAdFailedToLoad: (LoadAdError error) {
              log('InterstitialAd failed to load: $error');
              completer.complete();
            },
          ));
      await completer.future;
    } catch (e) {
      log(e.toString());
      completer.complete();
    }
  }

  Future<void> _loadOpenAds() async {
    final completer = Completer();
    try {
      await AppOpenAd.load(
        adUnitId: _adConfig.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            completer.complete();
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('OpenAds failed to load: $error');
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

  setupAdLimitation(
    AdLimitation? adLimitation,
  ) {
    if (adLimitation != null) {
      AdsCountingManager().setUpLimitation(adLimitation);
    }
  }

  init(AdConfig adConfig) async {
    _adConfig = adConfig;
    await MobileAds.instance.initialize();
    await _loadOpenAds();
    log('Completed initializing', name: 'AdmobService');
  }

  Future<void> showInterstitialAd({Function(bool didShow)? onComplete}) async {
    log('showInterstitialAd', name: 'AdmobService');
    if (_interstitialAd == null) {
      await _loadIntersitial();
    }
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        onComplete != null ? onComplete(true) : null;
        _interstitialAd?.dispose();
        _interstitialAd = null;
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        onComplete != null ? onComplete(false) : null;
        _interstitialAd?.dispose();
        _interstitialAd = null;
      },
    );
    await _interstitialAd?.show();
    AnalyticKit().logEvent(name: AnalyticEvent.showInterstitial);
  }

  Future<void> showAppOpenAd({Function(bool didShow)? onComplete}) async {
    log('showAppOpenAd', name: 'AdmobService');
    if (_appOpenAd == null) {
      await _loadOpenAds();
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
    AnalyticKit().logEvent(name: AnalyticEvent.showOpenAds);
  }

  Future<void> forceShowAppOpenAds() async {
    try {
      await AppOpenAd.load(
        adUnitId: _adConfig.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            ad.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('OpenAds failed to load: $error');
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
          adUnitId: _adConfig.interstitialId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              ad.show();
            },
            onAdFailedToLoad: (LoadAdError error) {
              log('InterstitialAd failed to load: $error');
            },
          ));
    } catch (e, s) {
      log(e.toString());
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }
}
