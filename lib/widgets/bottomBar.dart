import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/widgets/timer.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
    required this.playerName,
  }) : super(key: key);

  final String playerName;

  Future<void> getWin(BuildContext context) async {
    final response = await http.get(Uri.parse('http://0.0.0.0:8000/GetWin'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final winnerData = jsonData['Win'][0];
      final player1Score = int.parse(winnerData['Player1']);
      final player2Score = int.parse(winnerData['Player2']);

      // Determine the winner based on the scores
      String winnerLabel = '';
      if (player1Score > player2Score) {
        winnerLabel = 'Player 1 wins!';
      } else if (player2Score > player1Score) {
        winnerLabel = 'Player 2 wins!';
      } else {
        winnerLabel = 'It\'s a tie!';
      }

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
                        player1Score > player2Score ? 'Won' : 'Lost',
                        style: TextStyle(
                          color: player1Score > player2Score
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(player1Score.toString()),
                      Text(''),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Player 2'),
                      Text(
                        player2Score > player1Score ? 'Won' : 'Lost',
                        style: TextStyle(
                          color: player2Score > player1Score
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(player2Score.toString()),
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
          CountdownTimerWidget(
            durationInSeconds: 30,
            onTimerComplete: () {
              // Do something when the countdown is complete
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () async {
              getWin(context);
            },
          ),
        ],
      ),
    );
  }
}
