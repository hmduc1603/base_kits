import 'package:json_annotation/json_annotation.dart';

part 'ads_counter.g.dart';

@JsonSerializable()
class AdsCounter {
  int adsCounting;
  DateTime updatedDate;

  AdsCounter({
    required this.updatedDate,
    required this.adsCounting,
  });

  resetToNewDay() {
    adsCounting = 0;
  }

  factory AdsCounter.fromJson(Map<String, dynamic> json) =>
      _$AdsCounterFromJson(json);

  Map<String, dynamic> toJson() => _$AdsCounterToJson(this);
}
