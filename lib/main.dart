import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/homepage2.dart';
import 'package:flutter_application_2/widgets/leaderboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(Rummy());
  });
}

class Rummy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rummy Game',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage2(),
      },
    );
  }
}
