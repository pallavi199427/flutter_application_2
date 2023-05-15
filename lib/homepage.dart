// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
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

class _MyHomePageState extends State<MyHomePage> {
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
  bool WinClaimed = false;
  PlayingCard? showCard;
  PlayingCard? acceptedCard;
  int startingHandIndex = 0;
  int startingCardIndex = 0;

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

      // setState(() {});
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    super.initState();
    fetchData('http://$ip/InitializeGame');
    fetchDataSort('http://$ip/InitializeGame');
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
      setState(() {
        PickedCard = PickedCard;
        int lastHandIndex = 4;

        for (int i = allHands.length - 1; i >= 0; i--) {
          if (allHands[i].isNotEmpty) {
            lastHandIndex = i;
            break;
          }
        }

        allHands[lastHandIndex].add(PickedCard.single);
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

      setState(() {
        PickedCard = PickedCard;
        int lastHandIndex = 4;

        for (int i = allHands.length - 1; i >= 0; i--) {
          if (allHands[i].isNotEmpty) {
            lastHandIndex = i;
            break;
          }
        }

        print(lastHandIndex);
        allHands[lastHandIndex].add(PickedCard.single);
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

  fetchOpponentMove() async {
    final response = await http.get(Uri.parse('http://$ip/FetchOpponentMove'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final opponentMoveData = jsonData['OpponentMove'];
      final Pile = opponentMoveData['Pile'];
      final Show = opponentMoveData['Show'] == 'True';

      if (!Show) {
        _togglePlayer2Timer();
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Player 2 picked from $Pile Pile'),
            );
          },
        );
      } else {
        _togglePlayer2Timer();
        WinClaimed = true;

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Player 2 submitted a card for show'),
              content: Text('Please discard a card and submit your cards too.'),
            );
          },
        );
      }

      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop(); // Automatically dismiss the dialog

      _toggleBottomBarTimer();
    } else {
      throw Exception('Failed to load game state');
    }
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
            _buildJoker(joker, WinClaimed),
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
            if (WinClaimed) {
              _togglePlayer2Timer();
            }
          }, // <-- Pass it here
        ),
      ),
    );
  }

  Widget _buildJoker(List<PlayingCard> joker, bool WinClaimed) {
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
                    AbsorbPointer(
                      absorbing: WinClaimed, // Disable interaction
                      child: Opacity(
                        opacity: WinClaimed
                            ? 0.5
                            : 1.0, // Reduce opacity if disabled
                        child: PlayingCardView(
                          card: jokerCard,
                          showBack: false,
                          style: myCardStyles,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                            side: const BorderSide(color: Colors.red, width: 1),
                          ),
                        ),
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
    return Stack(
      children: [
        Positioned(
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
                  _showMessageDialog(
                      context, "Please wait for Player 2's turn");
                } else if (totalCardCount == 14) {
                  _showMessageDialog(
                      context, "Please select a card to discard");
                } else {
                  PickFromClosedDeck();
                }
              },
              child: Opacity(
                opacity: WinClaimed ? 0.5 : 1.0, // Reduce opacity if disabled
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
          ),
        ),
        if (WinClaimed)
          Positioned.fill(
            child: AbsorbPointer(),
          ),
      ],
    );
  }

  Widget _buildDiscardPile({bool show = true}) {
    final PlayingCard? topCard =
        discardPile.isNotEmpty ? discardPile.first : null;
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.43,
      left: MediaQuery.of(context).size.width * 0.59,
      child: AbsorbPointer(
        absorbing:
            WinClaimed, // Disable interaction based on the 'show' parameter
        child: Opacity(
          opacity: WinClaimed ? 0.5 : 1.0, // Reduce opacity if disabled
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.20,
              maxWidth: MediaQuery.of(context).size.width * 0.15,
            ),
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
                            side:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        )
                      : Container(),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1.0,
                    ),
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
        ),
      ),
    );
  }

  void refreshHands() {
    allHands = allHands.where((hand) => hand.isNotEmpty).toList();
  }

  Widget _buildCurrentCard() {
    int maxHands = 5;
    int maxCardsPerHand = 10;

    List<Widget> cardWidgets = [];

    for (int index = 0; index < maxHands * maxCardsPerHand; index++) {
      final handIndex = index ~/ maxCardsPerHand;
      final cardIndex = index % maxCardsPerHand;

      final hand = handIndex < allHands.length ? allHands[handIndex] : [];
      final card =
          hand != null && cardIndex < hand.length ? hand[cardIndex] : null;

      if (card == null) {
        cardWidgets.add(SizedBox(key: Key('empty$index')));
      } else {
        cardWidgets.add(
          SizedBox(
            key: Key('card$index'),
            child: Stack(
              children: [
                Positioned(
                  child: Container(
                    width: 120.0,
                    height: 95.0,
                    child: DragTarget<PlayingCard>(
                      onAccept: (card) {
                        setState(() {
                          allHands[startingHandIndex]
                              .removeAt(startingCardIndex);
                          allHands[handIndex].insert(cardIndex, card);
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return SizedBox(
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

                                      if (selectedCardIndexes.length == 1 &&
                                          totalCardCount > 13) {
                                        buttonText = 'Discard';
                                        showButton = true;
                                      } else if (selectedCardIndexes.length >
                                          1) {
                                        buttonText = 'Group';
                                        showButton = true;
                                      } else {
                                        showButton = false;
                                      }
                                    }); // Add your desired logic for the tap gesture here
                                  },
                                  child: Draggable<PlayingCard>(
                                    //axis: Axis.horizontal,
                                    data: card,
                                    onDragStarted: () {
                                      startingHandIndex = handIndex;
                                      startingCardIndex = cardIndex;
                                    },
                                    child: SizedBox(
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: selectedCardIndexes
                                                        .contains(handIndex *
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
                                              selectedCardIndexes
                                                  .contains(index) &&
                                              index == selectedCardIndexes.last)
                                            Positioned(
                                              top:
                                                  -20.0, // Adjust the value to move the button above the cards
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top:
                                                        15.0), // Add spacing between the button and cards
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    if (buttonText ==
                                                        'Discard') {
                                                      setState(() {
                                                        // Get the selected card
                                                        final discardedCard = allHands[
                                                                selectedCardIndexes
                                                                        .first ~/
                                                                    maxCardsPerHand]
                                                            [selectedCardIndexes
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
                                                        selectedCardIndexes
                                                            .clear();
                                                      });
                                                    }
                                                    if (buttonText == 'Group') {
                                                      setState(() {
                                                        try {
                                                          // Combine selected cards into a single list
                                                          final selectedHand =
                                                              selectedCardIndexes
                                                                  .map((index) {
                                                            print(index);
                                                            final handIndex =
                                                                index ~/
                                                                    maxCardsPerHand;
                                                            final cardIndex =
                                                                index %
                                                                    maxCardsPerHand;
                                                            print(
                                                                'handindex$handIndex');
                                                            print(
                                                                'cardindex$cardIndex');
                                                            print(
                                                                "===================");
                                                            final selectedCard =
                                                                allHands[
                                                                        handIndex]
                                                                    [cardIndex];
                                                            return selectedCard;
                                                          }).toList();

                                                          selectedCardIndexes
                                                              .forEach((index) {
                                                            final handIndex =
                                                                index ~/
                                                                    maxCardsPerHand;
                                                            final cardIndex =
                                                                index %
                                                                    maxCardsPerHand;

                                                            allHands[handIndex]
                                                                .removeAt(
                                                                    cardIndex); // Remove the card from the original hand
                                                          });

                                                          if (allHands.length >=
                                                              maxHands) {
                                                            // Find the hand with the fewest cards
                                                            int minCardCount =
                                                                allHands[0]
                                                                    .length;
                                                            int minCardHandIndex =
                                                                0;
                                                            for (int i = 1;
                                                                i <
                                                                    allHands
                                                                        .length;
                                                                i++) {
                                                              if (allHands[i]
                                                                      .length <
                                                                  minCardCount) {
                                                                minCardCount =
                                                                    allHands[i]
                                                                        .length;
                                                                minCardHandIndex =
                                                                    i;
                                                              }
                                                            }

                                                            // Add the remaining cards from selectedHand to the hand with the fewest cards
                                                            allHands[
                                                                    minCardHandIndex]
                                                                .addAll(
                                                                    selectedHand);
                                                          } else {
                                                            allHands.insert(0,
                                                                selectedHand); // Add the new group at the beginning of the list
                                                          }

                                                          selectedCardIndexes
                                                              .clear();
                                                          buttonText = '';
                                                          showButton = false;
                                                          setState(() {});
                                                        } catch (e, stackTrace) {
                                                          // Handle errors
                                                          debugPrint(
                                                              'An error occurred while grouping cards:');
                                                          debugPrint(
                                                              'Error: $e');
                                                          debugPrint(
                                                              'StackTrace: $stackTrace');
                                                          // Perform additional error handling as needed
                                                        }
                                                      });
                                                    } else {}
                                                  },
                                                  child: Text(buttonText),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    feedback: Material(
                                      child: Container(
                                        height: 100.0,
                                        width: 80.0,
                                        child: PlayingCardView(
                                          card: card,
                                          showBack: false,
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
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      child: Stack(
        children: [
          // Other widgets in the stack
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            width: MediaQuery.of(context).size.width,
            child: Container(
              //color: Colors.blue,
              child: FlatCardFan(children: cardWidgets),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return Stack(
      children: [
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.42,
          left: MediaQuery.of(context).size.width * 0.25,
          child: DragTarget<PlayingCard>(
            onAccept: (card) {
              setState(() {
                print("cardaccepted");
                acceptedCard = card;
                allHands[startingHandIndex].removeAt(startingCardIndex);
              });
            },
            onMove: (details) {
              setState(() {});
            },
            builder: (BuildContext context, List<dynamic> candidateData,
                List<dynamic> rejectedData) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width * 0.14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: acceptedCard != null
                        ? Colors.transparent
                        : Color.fromRGBO(0, 0, 0, 1),
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
                  child: acceptedCard != null
                      ? PlayingCardView(
                          card: acceptedCard!,
                          showBack: false,
                          style: myCardStyles,
                        )
                      : Text(
                          'Drop for \n show',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
