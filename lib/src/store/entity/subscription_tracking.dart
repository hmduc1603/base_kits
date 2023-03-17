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
    params.forEach((key, value) {
      data[key] = value;
    });
    return data;
  }

  update({
    String? screenName,
    String? productId,
    double? value,
    String? criteria,
    Map<String, dynamic>? params,
  }) {
    if (screenName != null) {
      this.screenName = screenName;
    }
    if (productId != null) {
      this.productId = productId;
    }
    if (value != null) {
      this.value = value;
    }
    if (criteria != null) {
      this.criteria = criteria;
    }
    if (params != null) {
      this.params = params;
    }
    log("tracking updated:${toMap()}", name: "SubscriptionTracking");
  }
}
