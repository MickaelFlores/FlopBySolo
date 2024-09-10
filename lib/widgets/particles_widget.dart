import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/custom_particle.dart';

class ParticlesWidget extends StatefulWidget {
  final double height;
  final double width;

  ParticlesWidget({required this.height, required this.width});

  @override
  _ParticlesWidgetState createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticlesWidget> {
  late List<CustomParticle> particles;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    particles = createParticles();
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      updateParticles();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<CustomParticle> createParticles() {
    final center = Offset(widget.width / 2, widget.height / 2);
    return List<CustomParticle>.generate(
      100,
      (index) {
        final radius = 2.0 + Random().nextDouble() * 4.0;
        final speed = 0.5 + Random().nextDouble() * 0.5;
        final direction = Random().nextDouble() * 2 * pi;
        final velocity = Offset(
          speed * cos(direction),
          speed * sin(direction),
        );
        final color = Colors.white.withOpacity(0.5);
        return CustomParticle(
          radius: radius,
          speed: speed,
          direction: direction,
          position: center,
          velocity: velocity,
          color: color,
        );
      },
    );
  }

  void updateParticles() {
    for (var particle in particles) {
      final newPosition = particle.position + particle.velocity;

      // Check for boundaries and reverse velocity if necessary
      if (newPosition.dx <= 0 || newPosition.dx >= widget.width) {
        particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
      }
      if (newPosition.dy <= 0 || newPosition.dy >= widget.height) {
        particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
      }

      particle.position = newPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlesPainter(particles),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final List<CustomParticle> particles;

  ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
