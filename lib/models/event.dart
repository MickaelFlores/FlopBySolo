import 'package:intl/intl.dart';

class Event {
  final String summary;
  final DateTime start;
  final DateTime end;
  final String location;
  final String subject; // Matière associée

  Event({
    required this.summary,
    required this.start,
    required this.end,
    required this.location,
    required this.subject,
  });

  static DateTime parseDate(String dateString) {
    final year = int.parse(dateString.substring(0, 4));
    final month = int.parse(dateString.substring(4, 6));
    final day = int.parse(dateString.substring(6, 8));
    final hour = int.parse(dateString.substring(9, 11));
    final minute = int.parse(dateString.substring(11, 13));
    final second = int.parse(dateString.substring(13, 15));
    return DateTime(year, month, day, hour, minute, second);
  }

  factory Event.fromICS(String icsString) {
    final start = parseDate(
        icsString.split('DTSTART;VALUE=DATE-TIME:')[1].split('\n')[0]);
    final end =
        parseDate(icsString.split('DTEND;VALUE=DATE-TIME:')[1].split('\n')[0]);
    final summary = icsString.split('SUMMARY:')[1].split('\n')[0];
    final location = icsString.split('LOCATION:')[1].split('\n')[0];
    final subject = extractSubjectFromSummary(summary);

    return Event(
      summary: summary,
      start: start,
      end: end,
      location: location,
      subject: subject,
    );
  }

  static String extractSubjectFromSummary(String summary) {
    // Exemple simple pour extraire la matière à partir du résumé
    // Adaptez cette fonction selon le format réel de vos données
    return summary.split(' ')[0];
  }

  String getFormattedDate() {
    return DateFormat('dd MMMM yyyy').format(start);
  }
}
