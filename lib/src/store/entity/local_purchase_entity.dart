import 'package:hive/hive.dart';

part 'local_purchase_entity.g.dart';

@HiveType(typeId: 0)
class LocalPurchaseEntity extends HiveObject {
  @HiveField(0)
  String purchasedDateInMillisecond;
  @HiveField(1)
  String productId;

  LocalPurchaseEntity({
    required this.purchasedDateInMillisecond,
    required this.productId,
  });
}
