import 'dart:async';

import 'package:flutter/material.dart';

class CardPickupAnimationWrapper extends StatefulWidget {
  const CardPickupAnimationWrapper({Key? key}) : super(key: key);

  @override
  _CardPickupAnimationWrapperState createState() =>
      _CardPickupAnimationWrapperState();
}

class _CardPickupAnimationWrapperState extends State<CardPickupAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    print("animation called");
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: -150.0,
    ).animate(_controller);

    _sizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
      } else if (status == AnimationStatus.dismissed) {
        _controller.reset();
      }
    });
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, _positionAnimation.value),
          child: Transform.scale(
            scale: _sizeAnimation.value,
            child: Container(
              height: 200,
              child: Image.asset('assets/backcard.png'),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    _controller.forward();
  }
}
