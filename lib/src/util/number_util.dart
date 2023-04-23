import 'package:number_display/number_display.dart';

class NumberUtil {
  static String displayAsPrice(double value) {
    final display = createDisplay(length: 10, decimal: 0);
    return display(value);
  }
}
