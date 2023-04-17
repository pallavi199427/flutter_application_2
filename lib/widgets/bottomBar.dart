import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import 'package:flutter_application_2/widgets/timer.dart';

class BottomBar extends StatelessWidget {
  final String playerName;
  final Function toggleTimerVisibility;
  final bool showTimer;
  final Function onComplete; // <-- Add this

  const BottomBar({
    Key? key,
    required this.playerName,
    required this.toggleTimerVisibility,
    required this.showTimer,
    required this.onComplete, // <-- Add this
  }) : super(key: key);

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
              durationInSeconds: 30,
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
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () async {},
          ),
        ],
      ),
    );
  }
}
