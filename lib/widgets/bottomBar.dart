// ignore_for_file: prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import 'package:flutter_application_2/widgets/timer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/homepage2.dart';

class BottomBar extends StatefulWidget {
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

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  bool _isRestarting = false;
  bool _isInitialized = false;

  Future<void> _restartGame() async {
    setState(() {
      _isRestarting = true;
    });

    void _showMessageDialog(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 7, 61, 141),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: const Center(
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
              style: const TextStyle(
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
                      color: const Color.fromARGB(255, 9, 132, 13),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Center(
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

    final snackBar = const SnackBar(
      content: Text('Please wait ....Restarting game...'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    final url = 'http://127.0.0.1:8000/Reset';
    await http.post(Uri.parse(url)).then((value) {
      Future.delayed(const Duration(seconds: 7), () async {
        final url1 = 'http://127.0.0.1:8000/InitializeGame';
        await http.post(Uri.parse(url1));
        final response = await http.post(Uri.parse(url1));

        if (response.statusCode == 200) {
          setState(() {
            _isRestarting = false;
            _isInitialized = true;
          });
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage2()),
          );
        } else {
          // If the response is not valid, retry initialization after a delay
          await Future.delayed(const Duration(seconds: 5));
        }
      });
    });
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
          if (widget.showTimer) // Conditionally show the timer widget
            CountdownTimerWidget(
              ringColor: Colors.black,
              durationInSeconds: 30,
              onTimerComplete: () {
                getWin(context);
                widget.onComplete();
              },
            ),
          const SizedBox(width: 8.0), // Add spacing between the widgets
          Row(
            children: [
              RandomAvatar(
                widget.playerName,
                height: 50.0,
                width: 50.0,
              ),
              const SizedBox(
                width: 2.0,
              ), // add some spacing between the avatar and the text
              Text(
                widget.playerName,
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
              ElevatedButton(
                child: const Text('Restart Game'),
                onPressed: () {
                  _restartGame();
                },
              ),
              if (_isInitialized)
                FutureBuilder(
                  future: http
                      .post(Uri.parse('http://127.0.0.1:8000/InitializeGame')),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        _isRestarting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const Text('Game restarted!');
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getWin(BuildContext context) async {
    final response = await http.get(Uri.parse('http://127.0.0.1/GetWin'));
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
            backgroundColor: const Color.fromARGB(255, 73, 140, 223),
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
                        const Text(
                          'Player Name',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Text(
                          'Result',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Text(
                          'Score',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Text(
                          ' ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Player 1'),
                      Text(
                        Player1Label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(''),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Player 2'),
                      Text(
                        Player2Label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(''),
                    ],
                  ),
                  const SizedBox(height: 20),
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
}
