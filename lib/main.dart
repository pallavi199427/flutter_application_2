import 'package:flutter/material.dart';
import 'package:flutter_application_2/homepage2.dart';
import 'package:flutter_application_2/homepage.dart';
import 'package:flutter_application_2/widgets/cardpickup.dart';

void main() {
  runApp(Rummy());
}

class Rummy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rummy Game',
      home: MyHomePage(),
    );
  }
}
