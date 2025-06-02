import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBubbleBackground extends StatefulWidget {
  const AnimatedBubbleBackground({super.key});

  @override
  State<AnimatedBubbleBackground> createState() =>
      _AnimatedBubbleBackgroundState();
}

class _AnimatedBubbleBackgroundState extends State<AnimatedBubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Bubble> _bubbles = [];
  final int numberOfBubbles = 50;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat();

    for (int i = 0; i < numberOfBubbles; i++) {
      _bubbles.add(_Bubble(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 40 + 10,
        speed: random.nextDouble() * 0.005 + 0.002,
        opacity: random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateBubbles() {
    for (var bubble in _bubbles) {
      bubble.y -= bubble.speed;
      if (bubble.y < -bubble.size / 100) {
        bubble.x = random.nextDouble();
        bubble.y = 1.2;
        bubble.size = random.nextDouble() * 40 + 10;
        bubble.speed = random.nextDouble() * 0.005 + 0.002;
        bubble.opacity = random.nextDouble() * 0.5 + 0.3;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          _updateBubbles();
          return CustomPaint(
            painter: _BubblePainter(_bubbles),
            child: Container(),
          );
        });
  }
}

class _Bubble {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;

  _BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    for (var bubble in bubbles) {
      final Offset position = Offset(bubble.x * size.width, bubble.y * size.height);
      paint.color = Colors.greenAccent.withOpacity(bubble.opacity);
      canvas.drawCircle(position, bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
