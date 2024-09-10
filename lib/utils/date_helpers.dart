import 'package:intl/intl.dart';

List<DateTime> getDaysOfWeek(DateTime today, bool isWeekend) {
  final firstDayOfWeek = isWeekend
      ? today.add(Duration(days: 8 - today.weekday))
      : today.subtract(Duration(days: today.weekday - 1));
  return List.generate(
      5,
      (index) => firstDayOfWeek
          .add(Duration(days: index))); // Exclude Saturday and Sunday
}

String formatDisplayedDay(DateTime selectedDate, bool isWeekend) {
  final now = DateTime.now();
  final weekday = now.weekday;

  if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
    isWeekend = true;
    final nextMonday = now.add(Duration(days: 8 - weekday));
    return DateFormat('EEEE', 'fr_FR').format(nextMonday);
  } else {
    isWeekend = false;
    return DateFormat('EEEE', 'fr_FR').format(now);
  }
}
