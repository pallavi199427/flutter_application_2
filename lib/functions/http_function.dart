import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:playing_cards/playing_cards.dart';

Future<List<PlayingCard>> fetchJoker() async {
  final url = Uri.parse('http://0.0.0.0:5000/joker');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    // Parse joker card
    final cardValue = jsonData['CardValue'];
    final suit = jsonData['Suit'];
    final jokerCard = PlayingCard(
      Suit.values.byName(suit),
      CardValue.values.byName(cardValue),
    );

    return [jokerCard];
  } else {
    throw Exception('Failed to load joker card');
  }
}
