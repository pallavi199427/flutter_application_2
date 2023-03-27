import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();

  void onCardDiscarded(PlayingCard currentCard) {}
}

class _MyHomePageState extends State<MyHomePage> {
  // Declare variables at the top of the class
  List<PlayingCard> currentCards = [];
  int selectedCardIndex = -1;
  int _remainingSeconds = 30;
  Timer? _timer;

  void initState() {
    super.initState();

    _fetchGameStateData();
    _startTimer(); // Call new method to fetch game state data
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
        }
      });
    });
  }

  void _fetchGameStateData() async {
    final url = Uri.parse('http://127.0.0.1:5000');
    final response =
        await http.get(url); // Make HTTP GET request to retrieve game state

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

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

      setState(() {}); // Update the UI with the new game state data
    } else {
      throw Exception('Failed to load game state');
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
    return Scaffold(
      body: Stack(
        children: [
          _buildCurrentCard(),
          Positioned(
            top: 100.0,
            left: 500.0,
            child: _remainingTime(_remainingSeconds),
          ),
        ],
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
                            setState(() {});
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

  Widget _remainingTime(int remainingTime) {
    return Container(
      alignment: Alignment.center,
      width: 100,
      height: 100,
      child: CircularCountDownTimer(
        duration: remainingTime,
        controller: CountDownController(),
        width: 50,
        height: 50,
        ringColor: Colors.grey[300]!,
        fillColor: Colors.blue[600]!,
        strokeWidth: 10.0,
        textStyle: const TextStyle(
          fontSize: 20.0,
          color: Colors.black,
        ),
        isReverse: true,
        isTimerTextShown: true,
      ),
    );
  }
}
