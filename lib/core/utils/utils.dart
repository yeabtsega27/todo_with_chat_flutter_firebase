import 'package:intl/intl.dart';

String formatDate(String dateTimeString) {
  DateTime now = DateTime.now();
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Calculate difference in days
  int dayDifference = now.difference(dateTime).inDays;

  if (dayDifference == 0) {
    // If it's today, show "today"
    return "Today ${DateFormat('hh:mm a').format(dateTime)}";
  } else if (dayDifference == 1) {
    // If it's yesterday, show "yesterday"
    return "Yesterday ${DateFormat('hh:mm a').format(dateTime)}";
  } else if (now.year == dateTime.year && now.month == dateTime.month) {
    // If it's the same month, show only the day
    return "${DateFormat('d').format(dateTime)} ${DateFormat('hh:mm a').format(dateTime)}";
  } else if (now.year == dateTime.year) {
    // If it's the same year but a different month, show month and day
    return "${DateFormat('MMM d').format(dateTime)} ${DateFormat('hh:mm a').format(dateTime)}";
  } else {
    // For dates in previous years, include year as well
    return "${DateFormat('MMM d, yyyy').format(dateTime)} ${DateFormat('hh:mm a').format(dateTime)}";
  }
}
