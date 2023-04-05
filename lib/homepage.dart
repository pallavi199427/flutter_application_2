import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

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

    _fetchGameStateData();
    _fetchJoker();
  }

  void _fetchJoker() async {
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
      joker = [jokerCard];
      setState(() {}); // Update the UI with the new joker card
    } else {
      throw Exception('Failed to load joker card');
    }
  }

  void _fetchGameStateData() async {
    final url = Uri.parse('http://127.0.0.1:5000');
    final response =
        await http.get(url); // Make HTTP GET request to retrieve game state

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Parse player 1 cards
      final player1CardsData = jsonData['player1_cards'];
      List<PlayingCard> playingCards =
          List<PlayingCard>.from(player1CardsData.map((card) {
        return PlayingCard(
          Suit.values.byName(card['Suit']),
          CardValue.values.byName(card['CardValue']),
        );
      }));
      currentCards = playingCards;

      setState(() {}); // Update the UI with the new game state data
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void _showDiscardCardSnackbar() {
    final snackbar = SnackBar(
      content: Text('Discard a card first to continue'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 150.0;

    return Scaffold(
      body: Stack(
        children: [
          _buildJokerAndRemainingCardStack(joker, remainingCards, cardWidth),
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
              _showDiscardCardSnackbar();
            } else {
              _fetchGameStateData();
            }
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
