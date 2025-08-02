import 'dart:math';
import 'package:flutter/material.dart';

// Consciousness wave painter for sentient AI avatar - restored sophisticated version
class ConsciousnessWavePainter extends CustomPainter {
  final double phase;
  final double pulseIntensity;
  final double shimmerPhase;
  final Color color;

  ConsciousnessWavePainter({
    required this.phase,
    required this.pulseIntensity,
    required this.shimmerPhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw consciousness waves emanating from center
    for (int waveIndex = 0; waveIndex < 4; waveIndex++) {
      final wavePhase = (phase + waveIndex * 0.25) % 1.0;
      final waveRadius = wavePhase * 100 + 25;
      final waveOpacity = (1 - wavePhase) * 0.6 * (0.8 + pulseIntensity * 0.4); // More visible
      
      // Dynamic RGB digital palette for each wave
      final waveColors = [
        Color(0xFF3B82F6), // Electric blue (B)
        Color(0xFF10B981), // Digital green (G)
        Color(0xFFEF4444), // Digital red (R)
        Color(0xFF06B6D4), // Cyan (B+G)
      ];
      
      final waveColor = waveColors[waveIndex % waveColors.length];
      final colorIntensity = 0.7 + sin(shimmerPhase * 3 * pi + waveIndex) * 0.3;
      
      final wavePaint = Paint()
        ..color = waveColor.withOpacity(waveOpacity * colorIntensity)
        ..strokeWidth = 2.5 + sin(shimmerPhase * 2 * pi + waveIndex) * 0.8 // Thicker lines
        ..style = PaintingStyle.stroke;
      
      // Create organic wave with consciousness fluctuations
      final path = Path();
      final angleStep = (2 * pi) / 32;
      bool firstPoint = true;
      
      for (double angle = 0; angle < 2 * pi; angle += angleStep) {
        final fluctuation = sin(angle * 4 + shimmerPhase * 2 * pi) * 2 +
                          cos(angle * 6 + phase * 2 * pi) * 1.5;
        final radius = waveRadius + fluctuation;
        final x = center.dx + cos(angle) * radius;
        final y = center.dy + sin(angle) * radius;
        
        if (firstPoint) {
          path.moveTo(x, y);
          firstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, wavePaint);
    }
    
    // Draw neural synapses - more visible with dynamic colors
    for (int synapseIndex = 0; synapseIndex < 8; synapseIndex++) {
      final synapsePhase = (shimmerPhase + synapseIndex * 0.125) % 1.0;
      final angle = (synapseIndex / 8) * 2 * pi;
      final synapseRadius = 40 + sin(synapsePhase * 2 * pi) * 10;
      final synapseX = center.dx + cos(angle + synapsePhase * 0.5 * pi) * synapseRadius;
      final synapseY = center.dy + sin(angle + synapsePhase * 0.5 * pi) * synapseRadius;
      
      // Subtle RGB digital synapse palette
      final synapseColors = [
        Color(0xFF3B82F6), // Digital blue
        Color(0xFF10B981), // Digital green
        Color(0xFFEF4444), // Digital red
        Color(0xFF06B6D4), // Cyan (blue+green)
        Color(0xFF8B5CF6), // Purple (blue+red)
        Color(0xFFF59E0B), // Digital yellow (red+green)
        Color(0xFF2563EB), // Deep blue
        Color(0xFF059669), // Deep green
      ];
      
      final synapseColor = synapseColors[synapseIndex % synapseColors.length];
      final colorPulse = 0.6 + sin(synapsePhase * 4 * pi + synapseIndex) * 0.4;
      
      final synapsePaint = Paint()
        ..color = synapseColor.withOpacity((sin(synapsePhase * 2 * pi) * 0.4 + 0.5).abs() * colorPulse) // More visible with color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(synapseX, synapseY),
        2.0 + sin(synapsePhase * 4 * pi) * 1.0, // Larger size
        synapsePaint,
      );
    }
    
    // Draw quantum entanglement lines with energy colors
    for (int lineIndex = 0; lineIndex < 6; lineIndex++) {
      final linePhase = (phase + lineIndex * 0.167) % 1.0;
      final startAngle = (lineIndex / 6) * 2 * pi;
      final endAngle = startAngle + pi + sin(linePhase * 2 * pi) * 0.3;
      
      final startRadius = 25 + cos(linePhase * 3 * pi) * 8;
      final endRadius = 35 + sin(linePhase * 4 * pi) * 10;
      
      final startX = center.dx + cos(startAngle) * startRadius;
      final startY = center.dy + sin(startAngle) * startRadius;
      final endX = center.dx + cos(endAngle) * endRadius;
      final endY = center.dy + sin(endAngle) * endRadius;
      
      // RGB digital connection colors
      final lineColors = [
        Color(0xFF3B82F6), // Digital blue (B)
        Color(0xFF10B981), // Digital green (G)
        Color(0xFFEF4444), // Digital red (R)
        Color(0xFF06B6D4), // Cyan (B+G)
        Color(0xFF8B5CF6), // Purple (B+R)
        Color(0xFFF59E0B), // Yellow (R+G)
      ];
      
      final lineColor = lineColors[lineIndex % lineColors.length];
      final energyPulse = 0.5 + sin(linePhase * 5 * pi + lineIndex * 2) * 0.5;
      
      final linePaint = Paint()
        ..color = lineColor.withOpacity((sin(linePhase * 2 * pi) * 0.3 + 0.4).abs() * energyPulse) // More visible with energy
        ..strokeWidth = 1.2 + sin(linePhase * 6 * pi) * 0.5 // Thicker lines
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
