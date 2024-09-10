import 'package:flutter/material.dart';

class CustomParticle {
  double radius;
  double speed;
  double direction;
  Offset position;
  Offset velocity;
  Color color;

  CustomParticle({
    required this.radius,
    required this.speed,
    required this.direction,
    required this.position,
    required this.velocity,
    required this.color,
  });
}
