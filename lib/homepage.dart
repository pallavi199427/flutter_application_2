// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:flutter_application_2/widgets/bottomBar.dart';
import 'package:flutter_application_2/widgets/background.dart';

class MyHomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
  void onCardDiscarded(PlayingCard currentCard) {}
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
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

// Declare an AnimationController in the widget's state
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapCard() {
    if (_animationController.isAnimating) {
      return;
    }

    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

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

  void initState() {
    super.initState();
    //fetchData('http://$ip/InitializeGame');
    fetchDataSort('http://$ip/InitializeGame');
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    //const double cardWidth = 150.0;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            background(),
            _buildCurrentCard(),
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

                                  if (selectedCardIndexes.length == 1) {
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
                                                  // _discardCardHttpCall(discardedCard);

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

                                                  // Remove selected cards from their original hands
                                                  for (final index
                                                      in selectedCardIndexes
                                                          .reversed) {
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
}
