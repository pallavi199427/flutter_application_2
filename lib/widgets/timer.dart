import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int durationInSeconds;
  final Color ringColor;
  final Color fillColor;
  final double strokeWidth;
  final TextStyle textStyle;
  final bool isReverse;
  final bool isReverseAnimation;
  final VoidCallback onTimerComplete;
  bool isTimerRunning = true;
  CountdownTimerWidget({
    Key? key,
    required this.durationInSeconds,
    required this.onTimerComplete,
    this.ringColor = Colors.grey,
    this.fillColor = Colors.blue,
    this.strokeWidth = 2.0,
    this.textStyle = const TextStyle(
      fontSize: 22.0,
      color: Colors.black,
    ),
    this.isReverse = true,
    this.isReverseAnimation = true,
  }) : super(key: key);

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  CountDownController _controller = CountDownController();

  @override
  Widget build(BuildContext context) {
    return CircularCountDownTimer(
      duration: widget.durationInSeconds,
      controller: _controller,
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height / 2,
      ringColor: widget.ringColor,
      fillColor: _controller.getTime() != null &&
              int.tryParse(_controller.getTime()!) != null &&
              int.parse(_controller.getTime()!) > 0 &&
              int.parse(_controller.getTime()!) <= 10
          ? Colors.redAccent
          : widget.fillColor,
      strokeWidth: widget.strokeWidth,
      textStyle: widget.textStyle,
      isReverse: widget.isReverse,
      isReverseAnimation: widget.isReverseAnimation,
      onComplete: widget.onTimerComplete,
    );
  }
}
