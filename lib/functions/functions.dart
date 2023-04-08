import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_2/functions/card_value.dart';

import 'package:playing_cards/playing_cards.dart';

List<PlayingCard> discardPile = [];
List<PlayingCard> currentCards = [];
List<PlayingCard> joker = [];
List<PlayingCard> remainingCards = [];

void fetchGameStateData() async {
  final url = Uri.parse('http://127.0.0.1:8000/InitializeGame');
  var response = await http.get(url);
  var jsonData;

  while (response.statusCode != 200) {
    await Future.delayed(Duration(seconds: 1));
    response = await http.get(url);
  }

  print("first initalizaition");

  jsonData = jsonDecode(response.body);

  // Parse discard pile card
  final discardData = jsonData['OpenDeck'];
  List<PlayingCard> discardCards =
      List<PlayingCard>.from(discardData.map((card) {
    final cardValue = parseCardValue(card['CardValue']);
    final suit = card['Suit'];
    return PlayingCard(
      Suit.values.byName(suit),
      CardValue.values.byName(cardValue),
    );
  }));
  discardPile = discardCards;
  print(discardPile);

  final jokerPile = jsonData['Joker'];
  List<PlayingCard> jokerCard = List<PlayingCard>.from(jokerPile.map((card) {
    final cardValue = parseCardValue(card['CardValue']);
    final suit = card['Suit'];
    return PlayingCard(
      Suit.values.byName(suit),
      CardValue.values.byName(cardValue),
    );
  }));
  joker = jokerCard;
  print("here");
  // Parse player 1 cards (Loosing hand)
  final player1CardsData = jsonData['Loosing Hand'];
  List<PlayingCard> playingCards =
      List<PlayingCard>.from(player1CardsData.map((card) {
    final cardValue = parseCardValue(card['CardValue']);
    final suit = card['Suit'];
    return PlayingCard(
      Suit.values.byName(suit),
      CardValue.values.byName(cardValue),
    );
  }));
  currentCards = playingCards;

  // Parse remaining cards (Closed deck)
  final remainingCardsData = jsonData['ClosedDeck'];
  remainingCards = List<PlayingCard>.from(remainingCardsData.map((card) {
    final cardValue = parseCardValue(card['CardValue']);
    final suit = card['Suit'];
    return PlayingCard(
      Suit.values.byName(suit),
      CardValue.values.byName(cardValue),
    );
  }));
}

void PickFromClosedDeck() async {
  final url = Uri.parse('http://127.0.0.1:8000/PickFromClosedDeck');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    // Parse discard pile card
    final discardData = jsonData['OpenDeck'];
    List<PlayingCard> discardCards =
        List<PlayingCard>.from(discardData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    discardPile = discardCards;

    final jokerPile = jsonData['Joker'];
    List<PlayingCard> jokerCard = List<PlayingCard>.from(jokerPile.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    joker = jokerCard;
    print("here");
    // Parse player 1 cards (Loosing hand)
    final player1CardsData = jsonData['Loosing Hand'];
    List<PlayingCard> playingCards =
        List<PlayingCard>.from(player1CardsData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    currentCards = playingCards;

    // Parse remaining cards (Closed deck)
    final remainingCardsData = jsonData['ClosedDeck'];
    remainingCards = List<PlayingCard>.from(remainingCardsData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
  } else {
    throw Exception('Failed to load game state');
  }
}

void PickFromOpenDeck() async {
  final url = Uri.parse('http://127.0.0.1:8000/PickFromOpenDeck');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    // Parse discard pile card
    final discardData = jsonData['OpenDeck'];
    List<PlayingCard> discardCards =
        List<PlayingCard>.from(discardData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    discardPile = discardCards;

    final jokerPile = jsonData['Joker'];
    List<PlayingCard> jokerCard = List<PlayingCard>.from(jokerPile.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    joker = jokerCard;
    print("here");
    // Parse player 1 cards (Loosing hand)
    final player1CardsData = jsonData['Loosing Hand'];
    List<PlayingCard> playingCards =
        List<PlayingCard>.from(player1CardsData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    currentCards = playingCards;

    // Parse remaining cards (Closed deck)
    final remainingCardsData = jsonData['ClosedDeck'];
    remainingCards = List<PlayingCard>.from(remainingCardsData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
  } else {
    throw Exception('Failed to load game state');
  }
}

void DiscardCard() async {
  final url = Uri.parse('http://127.0.0.1:8000/DiscardCard');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    // Parse discard pile card
    final discardData = jsonData['OpenDeck'];
    List<PlayingCard> discardCards =
        List<PlayingCard>.from(discardData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    discardPile = discardCards;

    final jokerPile = jsonData['Joker'];
    List<PlayingCard> jokerCard = List<PlayingCard>.from(jokerPile.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    joker = jokerCard;
    print("here");
    // Parse player 1 cards (Loosing hand)
    final player1CardsData = jsonData['Loosing Hand'];
    List<PlayingCard> playingCards =
        List<PlayingCard>.from(player1CardsData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
    currentCards = playingCards;

    // Parse remaining cards (Closed deck)
    final remainingCardsData = jsonData['ClosedDeck'];
    remainingCards = List<PlayingCard>.from(remainingCardsData.map((card) {
      final cardValue = parseCardValue(card['CardValue']);
      final suit = card['Suit'];
      return PlayingCard(
        Suit.values.byName(suit),
        CardValue.values.byName(cardValue),
      );
    }));
  } else {
    throw Exception('Failed to load game state');
  }
}
