import 'package:date_format/date_format.dart';

class DateTimeFormat {
  ///短日期格式
  static String toShort(int unixTime) {
    if (unixTime == 0) return "";
    return formatDate(
        DateTime.fromMillisecondsSinceEpoch(unixTime), [mm, "月", dd, "日"]);
  }

  ///长日期格式
  static String toLong(int unixTime) {
    if (unixTime == 0) return "";
    return formatDate(DateTime.fromMillisecondsSinceEpoch(unixTime),
        [yyyy, "-", mm, "-", dd, " ", HH, ":", nn, ":", ss]);
  }
}
