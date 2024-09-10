import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/ics_service.dart';
import 'models/event.dart';
import 'widgets/event_display.dart';
import 'widgets/particles_widget.dart';
import 'widgets/animated_text.dart';
import 'utils/date_helpers.dart';
import 'themes/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
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
  String selectedLevel = 'BUT1';
  String selectedGroup = '1A';
  late List<Future<List<Event>>> futureEventsForWeek;
  DateTime selectedDate = DateTime.now();
  int currentPageIndex = DateTime.now().weekday - 1;
  bool isWeekend = false;
  bool showParticles = false; // Désactive les particules par défaut

  late Map<String, Color> currentTheme = currentColors;

  final Map<String, Map<String, String>> groupLinks = {
    'BUT1': {
      '1A':
          'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/677.ics',
      '1B':
          'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/678.ics',
      '2A':
          'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/680.ics',
      '2B':
          'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/681.ics',
      '3A':
          'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/683.ics',
      '3B':
          'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/684.ics',
      '4A':
          'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/686.ics',
      '4B':
          'https://flopedt.iut-blagnac.fr/fr/ics/INFO/structural_group/687.ics',
    },
    'BUT2': {
      '1A': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/691.ics',
      '1B': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/692.ics',
      '2A': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/694.ics',
      '2B': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/695.ics',
      '3A': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/697.ics',
    },
    'BUT3': {
      '1A': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/504.ics',
      '1B': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/505.ics',
      '2A': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/506.ics',
      '2B': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/507.ics',
      '3A': 'https://flopedt.iut-blagnac.fr/fr/ics/structural_group/705.ics',
    },
  };

  @override
  void initState() {
    super.initState();
    futureEventsForWeek = []; // Initialise avec une liste vide
    _loadSelectedGroup();
  }

  Future<void> _loadSelectedGroup() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLevel = prefs.getString('selectedLevel') ?? 'BUT1';
      selectedGroup = prefs.getString('selectedGroup') ?? '1A';
      futureEventsForWeek = _fetchEventsForWeek();
    });
  }

  Future<void> _saveSelectedGroup(String level, String group) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLevel', level);
    prefs.setString('selectedGroup', group);
  }

  Future<void> _selectDay() async {
    final today = DateTime.now();
    final firstDayOfWeek = isWeekend
        ? today.add(Duration(days: 8 - today.weekday))
        : today.subtract(Duration(days: today.weekday - 1));
    final daysOfWeek =
        List.generate(5, (index) => firstDayOfWeek.add(Duration(days: index)));

    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: currentTheme['background'],
          title: Text('Sélectionnez un jour',
              style: TextStyle(color: currentTheme['primaryText'])),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: daysOfWeek.map((date) {
                final formattedDate =
                    DateFormat('EEEE d MMMM', 'fr_FR').format(date);
                return ListTile(
                  title: Text(formattedDate,
                      style: TextStyle(color: currentTheme['primaryText'])),
                  onTap: () {
                    Navigator.of(context).pop(date);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    if (selectedDate != null) {
      setState(() {
        this.selectedDate = selectedDate;
        currentPageIndex =
            daysOfWeek.indexWhere((date) => date.day == selectedDate.day);
        futureEventsForWeek = _fetchEventsForWeek();
      });
    }
  }

  Future<List<Event>> fetchEventsForGroup(
      String level, String group, DateTime date) async {
    final url = groupLinks[level]![group]!;
    return await ICSService().fetchEvents(url, date);
  }

  List<Future<List<Event>>> _fetchEventsForWeek() {
    final today = DateTime.now();
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(5, (index) {
      final date = firstDayOfWeek.add(Duration(days: index));
      return fetchEventsForGroup(selectedLevel, selectedGroup, date);
    });
  }

  String getDisplayedDay(DateTime date) {
    return DateFormat('EEEE', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final weekdays = List.generate(5, (index) {
      final today = DateTime.now();
      final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
      return firstDayOfWeek.add(Duration(days: index));
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: currentTheme['background'],
            ),
          ),
          if (showParticles)
            Positioned.fill(
              child: ParticlesWidget(
                height: screenHeight,
                width: screenWidth,
              ),
            ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: currentTheme['headerBackground'],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: AnimatedText(),
            ),
          ),
          Positioned(
            top: 25,
            right: 20,
            child: PopupMenuButton<String>(
              onSelected: (String value) {
                setState(() {
                  if (value == 'Particules O/F') {
                    showParticles = !showParticles;
                  } else if (value == 'Changer de thème') {
                    currentTheme = currentTheme == currentColors
                        ? newColors
                        : currentColors;
                  }
                });
              },
              icon: Icon(
                Icons.menu,
                color: currentTheme['menuIcon'],
                size: 35,
              ),
              color: currentTheme['background'],
              itemBuilder: (BuildContext context) {
                return {'Particules O/F', 'Changer de thème'}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(
                      choice,
                      style: TextStyle(
                        color: currentTheme['primaryText'],
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
          Positioned(
            top: 80,
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _selectDay,
                        child: Text(
                          getDisplayedDay(weekdays[currentPageIndex]),
                          style: TextStyle(
                            color: currentTheme['primaryText'],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: selectedLevel,
                            onChanged: (String? newLevel) {
                              if (newLevel != null) {
                                setState(() {
                                  selectedLevel = newLevel;
                                  selectedGroup =
                                      groupLinks[selectedLevel]!.keys.first;
                                  futureEventsForWeek = _fetchEventsForWeek();
                                  _saveSelectedGroup(
                                      selectedLevel, selectedGroup);
                                });
                              }
                            },
                            dropdownColor: currentTheme['background'],
                            style: TextStyle(
                              color: currentTheme['primaryText'],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            items: groupLinks.keys
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            underline: Container(),
                            iconEnabledColor: currentTheme['primaryText'],
                            iconDisabledColor: currentTheme['primaryText'],
                          ),
                          SizedBox(width: 20),
                          DropdownButton<String>(
                            value: selectedGroup,
                            onChanged: (String? newGroup) {
                              if (newGroup != null) {
                                setState(() {
                                  selectedGroup = newGroup;
                                  futureEventsForWeek = _fetchEventsForWeek();
                                  _saveSelectedGroup(
                                      selectedLevel, selectedGroup);
                                });
                              }
                            },
                            dropdownColor: currentTheme['background'],
                            style: TextStyle(
                              color: currentTheme['primaryText'],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            items: groupLinks[selectedLevel]!
                                .keys
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            underline: Container(),
                            iconEnabledColor: currentTheme['primaryText'],
                            iconDisabledColor: currentTheme['primaryText'],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: 5, // Nombre de jours de la semaine
                    controller: PageController(initialPage: currentPageIndex),
                    onPageChanged: (index) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: EventDisplay(
                          futureEvents: futureEventsForWeek.isNotEmpty
                              ? futureEventsForWeek[index]
                              : Future.value([]),
                          currentTheme: currentTheme,
                        ),
                      );
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
}
