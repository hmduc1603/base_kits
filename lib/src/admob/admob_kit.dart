import 'dart:async';
import 'dart:developer';
import 'package:base_kits/base_kits.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_counting_manager.dart';
import 'entity/ad_limitation.dart';

class AdmobKit {
  static final AdmobKit _instance = AdmobKit._internal();
  AdmobKit._internal();
  factory AdmobKit() => _instance;

  late AdConfig _adConfig;
  AppOpenAd? _appOpenAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  InterstitialAd? _interstitialAd;

  preloadInterstitialAd({
    bool showAfterBeingLoaded = false,
  }) {
    try {
      InterstitialAd.load(
          adUnitId: _adConfig.interstitialId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              _interstitialAd = ad;
              if (showAfterBeingLoaded) {
                forceShowInterstitialAd();
              }
            },
            onAdFailedToLoad: (LoadAdError error) {
              log('InterstitialAd failed to load: $error');
            },
          )).onError((error, stackTrace) {
        log(error.toString());
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> forceShowInterstitialAd({
    VoidCallback? onComplete,
    VoidCallback? reachLimitation,
  }) async {
    try {
      AdsCountingManager().checkShouldShowAds(
        onShouldShowAds: (shouldShowAds) {
          if (shouldShowAds) {
            if (_interstitialAd != null) {
              _interstitialAd?.fullScreenContentCallback =
                  FullScreenContentCallback(
                onAdFailedToShowFullScreenContent: (ad, error) {
                  onComplete != null ? onComplete() : null;
                },
                onAdDismissedFullScreenContent: (_) {
                  preloadInterstitialAd();
                  onComplete != null ? onComplete() : null;
                },
              );
              _interstitialAd?.show();
            } else {
              preloadInterstitialAd(showAfterBeingLoaded: true);
            }
          } else {
            reachLimitation != null ? reachLimitation() : null;
          }
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> preloadRewardInterAds() async {
    try {
      await RewardedInterstitialAd.load(
        adUnitId: "",
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedInterstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            log('RewardedInterAd failed to load: $error');
          },
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> showRewardInterstitialAds(
      {required Function(int rewards) onRewarded}) async {
    try {
      if (_rewardedInterstitialAd != null) {
        await _rewardedInterstitialAd?.show(
          onUserEarnedReward: (ad, reward) {
            onRewarded(reward.amount.toInt());
            preloadRewardInterAds();
          },
        );
      } else {
        await preloadRewardInterAds();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> showRewardAds(
      {required Function(int rewards) onRewarded}) async {
    try {
      await RewardedAd.load(
          adUnitId: _adConfig.rewardId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              ad.show(
                onUserEarnedReward: (ad, reward) {
                  onRewarded(reward.amount.toInt());
                },
              );
            },
            onAdFailedToLoad: (error) {
              log('RewardedAd failed to load: $error');
            },
          ));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> loadBannerAds({
    required Function(BannerAd bannerAd) onAdLoaded,
  }) async {
    try {
      await BannerAd(
        adUnitId: _adConfig.bannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdFailedToLoad: (ad, error) {
            log('BannerAds failed to load: $error');
          },
          onAdLoaded: (ad) {
            onAdLoaded(ad as BannerAd);
          },
        ),
      ).load();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> preLoadOpenAds(
      {bool showAfterLoaded = false, VoidCallback? onAdDimissed}) async {
// Open Ad
    try {
      await AppOpenAd.load(
        adUnitId: _adConfig.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            if (showAfterLoaded) {
              showAppOpenAd(onAdDimissed: onAdDimissed);
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('OpenAds failed to load: $error');
          },
        ),
        orientation: AppOpenAd.orientationPortrait,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  init({
    required AdConfig adConfig,
    AdLimitation? adLimitation,
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
    await MobileAds.instance.initialize();
  }

  Future<void> showAppOpenAd(
      {bool forceShow = false, VoidCallback? onAdDimissed}) async {
    try {
      log('showAppOpenAd', name: 'AdmobKit');
      if (_appOpenAd == null || forceShow) {
        await preLoadOpenAds(showAfterLoaded: true, onAdDimissed: onAdDimissed);
        return;
      }
      _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          preLoadOpenAds();
          if (onAdDimissed != null) {
            onAdDimissed();
          }
        },
      );
      await _appOpenAd?.show();
      AnalyticKit().logEvent(name: AnalyticEvent.showOpenAds);
    } catch (e) {
      log(e.toString(), name: "AdmobKit");
    }
  }
}
