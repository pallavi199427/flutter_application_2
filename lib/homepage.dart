import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_application_2/functions/card_value.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();

  void onCardDiscarded(PlayingCard currentCard) {}
}

class _MyHomePageState extends State<MyHomePage> {
  // Declare variables at the top of the class
  List<PlayingCard> currentCards = [];
  int selectedCardIndex = -1;
  int _remainingSeconds = 30;
  Timer? _timer;
  bool _showTimerWidget = true;
  List<PlayingCard> discardPile = [];
  List<PlayingCard> joker = [];
  List<PlayingCard> remainingCards = [];

  void initState() {
    super.initState();

    fetchGameStateData();
  }

  void fetchGameStateData() async {
    final url = Uri.parse('http://127.0.0.1:8000/InitializeGame');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      print("first initalizaition");

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
      List<PlayingCard> jokerCard =
          List<PlayingCard>.from(jokerPile.map((card) {
        final cardValue = parseCardValue(card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      joker = jokerCard;
      print("here2");
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
      setState(() {});
    } else {
      throw Exception('Failed to load game state');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 150.0;

    return Scaffold(
      body: Stack(
        children: [
          _buildJokerAndRemainingCardStack(joker, remainingCards, cardWidth),
          _buildDropZone(),
        ],
      ),
    );
  }

  Widget _buildJokerAndRemainingCardStack(List<PlayingCard> joker,
      List<PlayingCard> remainingCards, double cardWidth) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildJoker(joker),
        ...List<PlayingCard>.from(remainingCards.reversed)
            .asMap()
            .map((index, card) => MapEntry(
                  index,
                  _buildRemainingCard(
                      card, cardWidth, remainingCards.length, index),
                ))
            .values
            .toList(),
      ],
    );
  }

  Widget _buildJoker(List<PlayingCard> joker) {
    final jokerCard = joker.isNotEmpty ? joker.first : null;

    return jokerCard != null
        ? Positioned(
            bottom: 280,
            left: 460,
            child: SizedBox(
              height: 170,
              width: 120,
              child: Transform.rotate(
                angle: math.pi / 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PlayingCardView(
                      card: jokerCard,
                      showBack: false,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                        side: const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildRemainingCard(
    PlayingCard card,
    double cardWidth,
    int remainingCardsCount,
    int index,
  ) {
    final double top = index.toDouble() * 2.0;

    return Positioned(
      top: 240,
      child: SizedBox(
        height: 170,
        width: 120,
        child: GestureDetector(
          onTap: () {
            if (currentCards.length == 14) {
            } else {}
          },
          child: PlayingCardView(
            card: card,
            showBack: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildDropZone() {
  return Positioned(
    bottom: 20.0,
    left: 20.0,
    child: Container(
      height: 100.0,
      width: 100.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color.fromRGBO(0, 0, 0, 1),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(15, 189, 142, 80),
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Drop a card\nhere to show',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
