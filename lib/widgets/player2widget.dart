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
      height: 50, // Set the height of the row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width *
                0.09, // Set the width of the avatar and timer container
            child: Row(
              children: [
                RandomAvatar(
                  'Player 2',
                  height: avatarSize,
                  width: avatarSize,
                ),
                SizedBox(width: horizontalPadding),
                Text(
                  'Player 2',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.012,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (showTimer)
            Container(
              height: avatarSize, // Set the height of the timer container
              width: avatarSize, // Set the width of the timer container
              child: CountdownTimerWidget(
                ringColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 22.0,
                  color: Colors.white, // change this to the desired color
                ),
                durationInSeconds: 30,
                onTimerComplete: () {
                  onComplete();
                },
              ),
            ),
        ],
      ),
    );
  }
}
