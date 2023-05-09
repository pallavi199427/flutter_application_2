// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:flutter_application_2/widgets/bottomBar.dart';
import 'package:flutter_application_2/widgets/player2widget.dart';
import 'package:flutter_application_2/widgets/background.dart';
import 'package:flutter_application_2/widgets/cards.dart';

class MyHomePage2 extends StatefulWidget {
  @override
  _MyHomePageState2 createState() => _MyHomePageState2();
  void onCardDiscarded(PlayingCard currentCard) {}
}

class _MyHomePageState2 extends State<MyHomePage2> {
  List<PlayingCard> selectedCards = [];
  String buttonText = '';
  List<int> selectedCardIndexes = [];
  List<int> selectedHandIndexes = [];
  List<List<PlayingCard>> allHands = [];
  bool showButton = false;
  String ip = '127.0.0.1';
  bool isPlayer2Turn = false;
  bool _showBottomBarTimer = true;
  bool _showPlayer2Timer = false;
  bool isShowInitated = false;
  int selectedCardIndex = -1;
  bool isPickfromClosedDeck = false;
  bool isPickfromOpenDeck = false;

  PlayingCard? showCard;

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

  BottomBar bottomBar = BottomBar(
    playerName: 'John',
    toggleTimerVisibility: () {},
    showTimer: true,
    onComplete: () {},
  );

  bool isDisabled =
      true; // Set this variable to true to disable the widgets, false to enable them
  late List<PlayingCard> deck;
  late int currentPlayer;
  List<PlayingCard> discardPile = [];
  List<PlayingCard> currentCards = [];
  List<PlayingCard> joker = [];
  List<PlayingCard> remainingCards = [];
  List<PlayingCard> PickedCard = [];

  String discardButtonName = "Discard";
  PlayingCard? _discardedCard;

  void parseJsonData(Map<String, dynamic> jsonData) {
    final Map<String, dynamic> playerCardsData =
        jsonData['Loosing_Hand_Sorted'];
    final List<PlayingCard> playingCards = playerCardsData.containsKey('0')
        ? playerCardsData['0']
            .map<PlayingCard>((card) => PlayingCard(
                  Suit.values.byName(card['Suit']),
                  CardValue.values.byName(card['CardValue']),
                ))
            .toList()
        : [];

    final List<PlayingCard> secondset = playerCardsData.containsKey('1')
        ? playerCardsData['1']
            .map<PlayingCard>((card) => PlayingCard(
                  Suit.values.byName(card['Suit']),
                  CardValue.values.byName(card['CardValue']),
                ))
            .toList()
        : [];
    final List<PlayingCard> thirdset = playerCardsData.containsKey('2')
        ? playerCardsData['2']
            .map<PlayingCard>((card) => PlayingCard(
                  Suit.values.byName(card['Suit']),
                  CardValue.values.byName(card['CardValue']),
                ))
            .toList()
        : [];
    final List<PlayingCard> fourthset = playerCardsData.containsKey('3')
        ? playerCardsData['3']
            .map<PlayingCard>((card) => PlayingCard(
                  Suit.values.byName(card['Suit']),
                  CardValue.values.byName(card['CardValue']),
                ))
            .toList()
        : [];
    final List<PlayingCard> fifthset = playerCardsData.containsKey('4')
        ? playerCardsData['4']
            .map<PlayingCard>((card) => PlayingCard(
                  Suit.values.byName(card['Suit']),
                  CardValue.values.byName(card['CardValue']),
                ))
            .toList()
        : [];
    setState(() {
      allHands = [
        playingCards,
        secondset,
        thirdset,
        fourthset,
        fifthset,
      ];
    });
  }

  Future<void> fetchDataSort(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      parseJsonData(jsonData);
      setState(() {});
    } else {
      throw Exception('Failed to load game state');
    }
  }

  fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

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

      setState(() {});
    } else {
      throw Exception('Failed to load game state');
    }
  }

  fetchCardPick(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final CardPick = jsonData['CardPick'];
      List<PlayingCard> PickedCard =
          List<PlayingCard>.from(CardPick.map((card) {
        final cardValue = (card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      PickedCard = PickedCard;

      setState(() {});
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void initState() {
    super.initState();
    fetchData('http://$ip/InitializeGame');
    fetchDataSort('http://$ip/InitializeGame');
  }

  fetchOpponentMove() async {
    final response = await http.get(Uri.parse('http://$ip/FetchOpponentMove'));
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
        _togglePlayer2Timer();

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
              title: Text('Player 2 picked from' + Pile + 'Pile'),
            );
          },
        );
      }

      setState(() {
        fetchData('http://$ip/InitializeGame');
      });

      await Future.delayed(Duration(seconds: 3));

      Navigator.of(context).pop();
      _toggleBottomBarTimer();
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void PickFromClosedDeck() async {
    final response = await http.get(Uri.parse('http://$ip/PickFromClosedDeck'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final CardPick = jsonData['CardPick'];
      List<PlayingCard> PickedCard =
          List<PlayingCard>.from(CardPick.map((card) {
        final cardValue = (card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      PickedCard = PickedCard;

      final lastHandIndex = allHands.length - 1;
      final lastHand = List<PlayingCard>.from(allHands[lastHandIndex]);
      allHands[3].add(PickedCard.first);
      setState(() {
        isPickfromClosedDeck = false;
        allHands[lastHandIndex] = lastHand;
      });
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void PickFromOpenDeck() async {
    final response = await http.get(Uri.parse('http://$ip/PickFromOpenDeck'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final CardPick = jsonData['CardPick'];
      List<PlayingCard> PickedCard =
          List<PlayingCard>.from(CardPick.map((card) {
        final cardValue = (card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      PickedCard = PickedCard;

      final lastHandIndex = allHands.length - 1;
      final lastHand = List<PlayingCard>.from(allHands[lastHandIndex]);
      allHands[3].add(PickedCard.first);
      setState(() {
        isPickfromClosedDeck = false;
        allHands[lastHandIndex] = lastHand;
      });
    } else {
      throw Exception('Failed to load game state');
    }
  }

  _discardCardHttpCall(PlayingCard card) async {
    final url = 'http://$ip/DiscardCard';
    final cardJson = jsonEncode({
      'Suit': card.suit.name.toLowerCase(),
      'CardValue': card.value.name.toLowerCase(),
    });

    try {
      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"}, body: cardJson);

      setState(() {
        _toggleBottomBarTimer();
        _togglePlayer2Timer();
        fetchData('http://$ip/InitializeGame');
        fetchOpponentMove(); // wait for _discardCardHttpCall to complete before continuing with fetchOpponentMove
      });
    } catch (error) {
      // handle error
      print(error);
    }
  }

  void _onDiscardforShowButtonPressed() {
    setState(() {
      buttonText = "Discard \nfor show";
    });
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

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 150.0;
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
            _buildJoker(joker),
            buildRemainingCards(),
            _buildCurrentCard(),
            _buildDiscardPile(),
            _buildDropZone(),
          ],
        ),
        bottomNavigationBar: BottomBar(
          playerName: 'Player1',
          showTimer: _showBottomBarTimer,
          toggleTimerVisibility: _toggleBottomBarTimer,
          onComplete: () {
            _toggleBottomBarTimer();

            _togglePlayer2Timer();
          }, // <-- Pass it here
        ),
      ),
    );
  }

  Widget _buildJoker(List<PlayingCard> joker) {
    final jokerCard = joker.isNotEmpty ? joker.first : null;
    return jokerCard != null
        ? Positioned(
            bottom: MediaQuery.of(context).size.height * 0.42,
            left: MediaQuery.of(context).size.width * 0.38,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.22,
              width: MediaQuery.of(context).size.width * 0.12,
              child: Transform.rotate(
                angle: math.pi / -2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PlayingCardView(
                      card: jokerCard,
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
          )
        : const SizedBox();
  }

  Widget buildRemainingCards() {
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
        height: MediaQuery.of(context).size.height * 0.22,
        width: MediaQuery.of(context).size.height * 0.15,
        child: GestureDetector(
          onTap: () {
            int totalCardCount =
                allHands.fold<int>(0, (sum, hand) => sum + hand.length);
            if (isPlayer2Turn) {
              _showMessageDialog(context, "Please wait for Player 2's turn");
            } else if (totalCardCount == 14) {
              _showMessageDialog(context, "Please select a card to discard");
            } else {
              PickFromClosedDeck();
            }
          },
          child: PlayingCardView(
            card: topCard,
            showBack: true,
            style: myCardStyles,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                int totalCardCount =
                    allHands.fold<int>(0, (sum, hand) => sum + hand.length);
                if (isPlayer2Turn) {
                  _showMessageDialog(
                      context, "Please wait for Player 2's turn");
                } else if (totalCardCount == 14) {
                  _showMessageDialog(
                      context, "Please select a card to discard");
                } else {
                  discardPile.removeAt(0);
                  setState(() {
                    PickFromOpenDeck();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCard() {
    int maxCardsPerHand = 10;
    int startingHandIndex = -1;
    int startingCardIndex = -1;
    List<Widget> cardWidgets = List.generate(
        allHands.isEmpty ? 0 : allHands.length * maxCardsPerHand, (index) {
      final handIndex = index ~/ maxCardsPerHand;
      final cardIndex = index % maxCardsPerHand;
      final hand = allHands.isNotEmpty ? allHands[handIndex] : null;
      final card =
          hand != null && hand.length > cardIndex ? hand[cardIndex] : null;
      if (card == null) {
        return SizedBox(key: Key('empty$index'));
      }

      return SizedBox(
        child: Stack(
          children: [
            Positioned(
              child: Container(
                width: 100.0,
                height: 120.0,
                child: DragTarget<PlayingCard>(
                  onAccept: (card) {
                    setState(() {
                      allHands[startingHandIndex].removeAt(startingCardIndex);
                      allHands[handIndex].insert(cardIndex, card);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return SizedBox(
                      width: 100.0,
                      height: 120.0,
                      child: Stack(
                        children: [
                          Positioned(
                            child: Container(),
                          ),
                          Positioned(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedCardIndexes.contains(index)) {
                                    // The current card is already selected, so unselect it
                                    selectedCardIndexes.remove(index);
                                  } else {
                                    // Select the current card
                                    selectedCardIndexes.add(index);
                                  }

                                  int totalCardCount = allHands.fold<int>(
                                      0, (sum, hand) => sum + hand.length);

                                  if (totalCardCount > 13) {
                                    buttonText = 'Discard';
                                    showButton = true;
                                  } else if (selectedCardIndexes.length > 1) {
                                    buttonText = 'Group';
                                    showButton = true;
                                  } else {
                                    showButton = false;
                                  }
                                }); // Add your desired logic for the tap gesture here
                              },
                              child: Draggable<PlayingCard>(
                                axis: Axis.horizontal,
                                data: card,
                                onDragStarted: () {
                                  startingHandIndex = handIndex;
                                  startingCardIndex = cardIndex;
                                },
                                child: SizedBox(
                                  height: 100.0,
                                  width: 80.0,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selectedCardIndexes.contains(
                                                    handIndex *
                                                            maxCardsPerHand +
                                                        cardIndex)
                                                ? Colors.red
                                                : Colors.transparent,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: PlayingCardView(
                                          card: card,
                                          showBack: false,
                                          elevation: 2.0,
                                        ),
                                      ),
                                      if (showButton &&
                                          selectedCardIndexes.contains(index) &&
                                          index == selectedCardIndexes.last)
                                        Transform.translate(
                                          offset: Offset(10, -10),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (buttonText == 'Discard') {
                                                setState(() {
                                                  // Get the selected card
                                                  final discardedCard = allHands[
                                                          selectedCardIndexes
                                                                  .first ~/
                                                              maxCardsPerHand][
                                                      selectedCardIndexes
                                                              .first %
                                                          maxCardsPerHand];

                                                  // Remove the selected card from the hand and add it to the discard pile
                                                  allHands[selectedCardIndexes
                                                              .first ~/
                                                          maxCardsPerHand]
                                                      .removeAt(
                                                          selectedCardIndexes
                                                                  .first %
                                                              maxCardsPerHand);
                                                  discardPile
                                                      .add(discardedCard);
                                                  _discardCardHttpCall(
                                                      discardedCard);

                                                  // Clear the selected card index
                                                  selectedCardIndexes.clear();
                                                });
                                              } else if (buttonText ==
                                                  'Group') {
                                                setState(() {
                                                  // Combine selected cards into a single list
                                                  final selectedHand =
                                                      selectedCardIndexes
                                                          .map((index) {
                                                    final handIndex = index ~/
                                                        maxCardsPerHand;
                                                    final cardIndex =
                                                        index % maxCardsPerHand;
                                                    return allHands[handIndex]
                                                        [cardIndex];
                                                  }).toList();
                                                  print(selectedHand);
                                                  print(selectedCardIndex);
                                                  print(selectedHand);
                                                  // Remove selected cards from their original hands
                                                  for (final index
                                                      in selectedCardIndexes) {
                                                    final handIndex = index ~/
                                                        maxCardsPerHand;
                                                    final cardIndex =
                                                        index % maxCardsPerHand;
                                                    allHands[handIndex]
                                                        .removeAt(cardIndex);
                                                  }

                                                  // Add selected cards to the new hand at position 0
                                                  allHands.insert(
                                                      0, selectedHand);

                                                  // Clear selection state
                                                  selectedCardIndexes.clear();
                                                  buttonText = '';
                                                  showButton = false;
                                                });
                                              } else {}
                                            },
                                            child: Text(buttonText),
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets
                                                  .zero, // remove button padding
                                              tapTargetSize: MaterialTapTargetSize
                                                  .shrinkWrap, // remove extra padding around button
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                feedback: Material(
                                  child: SizedBox(
                                    height: 100.0,
                                    width: 80.0,
                                    child: Container(
                                      color: Color.fromARGB(
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                      child: PlayingCardView(
                                        card: card,
                                        showBack: false,
                                        elevation: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: SizedBox(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width * 1.4,
      child: Stack(
        children: [
          FlatCardFan(children: cardWidgets),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return Stack(
      children: [
        if (showCard == null) // only render if _discardedCard is null
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.46,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.17,
              width: MediaQuery.of(context).size.width * 0.14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(15, 189, 142, 80),
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
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                    ) // set the background color to blue
                    ),
              ),
            ),
          ),
        if (showCard != null) // only render if _discardedCard is not null
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.43,
            left: MediaQuery.of(context).size.width * 0.25,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.19,
              child: PlayingCardView(
                card: showCard!,
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
