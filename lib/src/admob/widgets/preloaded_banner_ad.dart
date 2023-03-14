import 'dart:developer';

import 'package:base_kits/src/admob/admob_kit.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

class PreloadedBannerAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final AdSize adSize;
  const PreloadedBannerAd({
    this.adNetwork = AdNetwork.admob,
    this.adSize = AdSize.banner,
    Key? key,
  }) : super(key: key);

  @override
  State<PreloadedBannerAd> createState() => _PreloadedBannerAdState();
}

class _PreloadedBannerAdState extends State<PreloadedBannerAd> {
  EasyAdBase? _bannerAd;

  @override
  Widget build(BuildContext context) {
    return _bannerAd?.show() ?? const SizedBox();
  }

  @override
  void didUpdateWidget(covariant PreloadedBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);

    createBanner();
    _bannerAd?.onBannerAdReadyForSetState = onBannerAdReadyForSetState;
  }

  void createBanner() {
    _bannerAd = EasyAds.instance
        .createBanner(adNetwork: widget.adNetwork, adSize: widget.adSize);
    _bannerAd?.load();
  }

  @override
  void initState() {
    if (AdmobKit().bannerAd == null) {
      log("Create new banner", name: "PreloadedBannerAd");
      createBanner();
      _bannerAd?.onAdLoaded = onBannerAdReadyForSetState;
    } else {
      log("Use preloaded banner", name: "PreloadedBannerAd");
      _bannerAd = AdmobKit().bannerAd;
      AdmobKit().preloadBannerAd();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void onBannerAdReadyForSetState(
      AdNetwork adNetwork, AdUnitType adUnitType, Object? data) {
    setState(() {});
  }
}
