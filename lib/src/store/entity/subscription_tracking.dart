import 'dart:developer';

class SubscriptionTracking {
  static final SubscriptionTracking _instance =
      SubscriptionTracking._internal();
  SubscriptionTracking._internal();
  factory SubscriptionTracking() => _instance;

  String screenName = '';
  String productId = '';
  double value = 0;
  String criteria = '';
  Map<String, dynamic> params = {};

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'screenName': screenName,
      'productId': productId,
      'value': value,
      'criteria': criteria,
    };
    return data;
  }

  update({
    String? screenName,
    String? productId,
    double? value,
    String? criteria,
    Map<String, dynamic>? params,
  }) {
    this.screenName = screenName ?? this.screenName;
    this.productId = productId ?? this.productId;
    this.value = value ?? this.value;
    this.criteria = criteria ?? "";
    this.params = params ?? {};

    log("tracking updated:${toMap()}", name: "SubscriptionTracking");
  }
}
