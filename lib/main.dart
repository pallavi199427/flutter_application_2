import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/homepage2.dart';
import 'package:flutter_application_2/homepage.dart';
import 'package:flutter_application_2/splash.dart';
import 'package:flutter_application_2/widgets/cardpickup.dart';
import 'package:flutter_application_2/widgets/ShrinkAnimation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter binding

  runApp(Rummy());
}

class Rummy extends StatefulWidget {
  @override
  _RummyState createState() => _RummyState();
}

class _RummyState extends State<Rummy> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rummy Game',
      home: MyHomePage(),
    );
  }
}
