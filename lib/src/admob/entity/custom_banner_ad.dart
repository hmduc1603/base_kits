// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:google_mobile_ads/google_mobile_ads.dart';

class CustomBannerAd {
  final BannerAd? ad;
  bool didShow;
  CustomBannerAd({
    this.ad,
    this.didShow = false,
  });

  @override
  String toString() {
    return "Ad: ${ad?.responseInfo?.responseId} - didShow: $didShow";
  }
}
