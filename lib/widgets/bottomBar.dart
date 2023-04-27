import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import 'package:flutter_application_2/widgets/timer.dart';
import 'package:flutter_application_2/widgets/leaderboard.dart';
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

class BottomBar extends StatelessWidget {
  final String playerName;
  final Function toggleTimerVisibility;
  final bool showTimer;
  final Function onComplete;

  const BottomBar({
    Key? key,
    required this.playerName,
    required this.toggleTimerVisibility,
    required this.showTimer,
    required this.onComplete,
  }) : super(key: key);

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
                      'Leave Game',
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

  Future<void> getWin(BuildContext context) async {
    final response = await http.get(Uri.parse('http://0.0.0.0:8000/GetWin'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final winnerData = jsonData['GetWin'];
      final player1Score = (winnerData['Player1']);
      final player2Score = (winnerData['Player2']);

      // Determine the winner based on the scores
      /* String winnerLabel = '';
      if (player1Score > player2Score) {
        winnerLabel = 'Player 1 wins!';
      } else if (player2Score > player1Score) {
        winnerLabel = 'Player 2 wins!';
      } else {
        winnerLabel = 'It\'s a tie!';
      }*/
      String Player1Label = player1Score;
      String Player2Label = player2Score;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Color.fromARGB(255, 73, 140, 223),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Player Name',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Result',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Score',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          ' ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Player 1'),
                      Text(
                        Player1Label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(''),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Player 2'),
                      Text(
                        Player2Label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(''),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      throw Exception('Failed to load winner information');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showTimer) // Conditionally show the timer widget
            CountdownTimerWidget(
              ringColor: Colors.black,
              durationInSeconds: 60,
              onTimerComplete: () {
                onComplete(); // <-- Call it here
              },
            ),
          const SizedBox(width: 8.0), // Add spacing between the widgets
          Row(
            children: [
              RandomAvatar(
                playerName,
                height: 50.0,
                width: 50.0,
              ),
              const SizedBox(
                width: 2.0,
              ), // add some spacing between the avatar and the text
              Text(
                playerName,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () async {
                  getWin(context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
