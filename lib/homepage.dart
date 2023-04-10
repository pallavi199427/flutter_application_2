import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_application_2/widgets/bottomBar.dart';
import 'package:flutter_application_2/widgets/player2widget.dart';
import 'package:flutter_application_2/widgets/background.dart';
import 'package:flutter_application_2/functions/card_value.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
  void onCardDiscarded(PlayingCard currentCard) {}
}

class _MyHomePageState extends State<MyHomePage> {
  // Declare variables at the top of the class
  late List<PlayingCard> deck;
  late int currentPlayer;
  List<PlayingCard> currentCards = [];
  int selectedCardIndex = -1;
  String discardButtonName = "Discard";
  PlayingCard? _discardedCard;
  void initState() {
    super.initState();
    fetchGameStateData();
  }

  void _onDiscardforShowButtonPressed() {
    print("here");
    setState(() {
      discardButtonName = "Discard \nfor show";
    });
  }

  void _onChangeButtonPressed() {
    setState(() {
      _discardedCard = currentCards.removeAt(selectedCardIndex);
      selectedCardIndex = -1;
      discardButtonName = "Discard";
    });
    _buildDropZone();
  }

  void fetchGameStateData() async {
    final url = Uri.parse('http://127.0.0.1:8000/InitializeGame');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

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

      setState(() {});
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final card = currentCards.removeAt(oldIndex);
      currentCards.insert(newIndex, card);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 150.0;
    return Scaffold(
      body: Stack(
        children: [
          background(),
          Player2Widget(),
          _buildCurrentCard(),
          _buildDropZone(),
        ],
      ),
      bottomNavigationBar: BottomBar(playerName: 'Player1'),
    );
  }

  Widget _buildCurrentCard() {
    double topPadding = 0;
    MediaQueryData? mediaQuery = MediaQuery.of(context);

    if (mediaQuery != null) {
      topPadding = mediaQuery.size.height * 0.6; // 50% of the screen height
    }

    return Container(
      padding: EdgeInsets.only(
        top: topPadding,
      ),
      child: ReorderableWrap(
        // ignore: sort_child_properties_last
        needsLongPressDraggable: false,

        // ignore: sort_child_properties_last
        children: [
          for (int i = 0; i < currentCards.length; i++)
            GestureDetector(
              key: Key(currentCards[i].toString()),
              onTap: () {
                setState(() {
                  selectedCardIndex = i;
                });
              },
              child: SizedBox(
                height: 125,
                child: Stack(
                  children: [
                    PlayingCardView(
                      card: currentCards[i],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    if (selectedCardIndex == i)
                      Positioned(
                        child: ElevatedButton(
                          onPressed: () {
                            if (discardButtonName == 'Discard') {
                              // perform discard action
                            } else {
                              // perform default action
                              setState(() {
                                _onChangeButtonPressed();
                              });
                            }
                          },
                          child: Text(discardButtonName),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
        onReorder: _onReorder,
      ),
    );
  }

  Widget _buildDropZone() {
    return Stack(
      children: [
        if (_discardedCard == null) // only render if _discardedCard is null
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.46,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.10,
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
                child: ElevatedButton(
                  onPressed: () {
                    _onDiscardforShowButtonPressed();
                  },
                  child: Text(
                    'Discard for show',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        if (_discardedCard != null) // only render if _discardedCard is not null
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.46,
            left: MediaQuery.of(context).size.width * 0.25,
            child: SizedBox(
              height: 125, // set height of the SizedBox to 125
              child: PlayingCardView(
                card: _discardedCard!,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.black.withOpacity(0.3)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
