// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdConfig _$AdConfigFromJson(Map<String, dynamic> json) => AdConfig(
      enableInterstitialAd: json['enableInterstitialAd'] as bool,
      enableOpenAd: json['enableOpenAd'] as bool,
      enableBannerAd: json['enableBannerAd'] as bool,
      enableRewardAd: json['enableRewardAd'] as bool? ?? false,
      adLimitation:
          AdLimitation.fromJson(json['adLimitation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdConfigToJson(AdConfig instance) => <String, dynamic>{
      'enableInterstitialAd': instance.enableInterstitialAd,
      'enableOpenAd': instance.enableOpenAd,
      'enableBannerAd': instance.enableBannerAd,
      'enableRewardAd': instance.enableRewardAd,
      'adLimitation': instance.adLimitation,
    };
