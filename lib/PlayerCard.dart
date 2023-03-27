import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class PlayerCards extends StatefulWidget {
  final List<PlayingCard> cards;
  final Function(PlayingCard) onCardDiscarded;
  final Function(List<PlayingCard>) onCardsUpdated; // new parameter

  PlayerCards({
    Key? key,
    required this.cards,
    required this.onCardDiscarded,
    required this.onCardsUpdated,
  }) : super(key: key);

  @override
  _PlayerCardsState createState() => _PlayerCardsState();
}

class _PlayerCardsState extends State<PlayerCards> {
  List<PlayingCard> currentCards = [];
  List<PlayingCard> discardPile = [];
  bool showDiscardButton = false;

  @override
  void initState() {
    super.initState();
    currentCards.addAll(widget.cards);
    final player1_card = [
      {"Suit": "clubs", "CardValue": "nine"},
      {"Suit": "hearts", "CardValue": "king"},
      {"Suit": "diamonds", "CardValue": "jack"},
      {"Suit": "clubs", "CardValue": "nine"},
      {"Suit": "hearts", "CardValue": "king"},
      {"Suit": "diamonds", "CardValue": "jack"},
      {"Suit": "clubs", "CardValue": "nine"},
      {"Suit": "hearts", "CardValue": "king"},
      {"Suit": "diamonds", "CardValue": "jack"}
    ];
    List<PlayingCard> playingCards = player1_card
        .map((card) => PlayingCard(Suit.values.byName(card['Suit'] as String),
            CardValue.values.byName(card['CardValue'] as String)))
        .toList();
    currentCards = playingCards;
  }

  void addCardsToHand(List<PlayingCard> cards) {
    setState(() {
      currentCards.addAll(cards);
    });
    widget.onCardsUpdated(currentCards); // call the callback function

    // Add this code to update the UI in the first page
    if (mounted) {
      setState(() {});
    }
  }

  int selectedCardIndex = -1;
  int selectedDiscardCardIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 370.0,
        left: 400.0,
      ),
      width: 850,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 150,
            child: FlatCardFan(
              children: [
                for (int i = 0; i < currentCards.length; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCardIndex = i;
                      });
                    },
                    child: Stack(
                      children: [
                        PlayingCardView(
                          card: currentCards[i],
                          showBack: false,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        if (selectedCardIndex == i)
                          Positioned(
                            top: 0.001,
                            child: ElevatedButton(
                              onPressed: () {
                                widget.onCardDiscarded(currentCards[i]);
                                setState(() {
                                  currentCards.removeAt(selectedCardIndex);
                                  selectedCardIndex = -1;
                                });
                              },
                              child: Text("Discard"),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
