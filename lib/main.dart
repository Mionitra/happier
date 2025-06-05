import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_page.dart';
import 'screens/name_input_page.dart';

late final String? userName;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  userName = prefs.getString('userName');
  print('Nom récupéré depuis SharedPreferences : $userName');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nom Utilisateur',
      debugShowCheckedModeBanner: false,
      home: userName == null || userName!.isEmpty
          ? NameInputPage()
          : HomePage(userName: userName!),
    );
  }
}
