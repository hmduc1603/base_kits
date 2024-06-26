// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_limitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdLimitation _$AdLimitationFromJson(Map<String, dynamic> json) => AdLimitation(
      dailyInterstitialLimitation:
          (json['dailyInterstitialLimitation'] as num?)?.toInt() ?? 1,
      showInterstitialAfterEveryNumber:
          (json['showInterstitialAfterEveryNumber'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$AdLimitationToJson(AdLimitation instance) =>
    <String, dynamic>{
      'dailyInterstitialLimitation': instance.dailyInterstitialLimitation,
      'showInterstitialAfterEveryNumber':
          instance.showInterstitialAfterEveryNumber,
    };
