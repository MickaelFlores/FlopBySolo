import 'dart:math';
import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_engine.dart';
import 'package:particles_flutter/component/particle/particle.dart';
import 'services/ics_service.dart';
import 'models/event.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventListScreen(),
    );
  }
}

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String selectedGroup = '1A'; // Valeur par défaut
  late Future<List<Event>> futureEvents;

  // Liste des liens pour les groupes
  final Map<String, String> groupLinks = {
    '1A': 'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/677.ics',
    '1B': 'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/678.ics',
    '2A': 'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/680.ics',
    '2B': 'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/681.ics',
    '3A': 'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/683.ics',
    '3B': 'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/684.ics',
    '4A': 'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/686.ics',
    '4B': 'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/687.ics',
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedGroup();
  }

  Future<void> _loadSelectedGroup() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGroup =
          prefs.getString('selectedGroup') ?? '1A'; // Valeur par défaut
      futureEvents = fetchEventsForGroup(selectedGroup);
    });
  }

  Future<void> _saveSelectedGroup(String group) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedGroup', group);
  }

  Future<List<Event>> fetchEventsForGroup(String group) async {
    final url = groupLinks[group]!;
    return await ICSService().fetchEvents(url);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Fond de particules
          Positioned.fill(
            child: Container(
              color: Colors.black, // Couleur de fond sombre
              child: Particles(
                awayRadius:
                    100, // Réduit la distance à laquelle les particules se déplacent lorsqu'elles sont éloignées
                particles: createParticles(),
                height: screenHeight,
                width: screenWidth,
                onTapAnimation: true,
                awayAnimationDuration: const Duration(milliseconds: 150),
                awayAnimationCurve: Curves.easeOut,
                enableHover: true,
                hoverRadius: 60,
                connectDots: false,
              ),
            ),
          ),

          // En-tête flottant
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.0),
              color:
                  Colors.black.withOpacity(0.7), // Fond légèrement transparent
              child: Text(
                'Flop By Solo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Interface utilisateur principale
          Positioned(
            top: 80, // Ajustez cette valeur selon la hauteur de l'en-tête
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    value: selectedGroup,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroup = newValue!;
                        futureEvents = fetchEventsForGroup(selectedGroup);
                        _saveSelectedGroup(selectedGroup);
                      });
                    },
                    dropdownColor:
                        Colors.grey[800], // Couleur de fond du menu déroulant
                    style: TextStyle(
                      color: Colors.cyan, // Couleur du texte du menu déroulant
                      fontSize: 18, // Taille du texte
                      fontWeight: FontWeight.bold, // Poids du texte
                    ),
                    items: groupLinks.keys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          'BUT1 $value',
                          style: TextStyle(
                            color: Colors
                                .cyan, // Couleur du texte des éléments du menu
                            fontSize:
                                18, // Taille du texte des éléments du menu
                            fontWeight: FontWeight.bold, // Poids du texte
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Event>>(
                    future: futureEvents,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Erreur: ${snapshot.error}',
                                style: TextStyle(color: Colors.orange)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text(
                          'Aucun cours pour aujourd\'hui.',
                          style: TextStyle(
                            color: Colors.lightGreen, // Couleur du texte
                            fontSize: 22, // Taille du texte
                            fontWeight: FontWeight.bold, // Poids du texte
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                color: Colors.black.withOpacity(0.7),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ));
                      } else {
                        final events = snapshot.data!;
                        return ListView(
                          children: events.map((event) {
                            final formattedStart =
                                DateFormat('HH:mm').format(event.start);
                            final formattedEnd =
                                DateFormat('HH:mm').format(event.end);
                            final formattedDate = event.getFormattedDate();

                            return ListTile(
                              title: Text(
                                event.summary,
                                style: TextStyle(
                                  color: Colors.pink, // Couleur du texte
                                  fontSize: 18, // Taille du texte
                                  fontWeight: FontWeight.bold, // Poids du texte
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
                                '$formattedDate\n$formattedStart - $formattedEnd\nSalle: ${event.location}',
                                style: TextStyle(
                                  color: Colors.lightBlue, // Couleur du texte
                                  fontSize: 16, // Taille du texte
                                  fontWeight: FontWeight.bold, // Poids du texte
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
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Particle> createParticles() {
    var rng = Random();
    List<Particle> particles = [];
    List<Color> colors = [
      Colors.white,
      Colors.green,
      Colors.red,
      Colors.yellow,
    ];
    for (int i = 0; i < 40; i++) {
      // Réduit le nombre de particules
      particles.add(Particle(
        color: colors[rng.nextInt(colors.length)]
            .withOpacity(0.4), // Couleurs des particules
        size: rng.nextDouble() * 6 +
            2, // Taille ajustée pour une meilleure visibilité
        velocity: Offset(
            rng.nextDouble() *
                50 *
                randomSign(), // Réduit la vitesse des particules
            rng.nextDouble() * 50 * randomSign()),
      ));
    }
    return particles;
  }

  double randomSign() {
    var rng = Random();
    return rng.nextBool() ? 1 : -1;
  }
}
