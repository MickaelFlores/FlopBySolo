import 'package:http/http.dart' as http;
import '../models/event.dart';

class ICSService {
  Future<List<Event>> fetchEvents(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final icsData = response.body;
      final events = _parseICS(icsData);
      events.sort((a, b) =>
          a.start.compareTo(b.start)); // Tri des événements par date de début

      // Filtrer les événements pour n'inclure que ceux du jour
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      return events
          .where((event) =>
              event.start.isAfter(startOfDay) && event.start.isBefore(endOfDay))
          .toList();
    } else {
      throw Exception('Failed to load ICS data');
    }
  }

  List<Event> _parseICS(String icsData) {
    final events = <Event>[];

    final eventStrings = icsData.split('BEGIN:VEVENT').skip(1);
    for (var eventString in eventStrings) {
      final event = Event.fromICS(eventString);
      events.add(event);
    }

    return events;
  }
}
