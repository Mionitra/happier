import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_form.dart';
import 'quote_list_page.dart';


// Fonction pour couleur texte lisible
Color textColorForBackground(Color background) {
  double luminance = background.computeLuminance();
  return luminance > 0.5 ? Colors.black : Colors.white;
}

class NotesPage extends StatefulWidget {
  final String mood;
  final DateTime date;
  final List<Map<String, dynamic>> existingNotes;
  final Function(Map<String, dynamic>) onNoteAdded;

  const NotesPage({
    Key? key,
    required this.mood,
    required this.date,
    required this.existingNotes,
    required this.onNoteAdded,
  }) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Map<String, dynamic>> _notes;

  final List<String> _themes = [
    'Réussite',
    'Connexion',
    'Croissance personnelle',
    'Passion',
    'Calme',
    'Gratitude pure',
    'Contribution',
    'Objectif',
    'Inspiration',
  ];

  final Map<String, Color> _themeColors = {
    'Réussite': Colors.greenAccent,
    'Connexion': Colors.pinkAccent,
    'Croissance personnelle': Colors.lightBlueAccent,
    'Passion': Colors.orangeAccent,
    'Calme': Colors.deepPurpleAccent,
    'Gratitude pure': Colors.yellowAccent,
    'Contribution': Colors.blueGrey,
    'Objectif': Colors.indigoAccent,
    'Inspiration': Colors.tealAccent,
  };

  @override
  void initState() {
    super.initState();
    _notes = List.from(widget.existingNotes);
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteForm(
          onSave: (noteData) {
            setState(() {
              _notes.add(noteData);
            });
            widget.onNoteAdded(noteData);
            Navigator.pop(context, noteData);
          },
          themes: _themes,
        ),
      ),
    );

    if (result != null) {
      final themeName = result['theme'] as String;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note ajoutée avec le thème "$themeName"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Mes Notes'),
  actions: [
    IconButton(
      icon: Icon(Icons.format_quote),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuoteListPage()),
        );
      },
      tooltip: 'Voir des citations',
    )
  ],
),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          final themeName = note['theme'] as String? ?? 'Sans thème';
          final bgColor = _themeColors[themeName] ?? Colors.grey.shade200;
          final txtColor = textColorForBackground(bgColor);

          return Card(
            color: bgColor,
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              title: Text(
                note['note'],
                style: TextStyle(color: txtColor),
              ),
              subtitle: Text(
                'Thème : $themeName',
                style: TextStyle(color: txtColor.withOpacity(0.7)),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: txtColor),
                onPressed: () {
                  setState(() {
                    _notes.removeAt(index);
                  });
                  // Sauvegarder la suppression dans ton parent si besoin
                },
              ),
              onTap: () async {
                final updatedNote = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteForm(
                      onSave: (noteData) {
                        setState(() {
                          _notes[index] = noteData;
                        });
                        widget.onNoteAdded(noteData);
                        Navigator.pop(context, noteData);
                      },
                      existingNote: note,
                      themes: _themes,
                    ),
                  ),
                );

                if (updatedNote != null) {
                  final updatedTheme = updatedNote['theme'] as String? ?? 'Sans thème';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Note modifiée avec le thème "$updatedTheme"')),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
      ),
    );
  }
}
