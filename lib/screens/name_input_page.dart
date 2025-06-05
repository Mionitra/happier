import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class NameInputPage extends StatefulWidget {
  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    print('Nom enregistré : $name');

    // Ajoute cette ligne :
    final checkName = prefs.getString('userName');
    print('Nom vérifié après enregistrement : $checkName');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenue')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Comment t\'appelles-tu ?', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ton nom',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveName(),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveName, child: Text('Valider')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
