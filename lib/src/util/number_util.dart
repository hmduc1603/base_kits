import 'dart:math';

import 'package:number_display/number_display.dart';

class NumberUtil {
  static String displayAsPrice(double value,
      {int length = 10, int decimal = 0}) {
    final display = createDisplay(length: length, decimal: decimal);
    return display(value);
  }

  static int getRandomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }
}
