// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingEntity _$RatingEntityFromJson(Map<String, dynamic> json) => RatingEntity(
      count: json['count'] as int,
      lastRequestedDateInMilliseconds:
          json['lastRequestedDateInMilliseconds'] as int,
    );

Map<String, dynamic> _$RatingEntityToJson(RatingEntity instance) =>
    <String, dynamic>{
      'count': instance.count,
      'lastRequestedDateInMilliseconds':
          instance.lastRequestedDateInMilliseconds,
    };
