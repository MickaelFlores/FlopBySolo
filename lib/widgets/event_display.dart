import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EventDisplay extends StatelessWidget {
  final Future<List<Event>> futureEvents;
  final Map<String, Color> currentTheme;

  EventDisplay({required this.futureEvents, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Tout vient à point \nà qui sait attendre ❤',
                    style: TextStyle(
                      color: currentTheme['primaryText'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  color: currentTheme['primaryText'], // Modifier la couleur ici
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur: ${snapshot.error}',
              style: TextStyle(color: Colors.orange),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Aucun cours pour aujourd\'hui.',
              style: TextStyle(
                color: currentTheme['primaryText'],
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          );
        } else {
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              List<Widget> eventWidgets = [];

              // Insère un espacement avant le déjeuner
              if (index > 0 &&
                  events[index - 1].end.hour <= 12 &&
                  event.start.hour >= 13) {
                eventWidgets.add(
                    SizedBox(height: 0)); // Espacement pour la pause déjeuner
                eventWidgets.add(
                  Container(
                    height: 60, // Ajustez la hauteur selon vos besoins
                    child: Center(
                      child: Text(
                        'Bon appétit ! 🍽️',
                        style: TextStyle(
                          color: currentTheme['primaryText'],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
                eventWidgets.add(Divider(
                    color: currentTheme[
                        'secondaryText'])); // Trait horizontal après la pause déjeuner
              } else if (index > 0 &&
                  !(events[index - 1].end.hour <= 12 &&
                      event.start.hour >= 13) &&
                  event.start.difference(events[index - 1].end).inHours >= 1) {
                // Insère un espacement supplémentaire si l'écart entre deux cours est supérieur à une heure
                eventWidgets.add(SizedBox(
                    height: 12)); // Espacement supplémentaire de 20 pixels
                eventWidgets.add(Divider(
                    color: currentTheme[
                        'secondaryText'])); // Trait horizontal après l'espacement supplémentaire
              }

              eventWidgets.add(buildEventCard(
                  event, context, index, index == events.length - 1));

              return Column(children: eventWidgets);
            },
          );
        }
      },
    );
  }

  Widget buildEventCard(
      Event event, BuildContext context, int index, bool isLast) {
    return Column(
      children: <Widget>[
        Card(
          color: currentTheme['background']!.withOpacity(0.2),
          elevation: 4.0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(event.start),
                  style: TextStyle(
                    color: currentTheme['primaryText'],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(event.end),
                  style: TextStyle(
                    color: currentTheme['secondaryText'],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            title: Text(
              event.summary,
              style: TextStyle(
                color: currentTheme['primaryText'],
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            subtitle: Text(
              'Salle: ${event.location}',
              style: TextStyle(
                color: currentTheme['secondaryText'],
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) Divider(color: currentTheme['secondaryText']),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 100).ms)
        .slideY(begin: 0.3, duration: 300.ms);
  }
}
