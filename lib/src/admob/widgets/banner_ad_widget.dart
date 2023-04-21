import 'package:base_kits/src/admob/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobServiceBannerAdWidget extends StatefulWidget {
  const AdmobServiceBannerAdWidget({super.key});

  @override
  State<AdmobServiceBannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<AdmobServiceBannerAdWidget> {
  BannerAd? ad;

  @override
  void initState() {
    AdmobKit().preloadBannerAd(
      onReceivedAd: (ad) {
        setState(() {
          this.ad = ad;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ad == null) {
      return const SizedBox();
    }
    return Container(
      width: double.infinity,
      height: 72.0,
      alignment: Alignment.center,
      child: AdWidget(ad: ad!),
    );
  }
}
