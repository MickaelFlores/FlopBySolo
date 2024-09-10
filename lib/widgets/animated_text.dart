import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isAnimating = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleAnimation() {
    setState(() {
      if (isAnimating) {
        _controller.stop();
      } else {
        _controller.repeat(reverse: true);
      }
      isAnimating = !isAnimating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleAnimation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [Colors.blue, Colors.red, Color(0xFF77ACA2)],
                stops: [
                  _controller.value - 0.2,
                  _controller.value,
                  _controller.value + 0.2,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: Text(
          'Flop By Solo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
