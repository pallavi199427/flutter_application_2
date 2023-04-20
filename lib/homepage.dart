import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_application_2/widgets/bottomBar.dart';
import 'package:flutter_application_2/widgets/player2widget.dart';
import 'package:flutter_application_2/widgets/background.dart';
import 'package:flutter_application_2/widgets/cards.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
  void onCardDiscarded(PlayingCard currentCard) {}
}

class _MyHomePageState extends State<MyHomePage> {
  bool isDisabled =
      true; // Set this variable to true to disable the widgets, false to enable them
  late List<PlayingCard> deck;
  late int currentPlayer;
  List<PlayingCard> discardPile = [];
  List<PlayingCard> currentCards = [];
  List<PlayingCard> joker = [];
  List<PlayingCard> remainingCards = [];
  int selectedCardIndex = -1;
  String discardButtonName = "Discard";
  PlayingCard? _discardedCard;
  bool isPlayer2Turn = false;
  bool _showBottomBarTimer = true;
  bool _showPlayer2Timer = false;
  bool isShowInitated = false;

  void _toggleBottomBarTimer() {
    setState(() {
      _showBottomBarTimer = !_showBottomBarTimer;
    });
  }

  void _togglePlayer2Timer() {
    setState(() {
      _showPlayer2Timer = !_showPlayer2Timer;
      isPlayer2Turn =
          !isPlayer2Turn; // Set isPlayer2Turn based on _showPlayer2Timer
    });
  }

  fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final player1CardsData = jsonData['Loosing Hand'];
      List<PlayingCard> playingCards =
          List<PlayingCard>.from(player1CardsData.map((card) {
        final cardValue = (card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      currentCards = playingCards;

      // Parse discard pile card
      final discardData = jsonData['OpenDeck'];
      List<PlayingCard> discardCards =
          List<PlayingCard>.from(discardData.map((card) {
        final cardValue = (card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      discardPile = discardCards;

      final remainingCardsData = jsonData['ClosedDeck'];
      List<PlayingCard> ClosedDeck =
          List<PlayingCard>.from(remainingCardsData.map((card) {
        final cardValue = (card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      remainingCards = ClosedDeck;

      final jokerPile = jsonData['Joker'];
      List<PlayingCard> jokerCard =
          List<PlayingCard>.from(jokerPile.map((card) {
        final cardValue = (card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      joker = jokerCard;

      setState(() {});
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void initState() {
    super.initState();
    fetchData('http://192.168.0.105:8000/InitializeGame');
  }

  ///
  ///
  ///
  fetchOpponentMove() async {
    final response = await http
        .get(Uri.parse('http://192.168.0.105:8000/FetchOpponentMove'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final opponentMoveData = jsonData['OpponentMove'];
      final Pile = opponentMoveData['Pile'];
      final Show = opponentMoveData['Show'] == 'True';

      if (Show) {
        final remainingCardsData = jsonData['Winning Hand'];
        List<PlayingCard> ClosedDeck =
            List<PlayingCard>.from(remainingCardsData.map((card) {
          final cardValue = (card['CardValue']);
          final suit = card['Suit'];
          return PlayingCard(
            Suit.values.byName(suit),
            CardValue.values.byName(cardValue),
          );
        }));
        remainingCards = ClosedDeck;

        // show the "submit a card for show" alert box
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Player 2 submitted a card for show'),
              content: Text('Please discard a card and submit your cards too.'),
            );
          },
        );
      } else {
        _togglePlayer2Timer();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Player 2 picked from Pile' + Pile),
            );
          },
        );
      }

      // update the state of the application with the fetched data
      setState(() {});

      // wait for 3 seconds before automatically dismissing the alert box
      await Future.delayed(Duration(seconds: 3));

      // dismiss the alert box
      Navigator.of(context).pop();
      _toggleBottomBarTimer();
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void PickFromClosedDeck() async {
    fetchData('http://192.168.0.105:8000/PickFromClosedDeck');
    //_toggleBottomBarTimer();
    // fetchOpponentMove();
  }

  void PickFromOpenDeck() async {
    fetchData('http://192.168.0.105:8000/PickFromOpenDeck');
    //_toggleBottomBarTimer();
    //fetchOpponentMove();
  }

  Future<void> _discardCardHttpCall(PlayingCard card) async {
    const url = 'http://192.168.0.105:8000/DiscardCard';
    final cardJson = jsonEncode({
      'Suit': card.suit.name.toLowerCase(),
      'CardValue': card.value.name.toLowerCase(),
    });

    try {
      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"}, body: cardJson);
      final responseData = jsonDecode(response.body);
      setState(() {
        _toggleBottomBarTimer();
        _togglePlayer2Timer();
        fetchData('http://192.168.0.105:8000/InitializeGame');

        fetchOpponentMove();
      });
    } catch (error) {
      print(error);
    }
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
      isShowInitated = true;
    });
    //_buildDropZone();
  }

  void _showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 7, 61, 141),
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Center(
            child: Text(
              ' ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Container(
                  height: 30,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 9, 132, 13),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
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
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            background(),
            Player2Widget(
              showTimer: _showPlayer2Timer,
              toggleTimerVisibility: _togglePlayer2Timer,
              onComplete: () {
                _togglePlayer2Timer();
                _toggleBottomBarTimer();
              },
            ),
            _buildJoker(),
            buildRemainingCards(),
            _buildCurrentCard(),
            _buildDiscardPile(),
            _buildDropZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscardPile({bool show = true}) {
    final PlayingCard? topCard =
        discardPile.isNotEmpty ? discardPile.first : null;

    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.43,
      left: MediaQuery.of(context).size.width * 0.59,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.20,
        width: MediaQuery.of(context).size.width * 0.15,
        child: Stack(
          children: [
            Container(
              child: topCard != null
                  ? PlayingCardView(
                      card: topCard,
                      showBack: false,
                      style: myCardStyles,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                    )
                  : Container(),
              decoration: BoxDecoration(
                color: show ? Colors.grey[300] : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (isPlayer2Turn) {
                  _showMessageDialog(
                      context, "Please wait for Player 2's turn");
                } else if (currentCards.length == 14) {
                  _showMessageDialog(
                      context, "Please select a card to discard");
                } else {
                  PickFromClosedDeck();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCard() {
    return Container(
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
                child: Stack(
                  children: [
                    PlayingCardView(
                      card: currentCards[i],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    if (currentCards.length > 13 && selectedCardIndex == i)
                      Positioned(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (isPlayer2Turn) {
                              _showMessageDialog(
                                  context, "Please wait for Player 2's turn");
                            } else if (discardButtonName == 'Discard') {
                              final discardedCard1 =
                                  currentCards.removeAt(selectedCardIndex);
                              setState(() {});
                              _discardCardHttpCall(discardedCard1);
                            } else {
                              // perform default action
                              setState(() {
                                _onChangeButtonPressed();
                              });
                            }
                          },
                          style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all<Size>(Size(10, 10)),
                            // Other button style properties
                          ),
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

  Widget _buildJoker() {
    return Positioned(
      bottom: 0.42 * MediaQuery.of(context).size.height,
      left: 0.38 * MediaQuery.of(context).size.width,
      child: SizedBox(
        height: 0.22 * MediaQuery.of(context).size.height,
        width: 0.12 * MediaQuery.of(context).size.width,
        child: Transform.rotate(
          angle: math.pi / -2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PlayingCardView(
                card: joker[0],
                showBack: false,
                style: myCardStyles,
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
    );
  }

  Widget buildRemainingCards() {
    final cardWidth = 100.0; // Replace this with the desired width of the cards

    // Check if the remainingCards list is null or empty
    if (remainingCards == null || remainingCards.isEmpty) {
      // Show a placeholder widget while the actual list is loading
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.20,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If the remainingCards list is not null or empty, show the top card
    final topCard = remainingCards.last;
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.43,
      left: MediaQuery.of(context).size.width * 0.46,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.20,
        width: cardWidth,
        child: GestureDetector(
          onTap: () {
            if (isPlayer2Turn) {
              _showMessageDialog(context, "Please wait for Player 2's turn");
            } else if (currentCards.length == 14) {
              _showMessageDialog(context, "Please select a card to discard");
            } else {
              PickFromClosedDeck();
            }
          },
          child: PlayingCardView(
            card: topCard,
            showBack: false,
            style: myCardStyles,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
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
              height: MediaQuery.of(context).size.height * 0.17,
              width: MediaQuery.of(context).size.width * 0.10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  width: 1.0,
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
                      'Show',
                    ),
                    style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all<Size>(Size(20, 30)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                    ) // set the background color to blue
                    ),
              ),
            ),
          ),
        if (_discardedCard != null) // only render if _discardedCard is not null
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.43,
            left: MediaQuery.of(context).size.width * 0.25,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.19,
              child: PlayingCardView(
                card: _discardedCard!,
                style: myCardStyles,
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
