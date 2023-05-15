import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/homepage2.dart';

import 'homepage.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  static const int gameStartDelaySeconds = 5;
  bool _showTimer = true;
  int _timerSecondsRemaining = gameStartDelaySeconds;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSecondsRemaining > 0) {
          _timerSecondsRemaining--;
        } else {
          _showTimer = false;
          timer.cancel();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => MyHomePage2(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _showTimer
              ? Text(
                  "Please wait while game starts in $_timerSecondsRemaining seconds...",
                  style: TextStyle(fontSize: 20),
                )
              : Text(
                  'To ensure fair play Player2 details will be displayed on screen ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
