import 'dart:math';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isListening;

  WavePainter({required this.animation, required this.isListening})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isListening) return;

    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2 + sin(animation.value * 2 * pi) * 10;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
        center, radius + 10, paint..color = Colors.blueAccent.withOpacity(0.3));
    canvas.drawCircle(
        center, radius + 20, paint..color = Colors.blueAccent.withOpacity(0.2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
