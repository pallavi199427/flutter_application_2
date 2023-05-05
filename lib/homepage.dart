import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:flutter_application_2/widgets/bottomBar.dart';
import 'package:flutter_application_2/widgets/player2widget.dart';
import 'package:flutter_application_2/widgets/background.dart';
import 'package:flutter_application_2/widgets/cards.dart';

class MyHomePage extends StatefulWidget {
  @override
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
    bool isFirstHand = true;
    int selectedIndex = -1;

    if (allHands.isNotEmpty) {
      maxCardsPerHand = allHands
          .reduce((value, element) =>
              value.length > element.length ? value : element)
          .length;
    }

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ReorderableListView.builder(
          proxyDecorator: proxyDecorator,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
          itemBuilder: (context, index) {
            final handIndex = index ~/ maxCardsPerHand;
            final cardIndex = index % maxCardsPerHand;
            final hand = allHands.isNotEmpty ? allHands[handIndex] : null;
            final card = hand != null && hand.length > cardIndex
                ? hand[cardIndex]
                : null;

            if (card == null) {
              // Return an empty SizedBox to hide the item
              return SizedBox(key: Key('empty$index'));
            }

            bool isSelectedCard = selectedIndex == index;

            double screenWidth = MediaQuery.of(context).size.width;
            double currentOverlap = -screenWidth / 30;
            final dx = cardIndex * -15.0;

            return Stack(
              key: Key('$handIndex$cardIndex'),
              children: [
                Transform.translate(
                  key: Key('$handIndex$cardIndex'),
                  offset: Offset(dx, 0),
                  child: GestureDetector(
                    key: Key('$handIndex$cardIndex'),
                    behavior: HitTestBehavior.opaque,
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
                        if (totalCardCount == 13) {
                          buttonText = 'Discard';
                          showButton = true;
                        } else if (selectedCardIndexes.isNotEmpty) {
                          buttonText = 'Group (${selectedCardIndexes.length})';
                          showButton = true;
                        } else {
                          showButton = false;
                        }
                      });
                    },
                    child: SizedBox(
                      key: Key('$handIndex$cardIndex'),
                      height: MediaQuery.of(context).size.height * 0.24,
                      child: ReorderableDragStartListener(
                        index: index,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedCardIndexes.contains(
                                      handIndex * maxCardsPerHand + cardIndex)
                                  ? Colors.blue
                                  : Colors.transparent,
                            ),
                          ),
                          child: PlayingCardView(
                            card: card,
                            showBack: false,
                            style: myCardStyles,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (showButton &&
                    selectedCardIndexes.contains(index) &&
                    index == selectedCardIndexes.last)
                  Positioned(
                    // Position the button as desired
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button press as desired
                      },
                      child: Text(buttonText),
                    ),
                  )
                else
                  SizedBox.shrink() // Hide the button if no cards are selected
              ],
            );
          },
          itemCount: allHands.isEmpty ? 0 : allHands.length * maxCardsPerHand,
          onReorder: (oldIndex, newIndex) {},
        ),
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 10,
          color: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }
}
