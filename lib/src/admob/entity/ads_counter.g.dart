// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_counter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdsCounter _$AdsCounterFromJson(Map<String, dynamic> json) => AdsCounter(
      updatedDate: DateTime.parse(json['updatedDate'] as String),
      adsCounting: json['adsCounting'] as int,
    );

Map<String, dynamic> _$AdsCounterToJson(AdsCounter instance) =>
    <String, dynamic>{
      'adsCounting': instance.adsCounting,
      'updatedDate': instance.updatedDate.toIso8601String(),
    };
