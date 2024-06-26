// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingEntity _$RatingEntityFromJson(Map<String, dynamic> json) => RatingEntity(
      isRequested: json['isRequested'] as bool? ?? false,
      lastRequestedDateInMilliseconds:
          (json['lastRequestedDateInMilliseconds'] as num).toInt(),
    );

Map<String, dynamic> _$RatingEntityToJson(RatingEntity instance) =>
    <String, dynamic>{
      'isRequested': instance.isRequested,
      'lastRequestedDateInMilliseconds':
          instance.lastRequestedDateInMilliseconds,
    };
