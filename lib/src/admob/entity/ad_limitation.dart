import 'package:json_annotation/json_annotation.dart';

part 'ad_limitation.g.dart';

@JsonSerializable()
class AdLimitation {
  final int dailyInterstitialLimitation;
  final int showInterstitialAfterEveryNumber;
  const AdLimitation({
    this.dailyInterstitialLimitation = 1,
    this.showInterstitialAfterEveryNumber = 2,
  });

  factory AdLimitation.fromJson(Map<String, dynamic> json) =>
      _$AdLimitationFromJson(json);

  Map<String, dynamic> toJson() => _$AdLimitationToJson(this);
}
