import 'dart:math';
import 'package:flutter/material.dart';

class FloatingParticle extends StatelessWidget {
  final int index;
  final Animation<double> animation;

  const FloatingParticle({
    super.key,
    required this.index,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random(index);
    
    // Cool-toned particles with new palette
    final colors = [
      const Color(0xFF89A8B2), // Dark blue
      const Color(0xFFB3C8CF), // Medium blue
      const Color(0xFFE5E1DA), // Light beige
      const Color(0xFFF1F0E8), // Cream
      const Color(0xFF89A8B2), // Dark blue (repeated for variety)
      const Color(0xFFB3C8CF), // Medium blue (repeated for variety)
    ];
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = (animation.value + (index * 0.1)) % 1.0;
        final x = random.nextDouble() * size.width;
        final y = size.height * 0.2 + 
                  (size.height * 0.6 * progress) + 
                  sin(progress * pi * 4 + index) * 40;
        
        final opacity = (sin(progress * pi) * 0.2).clamp(0.0, 1.0);
        final scale = 0.2 + sin(progress * pi) * 0.3;
        
        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 1.5 + random.nextDouble() * 2.5,
              height: 1.5 + random.nextDouble() * 2.5,
              decoration: BoxDecoration(
                color: colors[index % colors.length].withOpacity(opacity),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors[index % colors.length].withOpacity(opacity * 0.3),
                    blurRadius: 3,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
