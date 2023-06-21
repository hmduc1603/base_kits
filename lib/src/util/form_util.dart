class FormUtil {
  static String? validateEmail(
      String? value, String onEmpty, String onInvalid) {
    if (value == null) return null;
    if (value.isEmpty) return onEmpty;
    const pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    return RegExp(pattern).hasMatch(value) ? null : onInvalid;
  }

  static String? validateUrl(String? value, String onEmpty, String onInvalid) {
    if (value == null) return null;
    if (value.isEmpty) return onEmpty;
    const pattern =
        r'[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';
    return RegExp(pattern).hasMatch(value) ? null : onInvalid;
  }

  static String? validateEmpty(String? value,
      {String onEmpty = "Please input this field!"}) {
    if (value == null) return null;
    if (value.isEmpty) return onEmpty;
    return null;
  }

  static String? validateMatching(
      String? value, String? matchValue, String onEmpty, String onNotMatch) {
    if (value == null || matchValue == null) return null;
    if (value.isEmpty) return onEmpty;
    if (value != matchValue) return onNotMatch;
    return null;
  }

  static String? validatePassword(
      String? value, String onEmpty, String onInvalid) {
    if (value == null) return null;
    if (value.isEmpty) return onEmpty;
    if (value.length < 8) return onInvalid;
    return null;
  }

  static String? validateLength(
      String? value, int number, String onEmpty, String onInvalid) {
    if (value == null) return null;
    if (value.isEmpty) return onEmpty;
    if (value.length <= number) return onInvalid;
    return null;
  }

  static String? validateMaximumLength(
      String? value, int number, String onInvalid) {
    if (value == null) return null;
    if (value.length > number) return onInvalid;
    return null;
  }
}
