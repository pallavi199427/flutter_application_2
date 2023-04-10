// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_2/functions/functions.dart';
import 'package:random_avatar/random_avatar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/homepage2.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
    required this.playerName,
  }) : super(key: key);

  final String playerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      decoration: const BoxDecoration(
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
              const SizedBox(
                width: 2.0,
              ), // add some spacing between the avatar and the text
              Text(
                playerName,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () async {},
          ),
        ],
      ),
    );
  }
}
