import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/homepage2.dart';
import 'package:flutter_application_2/homepage.dart';
import 'package:flutter_application_2/splash.dart';
import 'package:flutter_application_2/widgets/cardpickup.dart';

Future<void> main() async {
  runApp(Rummy());
}

class Rummy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rummy Game',
      home: MyHomePage2(),
    );
  }
}
