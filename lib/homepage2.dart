import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';
import 'package:random_avatar/random_avatar.dart';

class MyHomePage2 extends StatefulWidget {
  @override
  _MyHomePageState2 createState() => _MyHomePageState2();

  void onCardDiscarded(PlayingCard currentCard) {}
}

class _MyHomePageState2 extends State<MyHomePage2> {
  // Declare variables at the top of the class
  late List<PlayingCard> deck;
  late int currentPlayer;
  bool _showAddButton = true;
  List<PlayingCard> discardPile = [];
  List<PlayingCard> currentCards = [];
  List<PlayingCard> joker = [];
  List<PlayingCard> remainingCards = [];
  int selectedCardIndex = -1;
  int selectedDiscardCardIndex = -1;

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
    final url = Uri.parse('http://0.0.0.0:5000');
    final response =
        await http.get(url); // Make HTTP GET request to retrieve game state

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Parse discard pile card
      final discardData = jsonData['discard_pile'];
      List<PlayingCard> discardCards =
          List<PlayingCard>.from(discardData.map((card) {
        return PlayingCard(
          Suit.values.byName(card['Suit']),
          CardValue.values.byName(card['CardValue']),
        );
      }));
      discardPile = discardCards;

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
      print(currentCards);

      // Parse remaining cards
      final remainingCardsData = jsonData['remaining_cards'];
      List<PlayingCard> remainingPlayingCards =
          List<PlayingCard>.from(remainingCardsData.map((card) {
        return PlayingCard(
          Suit.values.byName(card['Suit']),
          CardValue.values.byName(card['CardValue']),
        );
      }));
      remainingCards = remainingPlayingCards;

      setState(() {}); // Update the UI with the new game state data
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void addToDiscardPile(PlayingCard card) {
    setState(() {
      discardPile.add(card);
    });
  }

  Future<void> _discardCardHttpCall(PlayingCard card) async {
    final url =
        'http://0.0.0.0:5000/add_card/${card.suit.name.toLowerCase()}/${card.value.name.toLowerCase()}';

    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);
    } catch (error) {
      print(error);
    }
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
    final double cardWidth = 150.0;
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildImage(),
          _buildJokerAndRemainingCardStack(joker, remainingCards, cardWidth),
          _buildCurrentCard(),
          _buildDiscardPile(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
        ),
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

  Widget _buildDiscardPile() {
    final PlayingCard? topCard =
        discardPile.isNotEmpty ? discardPile.last : null;

    return Positioned(
      bottom: 280,
      left: 750, // adjust the left position as needed
      child: SizedBox(
        height: 170,
        width: 120,
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
                  //  _fetchGameStateData();

                  addFromDiscardPile();
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
      padding: const EdgeInsets.only(
        top: 420.0,
      ),
      child: ReorderableWrap(
        // ignore: sort_child_properties_last
        needsLongPressDraggable: false,

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
                          onPressed: () async {
                            setState(() {
                              final discardedCard =
                                  currentCards.removeAt(selectedCardIndex);
                              discardPile.add(discardedCard);
                              selectedCardIndex = -1;

                              // Call the HTTP function here with the card details
                              _discardCardHttpCall(discardedCard);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  content:
                                      Text("Please wait for Player's 2 turn"),
                                ),
                              );
                            });
                            await Future.delayed(Duration(seconds: 2));
                            Navigator.popUntil(
                                context,
                                ModalRoute.withName(Navigator
                                    .defaultRouteName)); // pop all routes until the home route
                            _onDiscardButtonPressed(
                                context); // call the desired function
                          },
                          child: const Text("Discard"),
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

  Future<String> fetchWinner() async {
    var response = await http.get(Uri.parse('http://127.0.0.1:5000/win'));
    var jsonResponse = jsonDecode(response.body);
    String win = jsonResponse['win'];
    return win;
  }

  Widget _buildBottomBar() {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RandomAvatar(
                'Player1',
                height: 50.0,
                width: 50.0,
              ),
              SizedBox(
                  width:
                      2.0), // add some spacing between the avatar and the text
              Text(
                'Player1',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            child: Text('Show'),
            onPressed: () async {
              String win = await fetchWinner();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: Text(
                      'Winner',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      win,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16.0,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 280, // Adjust the value to move the widget downwards
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RandomAvatar(
            'Player 2',
            height: 50,
            width: 50,
          ),
          SizedBox(width: 16.0),
          Text(
            'Player 2',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
