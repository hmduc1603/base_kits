import 'dart:developer';

import 'package:base_kits/src/admob/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore: depend_on_referenced_packages

class AdmobServiceBannerAdWidget extends StatefulWidget {
  const AdmobServiceBannerAdWidget({
    super.key,
    this.useForceShow = false,
    this.containerBackgroundColor,
    this.loadingWidget,
  });

  final bool useForceShow;
  final Color? containerBackgroundColor;
  final Widget? loadingWidget;

  @override
  State<AdmobServiceBannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<AdmobServiceBannerAdWidget> {
  BannerAd? ad;

  @override
  void dispose() {
    ad?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final preloadedAd = AdmobKit().getPreloadedBannerAd();
    if (preloadedAd != null && !widget.useForceShow) {
      ad = preloadedAd;
      AdmobKit().preloadBannerAd();
      log("Use preloaded banner ad: ${preloadedAd.responseInfo?.responseId}",
          name: "AdmobServiceBannerAdWidget");
    } else {
      AdmobKit().forceShowBannerAd().then((value) {
        try {
          if (value != null) {
            setState(() {
              ad = value;
            });
            AdmobKit().preloadBannerAd();
          }
        } catch (e) {
          log(e.toString());
        }
      });
      log("Loaded banner ad", name: "AdmobServiceBannerAdWidget");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdmobKit().adConfig.enableBannerAd) {
      return const SizedBox();
    }
    if (ad == null) {
      return FutureBuilder(
          future: Future.delayed(const Duration(seconds: 5)),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.all(5),
              color: widget.containerBackgroundColor ?? Colors.grey[200],
              height: AdSize.fullBanner.height.toDouble(),
              child: widget.loadingWidget ??
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  ),
            );
          });
    }
    return Container(
      height: AdSize.fullBanner.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(
        key: Key(ad!.responseInfo!.responseId!),
        ad: ad!,
      ),
    );
  }
}
