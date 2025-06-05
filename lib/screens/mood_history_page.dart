import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mood_entry.dart';

class MoodHistoryPage extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const MoodHistoryPage({Key? key, required this.moodEntries})
    : super(key: key);

  @override
  _MoodHistoryPageState createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<MoodHistoryPage> {
  late final Map<DateTime, String> moodMap;

  @override
  void initState() {
    super.initState();

    // 🟡 Important : arrondir la date à 00:00 pour chaque humeur enregistrée
    moodMap = {
      for (var entry in widget.moodEntries)
        DateTime(entry.date.year, entry.date.month, entry.date.day): entry.mood,
    };

    // Vérifie en console si les données sont bien là
    print("📝 Humeurs enregistrées :");
    moodMap.forEach((date, mood) {
      print("$date : $mood");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historique des humeurs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(fontSize: 16),
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: Colors.white),
          ),
          eventLoader: (day) {
            final normalizedDay = DateTime(day.year, day.month, day.day);
            final mood = moodMap[normalizedDay];
            return mood != null ? [mood] : [];
          },

          calendarBuilders: CalendarBuilders(
  markerBuilder: (context, day, events) {
    if (events.isNotEmpty) {
      final mood = events.first.toString();
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            _moodToEmoji(mood),
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  },
),

        ),
      ),
    );
  }

  String _moodToEmoji(String mood) {
    switch (mood) {
      case "Heureux":
        return "😊";
      case "Neutre":
        return "😐";
      case "Triste":
        return "😢";
      case "Énervé":
        return "😠";
      default:
        return "❓";
    }
  }
}
