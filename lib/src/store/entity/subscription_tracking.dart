class SubscriptionTracking {
  static final SubscriptionTracking _instance =
      SubscriptionTracking._internal();
  SubscriptionTracking._internal();
  factory SubscriptionTracking() => _instance;

  String screenName = '';
  String sourceName = '';
  String productId = '';
}
