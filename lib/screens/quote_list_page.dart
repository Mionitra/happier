// quote_list_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Quote {
  final String content;
  final String author;

  Quote({required this.content, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['text'],
      author: json['author'] ?? 'Inconnu',
    );
  }
}

class QuoteListPage extends StatefulWidget {
  @override
  _QuoteListPageState createState() => _QuoteListPageState();
}

class _QuoteListPageState extends State<QuoteListPage> {
  late Future<List<Quote>> _quotes;

  Future<List<Quote>> fetchQuotes() async {
    final response = await http.get(Uri.parse('https://type.fit/api/quotes'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Quote.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des citations');
    }
  }

  @override
  void initState() {
    super.initState();
    _quotes = fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Citations inspirantes')),
      body: FutureBuilder<List<Quote>>(
        future: _quotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Erreur : ${snapshot.error}'));

          final quotes = snapshot.data!;
          return ListView.builder(
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return ListTile(
                title: Text('"${quote.content}"'),
                subtitle: Text('- ${quote.author}'),
              );
            },
          );
        },
      ),
    );
  }
}
