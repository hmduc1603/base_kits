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
    data.addAll(params);
    return data;
  }

  update({
    String? screenName,
    String? productId,
    double? value,
    String? criteria,
    Map<String, dynamic>? params,
  }) {
    screenName = screenName ?? this.screenName;
    productId = productId ?? this.productId;
    value = value ?? this.value;
    criteria = criteria ?? "";
    params = params ?? {};
  }
}
