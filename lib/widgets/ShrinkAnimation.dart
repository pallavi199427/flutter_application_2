import 'package:flutter/material.dart';

class ShrinkAnimation extends StatefulWidget {
  final double initialPosition;
  final double targetPosition;
  final String imagePath;

  ShrinkAnimation({
    required this.initialPosition,
    required this.targetPosition,
    required this.imagePath,
  });

  @override
  _ShrinkAnimationState createState() => _ShrinkAnimationState();
}

class _ShrinkAnimationState extends State<ShrinkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, widget.initialPosition),
      end: Offset(0.0, widget.targetPosition),
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.isCompleted
        ? SizedBox.shrink()
        : AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Transform.translate(
                offset: _slideAnimation.value,
                child: Opacity(
                  opacity: _animation.value,
                  child: Transform.scale(
                    scale: _animation.value,
                    child: Image.asset(
                      widget.imagePath,
                      height: 200.0,
                      width: 200.0,
                    ),
                  ),
                ),
              );
            },
          );
  }
}
