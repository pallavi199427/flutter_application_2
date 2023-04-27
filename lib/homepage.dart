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
  String ip = '127.0.0.1';
  bool showButton = false;
  List<PlayingCard> playingCards = [];
  List<PlayingCard> secondset = [];
  List<PlayingCard> thirdset = [];
  List<PlayingCard> fourthset = [];
  List<PlayingCard> fifthset = [];

  List<PlayingCard> currentCards = [];
  List<List<PlayingCard>> allHands = [];

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
      print("here");

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
    fetchData('http://$ip:8000/InitializeGame');
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
          shrinkWrap: true,
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
              return SizedBox(key: Key('empty$index'), width: 1, height: 0);
            }

            bool isHandFinished = hand.length == cardIndex + 1;

            // Check if the current card should have the ElevatedButton displayed
            return Stack(
              key: Key('$handIndex$cardIndex'),
              children: [
                GestureDetector(
                  key: Key('$handIndex$cardIndex'),
                  child: SizedBox(
                    key: Key('$handIndex$cardIndex'),
                    height: MediaQuery.of(context).size.height * 0.24,
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        child: PlayingCardView(
                          card: card,
                          showBack: false,
                          style: myCardStyles,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                            side:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: isSelectedCard
                              ? Colors.blue.withOpacity(0.5)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isHandFinished)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 10,
                  ),
              ],
            );
          },
          itemCount: allHands.length * 5,
          onReorder: (oldIndex, newIndex) {},
        ),
      ),
    );
  }
}
