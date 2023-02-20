import 'package:hive/hive.dart';

part 'ads_counter.g.dart';

@HiveType(typeId: 3)
class AdsCounter extends HiveObject {
  @HiveField(0)
  int adsCounting;
  @HiveField(1)
  DateTime updatedDate;

  AdsCounter({
    required this.updatedDate,
    required this.adsCounting,
  });

  resetToNewDay() {
    adsCounting = 0;
  }
}
