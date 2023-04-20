import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:flutter_application_2/widgets/timer.dart';

class Player2Widget extends StatelessWidget {
  final bool showTimer;
  final Function toggleTimerVisibility;
  final Function onComplete;

  const Player2Widget({
    Key? key,
    required this.toggleTimerVisibility,
    required this.showTimer,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double avatarSize = MediaQuery.of(context).size.width * 0.03;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.01;

    return Container(
      height: 70, // Set the height of the row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // Set the width of the avatar and timer container
            child: Row(
              children: [
                RandomAvatar(
                  'Player 2',
                  height: avatarSize,
                  width: avatarSize,
                ),
                SizedBox(width: 10),
                Text(
                  'Player 2',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.012,
                    color: Color.fromARGB(255, 3, 38, 66),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (showTimer)
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.05,
                width: MediaQuery.of(context).size.width * 0.05,
                child: CountdownTimerWidget(
                  ringColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                  ),
                  durationInSeconds: 30,
                  onTimerComplete: () {
                    onComplete();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
