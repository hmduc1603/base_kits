import 'dart:convert';

class AdConfig {
  final String adId;
  final String bannerId;
  final String appOpenId;
  final String rewardId;
  final String interstitialId;
  AdConfig({
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

  factory AdConfig.fromMap(Map<String, dynamic> map) {
    return AdConfig(
      bannerId: map['bannerId'] as String,
      appOpenId: map['appOpenId'] as String,
      rewardId: map['rewardId'] as String,
      interstitialId: map['interstitialId'] as String,
      adId: map['adId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AdConfig.fromJson(String source) =>
      AdConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}
