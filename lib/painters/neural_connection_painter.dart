import 'dart:math';
import 'package:flutter/material.dart';

// Neural connection painter for consciousness effects
class NeuralConnectionPainter extends CustomPainter {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double opacity;
  final Color color;
  final double phase;

  NeuralConnectionPainter({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.opacity,
    required this.color,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 1.5 + sin(phase * 4 * pi) * 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create neural connection path with organic curves
    final path = Path();
    path.moveTo(startX, startY);
    
    final controlX1 = startX + (endX - startX) * 0.3 + cos(phase * 6 * pi) * 20;
    final controlY1 = startY + (endY - startY) * 0.2 + sin(phase * 5 * pi) * 15;
    final controlX2 = startX + (endX - startX) * 0.7 + sin(phase * 4 * pi) * 25;
    final controlY2 = startY + (endY - startY) * 0.8 + cos(phase * 3 * pi) * 20;
    
    path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
    
    canvas.drawPath(path, paint);
    
    // Add energy nodes along the path
    final nodeCount = 3;
    for (int i = 0; i < nodeCount; i++) {
      final t = (i + 1) / (nodeCount + 1);
      final nodeOpacity = (sin(phase * 3 * pi + i * pi) * 0.5 + 0.5).abs();
      
      final nodeX = startX + (endX - startX) * t + sin(phase * 8 * pi + i) * 10;
      final nodeY = startY + (endY - startY) * t + cos(phase * 6 * pi + i) * 8;
      
      final nodePaint = Paint()
        ..color = color.withOpacity((opacity * nodeOpacity).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(nodeX, nodeY),
        2 + sin(phase * 10 * pi + i) * 1,
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
