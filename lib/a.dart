import 'dart:convert';
import 'package:flutter_application_2/widgets/background.dart';
import 'package:flutter_application_2/widgets/cards.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PlayingCard> selectedCards = [];
  String buttonText = '';
  int? selectedCardIndex = -1;
  int selectedHandIndex = -1;
  bool showButton = false;

  String ip = '127.0.0.1';
  List<PlayingCard> playingCards = [];
  List<PlayingCard> secondset = [];
  List<PlayingCard> thirdset = [];
  List<PlayingCard> fourthset = [];
  List<PlayingCard> fifthset = [];

  List<PlayingCard> currentCards = [];
  List<List<PlayingCard>> allHands = [];

  void parseJsonData(Map<String, dynamic> jsonData) {
    final Map<String, dynamic> playerCardsData = jsonData['Loosing Hand'];
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

  Future<void> fetchData(String url) async {
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
    fetchData('http://$ip:5000/InitializeGame');
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 150.0;
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
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.55,
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.065),
          itemBuilder: (context, index) {
            final handIndex = index ~/ 5;
            final cardIndex = index % 5;
            final hand = allHands[handIndex];
            final card = hand.length > cardIndex ? hand[cardIndex] : null;
            bool isSelectedCard = cardIndex == selectedCardIndex &&
                handIndex == selectedHandIndex;
            bool isLastSelectedCard =
                isSelectedCard && selectedCards.length == 1;

            if (card == null) {
              // Return an empty SizedBox to hide the item
              return SizedBox(key: Key('empty$index'), width: 2, height: 0);
            }

            if (cardIndex == 0 && handIndex > 0) {
              // Return a SizedBox with the desired spacing after every hand
              return SizedBox(key: Key('empty$index'), width: 10);
            }

            return SizedBox(
              key: Key('$handIndex$cardIndex'),
              height: MediaQuery.of(context).size.height * 0.24,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    // When the card is tapped, update selectedCards list and showButton flag
                    if (isSelectedCard) {
                      selectedCards.remove(card);
                    } else {
                      selectedCards.add(card);
                    }

                    if (selectedCards.length == 1) {
                      selectedHandIndex = handIndex;
                      selectedCardIndex = cardIndex;
                      buttonText = 'Discard';
                      showButton = true;
                    } else if (selectedCards.length > 1) {
                      selectedHandIndex = handIndex;
                      selectedCardIndex = cardIndex;
                      buttonText = 'Group';
                      showButton = true;
                    } else {
                      showButton = false;
                    }
                  });

                  print(
                      'Selected cards: ${selectedCards.map((card) => '${card.suit} ${card.value}').join(', ')}');
                },
                child: Stack(
                  children: [
                    Container(
                      child: PlayingCardView(
                        card: card,
                        showBack: false,
                        style: myCardStyles,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: isSelectedCard
                            ? Colors.blue.withOpacity(0.5)
                            : null,
                      ),
                    ),
                    if (showButton &&
                        showButton &&
                        cardIndex == selectedCardIndex &&
                        handIndex ==
                            selectedHandIndex) // Conditionally show the ElevatedButton only for the last selected card
                      Positioned(
                        top: 0,
                        right: 0,
                        child: ElevatedButton(
                          onPressed: () {
                            if (buttonText == 'Discard') {
                            } else if (buttonText == "Group") {
                            } else {}
                          },
                          child: Text(buttonText),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          itemCount: allHands.length * 5,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final oldHandIndex = oldIndex ~/ 5;
              final oldCardIndex = oldIndex % 5;
              final oldCard = allHands[oldHandIndex][oldCardIndex];

              final newHandIndex = newIndex ~/ 5;
              final newCardIndex = newIndex % 5;
              final newCard = allHands[newHandIndex].length > newCardIndex
                  ? allHands[newHandIndex][newCardIndex]
                  : null;

              if (newCard != null) {
                allHands[oldHandIndex][oldCardIndex] = newCard;
                allHands[newHandIndex][newCardIndex] = oldCard;
              } else {
                allHands[newHandIndex].add(oldCard);
                allHands[oldHandIndex].removeAt(oldCardIndex);
              }
            });
          },
        ),
      ),
    );
  }
}
