import 'package:flutter/material.dart';
import 'package:flutter_application_2/homepage2.dart';
import 'package:flutter_application_2/homepage.dart';

import 'package:flutter_application_2/splash.dart';
import 'package:flutter_application_2/widgets/cardpickup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyHomePage2(),
    );
  }
}
