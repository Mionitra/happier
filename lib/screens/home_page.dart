import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'mood_history_page.dart';
import 'package:happier/models/mood_entry.dart';
import 'notes_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'name_input_page.dart';
import 'dart:convert'; // pour encoder/décoder JSON

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({Key? key, required this.userName}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedMood;
  List<MoodEntry> moodHistory = [];
  Map<DateTime, List<Map<String, dynamic>>> notesByDate = {};
  @override
  void initState() {
    super.initState();
    _loadNotesFromPrefs();
  }

  /// Charger les notes sauvegardées depuis SharedPreferences
  Future<void> _loadNotesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notesByDate');
    if (data != null) {
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(
        jsonDecode(data),
      );
      setState(() {
        notesByDate = decoded.map((key, value) {
          final date = DateTime.parse(key);
          final notes = List<Map<String, dynamic>>.from(
            value.map((item) => Map<String, dynamic>.from(item)),
          );
          return MapEntry(date, notes);
        });
      });
    }
  }

  /// Sauvegarder les notes dans SharedPreferences
  Future<void> _saveNotesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      notesByDate.map((key, value) {
        return MapEntry(key.toIso8601String(), value);
      }),
    );
    await prefs.setString('notesByDate', jsonString);
  }

  void _changeUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NameInputPage()),
    );
  }

  void _selectMood(String mood) {
    setState(() {
      selectedMood = mood;
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = MoodEntry(date: today, mood: mood);

    moodHistory.removeWhere((e) => e.date == today);
    moodHistory.add(entry);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Humeur enregistrée : $mood")));

    Future.delayed(Duration(milliseconds: 500), () async {
      final newNote = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => NotesPage(
                mood: mood,
                date: today,
                existingNotes: notesByDate[today] ?? [],
                onNoteAdded: (note) {
                  setState(() {
                    notesByDate.putIfAbsent(today, () => []);
                    notesByDate[today]!.add(note);
                    _saveNotesToPrefs(); // ➕ On sauvegarde
                  });
                },
              ),
        ),
      );

      if (newNote != null) {
        // Si tu veux faire autre chose avec la note retournée
        print("Nouvelle note reçue : $newNote");
      }
    });
  }

  void _goToHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodHistoryPage(moodEntries: moodHistory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Changer de nom',
            onPressed: _changeUserName,
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _goToHistoryPage,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${widget.userName} 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Comment vous sentez-vous aujourd’hui ?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _emojiButton("😊", "Heureux"),
                _emojiButton("😐", "Neutre"),
                _emojiButton("😢", "Triste"),
                _emojiButton("😠", "Énervé"),
              ],
            ),
            if (selectedMood != null) ...[
              SizedBox(height: 40),
              Text(
                'Vous vous sentez : $selectedMood',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ],
            Spacer(),
            ElevatedButton.icon(
              onPressed: _goToHistoryPage,
              icon: Icon(Icons.calendar_month),
              label: Text('Voir l’historique'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emojiButton(String emoji, String moodLabel) {
    return GestureDetector(
      onTap: () => _selectMood(moodLabel),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 40)),
          SizedBox(height: 4),
          Text(moodLabel, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
