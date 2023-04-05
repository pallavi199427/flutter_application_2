import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class Player2Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double avatarSize = MediaQuery.of(context).size.width * 0.03;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.01;
    double verticalPadding = MediaQuery.of(context).size.height * 0.1;

    return Container(
      height: MediaQuery.of(context).size.height * 0.10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
