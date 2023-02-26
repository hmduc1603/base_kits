// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_purchase_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalPurchaseEntity _$LocalPurchaseEntityFromJson(Map<String, dynamic> json) =>
    LocalPurchaseEntity(
      purchasedDateInMillisecond: json['purchasedDateInMillisecond'] as String,
      productId: json['productId'] as String,
    );

Map<String, dynamic> _$LocalPurchaseEntityToJson(
        LocalPurchaseEntity instance) =>
    <String, dynamic>{
      'purchasedDateInMillisecond': instance.purchasedDateInMillisecond,
      'productId': instance.productId,
    };
