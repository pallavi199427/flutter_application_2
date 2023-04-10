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

class MyHomePage2 extends StatefulWidget {
  @override
  _MyHomePageState2 createState() => _MyHomePageState2();
  void onCardDiscarded(PlayingCard currentCard) {}
}

class _MyHomePageState2 extends State<MyHomePage2> {
  // Declare variables at the top of the class
  late List<PlayingCard> deck;
  late int currentPlayer;
  List<PlayingCard> discardPile = [];
  List<PlayingCard> currentCards = [];
  List<PlayingCard> joker = [];
  List<PlayingCard> remainingCards = [];
  int selectedCardIndex = -1;
  String discardButtonName = "Discard";
  PlayingCard? _discardedCard;
  void fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
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

  void initState() {
    super.initState();
    fetchData('http://127.0.0.1:8000/InitializeGame');
  }

  void PickFromClosedDeck() async {
    fetchData('http://127.0.0.1:8000/PickFromClosedDeck');
  }

  void PickFromOpenDeck() async {
    fetchData('http://127.0.0.1:8000/PickFromOpenDeck');
  }

  void DiscardCard() async {
    fetchData('http://127.0.0.1:8000/DiscardCard');
  }

  void addToDiscardPile(PlayingCard card) {
    setState(() {
      discardPile.add(card);
    });
  }

  void _onDiscardforShowButtonPressed() {
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

  void addFromDiscardPile() {
    if (discardPile.isNotEmpty) {
      PlayingCard topCard = discardPile.last;
      discardPile.removeLast();
      setState(() {
        currentCards.add(topCard);
      });
    }
  }

  void _showDiscardCardSnackbar() {
    final snackbar = SnackBar(
      content: Text('Discard a card first to continue'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
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

  void _onDiscardButtonPressed(BuildContext context) async {
    // perform the discard operation

    // Make HTTP GET request to retrieve pile state
    final url = Uri.parse('http://0.0.0.0:5000/pile');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Check if Player2 picked a card from the closed pile
      final player2Pile = jsonData['Pile'];
      if (player2Pile == 'Closed') {
        // Show the alert dialog box to notify player 1
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Text('Player 2 picked a card from the $player2Pile pile'),
          ),
        );
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context); // Dismiss the alert dialog box
      }
    } else {
      throw Exception('Failed to load pile state');
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 150.0;
    return Scaffold(
      body: Stack(
        children: [
          background(),
          Player2Widget(),
          _buildJokerAndRemainingCardStack(joker, remainingCards, cardWidth),
          _buildCurrentCard(),
          _buildDiscardPile(),
          _buildDropZone(),
        ],
      ),
      bottomNavigationBar: BottomBar(playerName: 'Player1'),
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
            bottom: MediaQuery.of(context).size.height * 0.42,
            left: MediaQuery.of(context).size.width * 0.37,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.22,
              width: MediaQuery.of(context).size.width * 0.12,
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
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.43,
      left: MediaQuery.of(context).size.width * 0.42,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.21,
        width: MediaQuery.of(context).size.width * 0.09,
        child: GestureDetector(
          onTap: () {
            if (currentCards.length == 14) {
              _showDiscardCardSnackbar();
            } else {
              PickFromClosedDeck();
            }
          },
          child: PlayingCardView(
            card: card,
            showBack: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscardPile() {
    final PlayingCard? topCard =
        discardPile.isNotEmpty ? discardPile.last : null;

    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.44,
      left: MediaQuery.of(context).size.width * 0.59,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.20,
        width: MediaQuery.of(context).size.width * 0.15,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: topCard != null
                  ? PlayingCardView(
                      card: topCard,
                      showBack: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                    )
                  : Container(),
            ),
            GestureDetector(
              onTap: () {
                if (currentCards.length == 14) {
                  _showDiscardCardSnackbar();
                } else {
                  PickFromOpenDeck();
                }
              },
            ),
          ],
        ),
      ),
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
                            } else if (discardButtonName == 'Change') {
                              // perform second discard action
                              setState(() {
                                // perform second discard action
                              });
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
