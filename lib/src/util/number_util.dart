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

  static double randomInRange(double start, double end) {
    final random = Random();
    return random.nextDouble() * (end - start) + start;
  }

  static int generateRandomNumber(int numberOfDigits) {
    if (numberOfDigits < 1) {
      throw ArgumentError('Number of digits must be at least 1');
    }
    int min = pow(10, numberOfDigits - 1).toInt();
    int max = pow(10, numberOfDigits).toInt() - 1;
    var random = Random();
    return min + random.nextInt(max - min + 1);
  }
}
