import 'dart:math';

class StringUtil {
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return "";
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  static String? convertToUrl(String? text) {
    if (text == null) {
      return null;
    }
    if (!text.contains('https://') ||
        !text.contains('http://') ||
        !text.contains('www.')) {
      return 'https://$text';
    }
    return text;
  }

  static String generateRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
