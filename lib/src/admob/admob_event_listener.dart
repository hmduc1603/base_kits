import 'package:easy_ads_flutter/easy_ads_flutter.dart';

mixin AdmobEventListener {
  onOpenAdEvent(AdEventType adEventType);
  onInterstitialAdEvent(AdEventType adEventType);
  onBannerAdEvent(AdEventType adEventType);
  onRewardAdEvent(AdEventType adEventType);
}
