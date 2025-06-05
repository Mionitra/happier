import 'package:flutter/material.dart';

class NoteForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? existingNote;
  final List<String> themes;

  const NoteForm({
    Key? key,
    required this.onSave,
    this.existingNote,
    required this.themes,
  }) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  late TextEditingController _noteController;
  String? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.existingNote != null ? widget.existingNote!['note'] : '',
    );
    _selectedTheme = widget.existingNote != null
        ? widget.existingNote!['theme']
        : (widget.themes.isNotEmpty ? widget.themes[0] : null);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_noteController.text.trim().isEmpty || _selectedTheme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Merci de saisir une note et choisir un thème.")),
      );
      return;
    }

    final noteData = {
      'note': _noteController.text.trim(),
      'theme': _selectedTheme!,
    };

    widget.onSave(noteData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote != null ? 'Modifier la note' : 'Nouvelle note'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Enregistrer',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Votre note',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              items: widget.themes
                  .map((theme) => DropdownMenuItem(
                        value: theme,
                        child: Text(theme),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedTheme = val;
                });
              },
              decoration: InputDecoration(
                labelText: 'Choisir un thème',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
