import 'package:json_annotation/json_annotation.dart';

part 'local_purchase_entity.g.dart';

@JsonSerializable()
class LocalPurchaseEntity {
  int purchasedDateInMillisecond;
  String productId;
  String? purchaseId;

  LocalPurchaseEntity({
    required this.purchasedDateInMillisecond,
    required this.productId,
    this.purchaseId,
  });

  factory LocalPurchaseEntity.fromJson(Map<String, dynamic> json) =>
      _$LocalPurchaseEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LocalPurchaseEntityToJson(this);
}
