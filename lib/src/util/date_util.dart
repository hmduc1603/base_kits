import 'dart:ui';

import 'package:lit_relative_date_time/controller/relative_date_format.dart';
import 'package:lit_relative_date_time/model/relative_date_time.dart';

class DateUtil {
  static String getRelativeTimeFromString(String? dateAsString) {
    if (dateAsString == null) {
      return "-";
    }
    return const RelativeDateFormat(Locale('en')).format(RelativeDateTime(
        dateTime: DateTime.parse(dateAsString), other: DateTime.now()));
  }

  static String getRelativeTimeFromDate(DateTime? date) {
    if (date == null) {
      return "-";
    }
    return const RelativeDateFormat(Locale('en'))
        .format(RelativeDateTime(dateTime: date, other: DateTime.now()));
  }
}
