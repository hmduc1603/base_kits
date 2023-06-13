abstract class BaseHandler {
  void logPurchase(String currency, double price);
  void sendEvent(String name, Map<String, dynamic>? value);
}
