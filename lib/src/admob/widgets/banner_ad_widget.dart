import 'dart:developer';

import 'package:base_kits/src/admob/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore: depend_on_referenced_packages

class AdmobServiceBannerAdWidget extends StatefulWidget {
  const AdmobServiceBannerAdWidget({super.key});

  @override
  State<AdmobServiceBannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<AdmobServiceBannerAdWidget> {
  BannerAd? ad;

  @override
  void initState() {
    if (AdmobKit().isBannerAdPreloaded) {
      setState(() {
        ad = AdmobKit().bannerAds;
      });
      AdmobKit().preloadBannerAd();
      log("Use preloaded banner ad", name: "AdmobServiceBannerAdWidget");
    } else {
      AdmobKit().forceShowBannerAd().then((value) {
        if (value != null) {
          setState(() {
            ad = value;
          });
          AdmobKit().preloadBannerAd();
        }
      });
      log("Loaded banner ad", name: "AdmobServiceBannerAdWidget");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ad == null) {
      return FutureBuilder(
          future: Future.delayed(const Duration(seconds: 5)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const SizedBox();
            }
            return const SizedBox(
              height: 72.0,
            );
          });
    }
    return FutureBuilder<AdSize?>(
        future: ad!.getPlatformAdSize(),
        builder: (context, snapshot) {
          return SafeArea(
            child: Container(
              width: double.infinity,
              height: snapshot.data?.height.toDouble() ?? 72.0,
              alignment: Alignment.center,
              child: AdWidget(ad: ad!),
            ),
          );
        });
  }
}
