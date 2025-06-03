import 'package:intl/intl.dart';

DateTime stringToDate(String dateString, {String formatStr = "yyyy-MM-dd"}) {
  try {
    return DateFormat(formatStr).parse(dateString);
  } catch (e) {
    return DateTime.now();
  }
}

String getStringDateToOtherFormate(String dateString, {String formatStr = "yyyy-MM-dd", String outFormatStr = "yyyy-MM-dd"}) {
  try {
    DateTime date = DateFormat(formatStr).parse(dateString);
    return DateFormat(outFormatStr).format(date);
  } catch (e) {
    return dateString;
  }
}

DateTime dateToStartDate(DateTime date) {
  try {
    return DateTime(date.year, date.month, date.day);
  } catch (e) {
    return date;
  }
}

String dateToString(DateTime date, {String formatStr = "yyyy-MM-dd"}) {
  try {
    return DateFormat(formatStr).format(date);
  } catch (e) {
    return "";
  }
}

String getTime(int minutesFromMidnight) {
  try {
    int hour = (minutesFromMidnight ~/ 60) % 24;
    return '${hour.toString().padLeft(2, '0')}:00';
  } catch (e) {
    return "00:00";
  }
}

String getDayTitle(String dateStr) {
  try {
    DateTime date = DateFormat("dd/MM/yyyy hh:mm aa").parse(dateStr);
    return DateFormat("E").format(date);
  } catch (e) {
    return "";
  }
}

extension DateHelpers on DateTime {
  bool get isToday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 0;
  }

  bool get isYesterday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == -1;
  }

  bool get isTomorrow {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 1;
  }
}
