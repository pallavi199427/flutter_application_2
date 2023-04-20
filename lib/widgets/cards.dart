import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_application_2/widgets/bottomBar.dart';
import 'package:flutter_application_2/widgets/player2widget.dart';
import 'package:flutter_application_2/widgets/background.dart';

PlayingCardViewStyle myCardStyles = PlayingCardViewStyle(suitStyles: {
  Suit.spades: SuitStyle(
      builder: (context) => FittedBox(
            child: Text(
              "",
              style: TextStyle(fontSize: 2),
            ),
          ),
      style: TextStyle(color: Colors.white),
      cardContentBuilders: {
        CardValue.ace: (context) => Image.asset(
              "assets/1_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.two: (context) => Image.asset(
              "assets/2_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.three: (context) => Image.asset(
              "assets/3_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.four: (context) => Image.asset(
              "assets/4_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.five: (context) => Image.asset(
              "assets/5_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.six: (context) => Image.asset(
              "assets/6_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.seven: (context) => Image.asset(
              "assets/7_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.eight: (context) => Image.asset(
              "assets/8_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.nine: (context) => Image.asset(
              "assets/9_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.ten: (context) => Image.asset(
              "assets/10_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.jack: (context) => Image.asset(
              "assets/11_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.queen: (context) => Image.asset(
              "assets/12_spades.png",
              width: 400,
              height: 300,
            ),
        CardValue.king: (context) => Image.asset(
              "assets/13_spades.png",
              width: 400,
              height: 300,
            ),
      }),
  Suit.hearts: SuitStyle(
      builder: (context) => FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              "",
              style: TextStyle(fontSize: 5),
            ),
          ),
      style: TextStyle(color: Colors.white),
      cardContentBuilders: {
        CardValue.ace: (context) => Image.asset(
              "assets/1_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.two: (context) => Image.asset(
              "assets/2_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.three: (context) => Image.asset(
              "assets/3_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.four: (context) => Image.asset(
              "assets/4_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.five: (context) => Image.asset(
              "assets/5_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.six: (context) => Image.asset(
              "assets/6_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.seven: (context) => Image.asset(
              "assets/7_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.eight: (context) => Image.asset(
              "assets/8_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.nine: (context) => Image.asset(
              "assets/9_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.ten: (context) => Image.asset(
              "assets/10_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.jack: (context) => Image.asset(
              "assets/11_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.queen: (context) => Image.asset(
              "assets/12_hearts.png",
              width: 400,
              height: 300,
            ),
        CardValue.king: (context) => Image.asset(
              "assets/13_hearts.png",
              width: 400,
              height: 300,
            ),
      }),
  Suit.clubs: SuitStyle(
      builder: (context) => FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              "",
              style: TextStyle(fontSize: 5),
            ),
          ),
      style: TextStyle(color: Colors.white),
      cardContentBuilders: {
        CardValue.ace: (context) => Image.asset(
              "assets/1_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.two: (context) => Image.asset(
              "assets/2_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.three: (context) => Image.asset(
              "assets/3_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.four: (context) => Image.asset(
              "assets/4_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.five: (context) => Image.asset(
              "assets/5_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.six: (context) => Image.asset(
              "assets/6_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.seven: (context) => Image.asset(
              "assets/7_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.eight: (context) => Image.asset(
              "assets/8_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.nine: (context) => Image.asset(
              "assets/9_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.ten: (context) => Image.asset(
              "assets/10_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.jack: (context) => Image.asset(
              "assets/11_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.queen: (context) => Image.asset(
              "assets/12_clubs.png",
              width: 400,
              height: 300,
            ),
        CardValue.king: (context) => Image.asset(
              "assets/13_clubs.png",
              width: 400,
              height: 300,
            ),
      }),
  Suit.diamonds: SuitStyle(
      builder: (context) => FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              "",
              style: TextStyle(fontSize: 5),
            ),
          ),
      style: TextStyle(color: Colors.white),
      cardContentBuilders: {
        CardValue.ace: (context) => Image.asset(
              "assets/1_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.two: (context) => Image.asset(
              "assets/2_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.three: (context) => Image.asset(
              "assets/3_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.four: (context) => Image.asset(
              "assets/4_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.five: (context) => Image.asset(
              "assets/5_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.six: (context) => Image.asset(
              "assets/6_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.seven: (context) => Image.asset(
              "assets/7_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.eight: (context) => Image.asset(
              "assets/8_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.nine: (context) => Image.asset(
              "assets/9_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.ten: (context) => Image.asset(
              "assets/10_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.jack: (context) => Image.asset(
              "assets/11_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.queen: (context) => Image.asset(
              "assets/12_diamonds.png",
              width: 400,
              height: 300,
            ),
        CardValue.king: (context) => Image.asset(
              "assets/13_diamonds.png",
              width: 400,
              height: 300,
            ),
      })
});
