import 'dart:math';
import 'package:flutter/material.dart';

class AudioWavePainter extends CustomPainter {
  final AnimationController primaryAnimation;
  final AnimationController secondaryAnimation;
  final AnimationController pulseAnimation;
  final bool isActive;

  AudioWavePainter({
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.pulseAnimation,
    required this.isActive,
  }) : super(repaint: Listenable.merge([primaryAnimation, secondaryAnimation, pulseAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    _drawHorizontalWaves(canvas, size);
  }

  void _drawHorizontalWaves(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    _drawRealisticAudioWave(canvas, size, centerY);
  }

  void _drawRealisticAudioWave(Canvas canvas, Size size, double centerY) {
    final path = Path();
    final points = <Offset>[];
    
    // Increased amplitude for taller waves
    final baseAmplitude = 40.0 + pulseAnimation.value * 25; // Increased from 25.0 + 15
    final primaryFreq = 0.01;
    final timeOffset = primaryAnimation.value * 3 * pi;
    
    // Generate wave points with enhanced smoothness
    for (double x = 0; x <= size.width; x += 0.5) {
      final normalizedX = x / size.width;
      
      // Create envelope for natural audio wave characteristics
      final envelope = _calculateEnvelope(normalizedX);
      
      // Complex wave generation with smoother frequency components
      final wave1 = sin(x * primaryFreq + timeOffset) * 0.6;
      final wave2 = sin(x * primaryFreq * 1.618 + timeOffset * 1.1) * 0.3; // Golden ratio frequency
      final wave3 = sin(x * primaryFreq * 2.414 + timeOffset * 0.9) * 0.2; // Musical interval
      final wave4 = sin(x * primaryFreq * 3.732 + timeOffset * 1.4) * 0.1; // Harmonic series
      
      // Add subtle noise for organic feel
      final noise = _generatePerlinNoise(normalizedX, timeOffset) * 0.05;
      
      // Combine all components with envelope modulation
      final combinedWave = (wave1 + wave2 + wave3 + wave4 + noise) * envelope;
      
      // Apply smoother dynamic amplitude modulation with higher reach
      final dynamicAmplitude = baseAmplitude * (0.9 + 0.2 * sin(timeOffset * 0.5 + normalizedX * pi * 1.2));
      
      // Position wave higher to create better transition
      final y = (centerY * 0.7) + combinedWave * dynamicAmplitude; // Moved wave higher
      points.add(Offset(x, y));
    }
    
    // Create container-style filled path from bottom
    if (points.isNotEmpty) {
      path.moveTo(0, size.height);
      
      // Add smooth curve along wave points
      path.lineTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final previous = points[i - 1];
        
        // Create ultra-smooth control points for fluid motion
        final controlPoint1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.5,
          previous.dy + (current.dy - previous.dy) * 0.5,
        );
        final controlPoint2 = Offset(
          current.dx + (next.dx - current.dx) * 0.5,
          current.dy + (next.dy - current.dy) * 0.5,
        );
        
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          current.dx, current.dy,
        );
      }
      
      // Complete the path back to bottom
      path.lineTo(points.last.dx, points.last.dy);
      path.lineTo(size.width, size.height);
      path.close();
    }

    // Create realistic fluid gradient with natural water-like tones
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF7A9BA8), // Deeper blue-grey for realistic water surface
        Color(0xFF8FAAB7), // Natural water blue
        Color(0xFFA8C0CC), // Soft blue-grey
        Color(0xFFC4D6E0), // Light water tone
        Color(0xFFDDE9ED), // Very light blue-grey
        Color(0xFFF1F0E8), // Fade to background
      ],
      stops: [0.0, 0.15, 0.35, 0.55, 0.75, 1.0],
    );

    // Draw main container with consistent fluid effect
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
    
    // Draw clean, bold wave outline
    final outlinePath = Path();
    if (points.isNotEmpty) {
      outlinePath.moveTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final previous = points[i - 1];
        
        // Ultra-smooth control points for outline
        final controlPoint1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.5,
          previous.dy + (current.dy - previous.dy) * 0.5,
        );
        final controlPoint2 = Offset(
          current.dx + (next.dx - current.dx) * 0.5,
          current.dy + (next.dy - current.dy) * 0.5,
        );
        
        outlinePath.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          current.dx, current.dy,
        );
      }
    }
    
    // Realistic water outline with natural depth
    final outlinePaint = Paint()
      ..color = const Color(0xFF7A9BA8).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(outlinePath, outlinePaint);
    
    // Add subtle surface highlight for realistic water effect
    final highlightPaint = Paint()
      ..color = const Color(0xFFC4D6E0).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(outlinePath, highlightPaint);
  }

  // Calculate envelope for natural wave characteristics
  double _calculateEnvelope(double x) {
    // Create natural envelope with multiple peaks
    final envelope1 = sin(x * pi) * 0.8; // Main envelope
    final envelope2 = sin(x * pi * 2.5 + pi/4) * 0.3; // Secondary modulation
    final envelope3 = cos(x * pi * 1.7) * 0.2; // Tertiary variation
    
    return (envelope1 + envelope2 + envelope3).abs().clamp(0.3, 1.0);
  }

  // Simple Perlin-like noise for organic feel
  double _generatePerlinNoise(double x, double time) {
    final noise1 = sin(x * 50 + time * 2) * 0.5;
    final noise2 = sin(x * 127 + time * 1.3) * 0.3;
    final noise3 = sin(x * 233 + time * 0.8) * 0.2;
    
    return (noise1 + noise2 + noise3) / 3;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
