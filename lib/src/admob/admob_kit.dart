import 'dart:async';
import 'dart:developer';
import 'package:base_kits/base_kits.dart';
import 'package:base_kits/src/admob/ads_counting_manager.dart';
import 'package:base_kits/src/admob/entity/ad_limitation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobKit {
  static final AdmobKit _instance = AdmobKit._internal();
  AdmobKit._internal();
  factory AdmobKit() => _instance;

  late AdConfig _adConfig;
  AppOpenAd? _appOpenAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  void showInterstitialAd({
    VoidCallback? onComplete,
    VoidCallback? reachLimitation,
  }) {
    // InterstitialAd
    AdsCountingManager().checkShouldShowAds(
      onShouldShowAds: (shouldShowAds) async {
        if (shouldShowAds) {
          await InterstitialAd.load(
              adUnitId: _adConfig.interstitialId,
              request: const AdRequest(),
              adLoadCallback: InterstitialAdLoadCallback(
                onAdLoaded: (InterstitialAd ad) {
                  ad.fullScreenContentCallback = FullScreenContentCallback(
                    onAdDismissedFullScreenContent: (_) {
                      if (onComplete != null) {
                        onComplete();
                      }
                    },
                  );
                  ad.show();
                },
                onAdFailedToLoad: (LoadAdError error) {
                  log('InterstitialAd failed to load: $error');
                  if (onComplete != null) {
                    onComplete();
                  }
                },
              )).onError((error, stackTrace) {
            log(error.toString());
            if (onComplete != null) {
              onComplete();
            }
          });
        } else {
          if (reachLimitation != null) {
            reachLimitation();
          }
        }
      },
    );
  }

  Future<void> _preloadRewardInterAds() async {
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

  Future<void> showRewardInterstitialAds({required Function(int rewards) onRewarded}) async {
    try {
      if (_rewardedInterstitialAd != null) {
        await _rewardedInterstitialAd?.show(
          onUserEarnedReward: (ad, reward) {
            onRewarded(reward.amount.toInt());
            _preloadRewardInterAds();
          },
        );
      } else {
        await _preloadRewardInterAds();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> showRewardAds({required Function(int rewards) onRewarded}) async {
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

  Future<void> _loadOpenAds() async {
// Open Ad
    try {
      await AppOpenAd.load(
        adUnitId: _adConfig.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
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

  Future<void> forceShowAppOpenAds({VoidCallback? onAdDimissed}) async {
    try {
      await AppOpenAd.load(
        adUnitId: _adConfig.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                if (onAdDimissed != null) {
                  onAdDimissed();
                }
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('InterstitialAd failed to load: $error');
          },
        ),
        orientation: AppOpenAd.orientationPortrait,
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  init({
    required AdConfig adConfig,
    required AdLimitation adLimitation,
  }) async {
    _adConfig = adConfig;
    AdsCountingManager().setUpLimitation(adLimitation);
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        init(adConfig: _adConfig, adLimitation: AdsCountingManager().adLimitation);
      }
    });
    await MobileAds.instance.initialize();
    await _loadOpenAds();
    _preloadRewardInterAds(); //no need asyn
  }

  Future<void> showAppOpenAd({bool forceShow = false}) async {
    log('showAppOpenAd', name: 'AdmobKit');
    if (_appOpenAd == null || forceShow) {
      await _loadOpenAds();
    }
    await _appOpenAd?.show().onError((error, stackTrace) {
      log(error.toString());
    });
    AnalyticKit().logEvent(name: AnalyticEvent.showOpenAds);
  }
}
