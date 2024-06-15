// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:base_kits/base_kits.dart';

part 'ad_config.g.dart';

@JsonSerializable()
class AdConfig {
  final bool enableInterstitialAd;
  final bool enableOpenAd;
  final bool enableBannerAd;
  final bool enableRewardAd;
  final AdLimitation adLimitation;
  AdConfig({
    required this.enableInterstitialAd,
    required this.enableOpenAd,
    required this.enableBannerAd,
    this.enableRewardAd = false,
    required this.adLimitation,
  });

  factory AdConfig.fromJson(Map<String, dynamic> json) =>
      _$AdConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AdConfigToJson(this);
}

class AdUnitConfig {
  final String adId;
  final String bannerId;
  final String appOpenId;
  final String rewardId;
  final String interstitialId;

  AdUnitConfig({
    required this.bannerId,
    required this.appOpenId,
    required this.rewardId,
    required this.interstitialId,
    required this.adId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bannerId': bannerId,
      'appOpenId': appOpenId,
      'rewardId': rewardId,
      'adId': adId,
      'interstitialId': interstitialId,
    };
  }

  factory AdUnitConfig.fromMap(Map<String, dynamic> map) {
    return AdUnitConfig(
      bannerId: map['bannerId'] as String,
      appOpenId: map['appOpenId'] as String,
      rewardId: map['rewardId'] as String,
      interstitialId: map['interstitialId'] as String,
      adId: map['adId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AdUnitConfig.fromJson(String source) =>
      AdUnitConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}
