import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';

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
  late PlayingCard joker;
  List<PlayingCard> remainingCards = [];
  int selectedCardIndex = -1;
  int selectedDiscardCardIndex = -1;

  void initState() {
    super.initState();

    currentPlayer = 2;
    joker = PlayingCard(Suit.clubs, CardValue.nine);

    _fetchGameStateData(); // Call new method to fetch game state data
  }

  void _fetchGameStateData() async {
    final url = Uri.parse('http://127.0.0.1:5000');
    final response =
        await http.get(url); // Make HTTP GET request to retrieve game state

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Parse discard pile card
      final discardData = jsonData['discard_pile'];
      final suit = discardData['Suit'];
      final cardValue = discardData['CardValue'];
      discardPile = [
        PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        )
      ];

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
        'http://localhost:5000/add_card/${card.suit.name.toLowerCase()}/${card.value.name.toLowerCase()}';

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

  Widget _buildJokerAndRemainingCardStack(
      PlayingCard joker, List<PlayingCard> remainingCards, double cardWidth) {
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

  Widget _buildJoker(PlayingCard joker) {
    return Positioned(
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
                card: joker,
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
    );
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
            _fetchGameStateData(); // Call _fetchGameStateData again to retrieve latest
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
                _fetchGameStateData(); // Call _fetchGameStateData again to retrieve latest
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
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    if (selectedCardIndex == i)
                      Positioned(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              final discardedCard =
                                  currentCards.removeAt(selectedCardIndex);
                              discardPile.add(discardedCard);
                              selectedCardIndex = -1;

                              // Call the HTTP function here with the card details
                              _discardCardHttpCall(discardedCard);
                            });
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            child: const Text('Player1'),
            onPressed: () {},
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
    return Positioned(
      bottom: 520,
      left: 545,
      child: Transform.rotate(
        angle: 15 * 3.14159 / 180, // 15 degrees clockwise in radians
        child: SizedBox(
          width: 100,
          height: 100,
          child: Image.asset('assets/cards.png'),
        ),
      ),
    );
  }
}
