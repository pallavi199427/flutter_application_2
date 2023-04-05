import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
    required this.playerName,
  }) : super(key: key);

  final String playerName;

  Future<String> fetchWinner() async {
    var response = await http.get(Uri.parse('http://127.0.0.1:5000/win'));
    var jsonResponse = jsonDecode(response.body);
    String win = jsonResponse['win'];
    return win;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RandomAvatar(
                playerName,
                height: 50.0,
                width: 50.0,
              ),
              SizedBox(
                width: 2.0,
              ), // add some spacing between the avatar and the text
              Text(
                playerName,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            child: Text('Show'),
            onPressed: () async {
              String win = await fetchWinner();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: Text(
                      'Winner',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      win,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16.0,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
