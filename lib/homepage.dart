import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_application_2/widgets/bottomBar.dart';
import 'package:flutter_application_2/widgets/player2widget.dart';
import 'package:flutter_application_2/widgets/background.dart';
import 'package:flutter_application_2/functions/card_value.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // Declare variables at the top of the class

  List<PlayingCard> discardPile = [];
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    fetchData('http://0.0.0.0:8000/InitializeGame');

    // Initialize the animation controller and animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(_controller!);
  }

  void fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      print("first initalizaition");

      // Parse discard pile card
      final discardData = jsonData['OpenDeck'];
      List<PlayingCard> discardCards =
          List<PlayingCard>.from(discardData.map((card) {
        final cardValue = parseCardValue(card['CardValue']);
        final suit = card['Suit'];
        return PlayingCard(
          Suit.values.byName(suit),
          CardValue.values.byName(cardValue),
        );
      }));
      discardPile = discardCards;
      print(discardPile);

      setState(() {});
    } else {
      throw Exception('Failed to load game state');
    }
  }

  void _playAnimation() {
    // Start the animation when this function is called
    _controller!.forward(from: 0);
  }

  @override
  void dispose() {
    // Clean up the animation controller when the widget is disposed
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          background(),
          _buildDiscardPile(),
        ],
      ),
    );
  }

  Widget _buildDiscardPile() {
    final PlayingCard? topCard =
        discardPile.isNotEmpty ? discardPile.last : null;

    return Positioned(
      bottom: 100, // fixed value for the bottom position
      left: 300, // fixed value for the left position
      child: SizedBox(
        height: 200, // or some other fixed height
        width: 150, // fixed width of the discard pile
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom: topCard != null ? 10 : 0,
              left: topCard != null ? 10 : 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: topCard != null
                    ? PlayingCardView(
                        card: topCard,
                        showBack: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                      )
                    : Container(),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  discardPile.removeLast();
                });

                _animateDiscardPile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _animateDiscardPile() async {
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {});

    await Future.delayed(Duration(milliseconds: 200));

    setState(() {
      discardPile.isNotEmpty ? discardPile.last : null;
    });
  }
}
