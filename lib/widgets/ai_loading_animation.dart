import 'package:flutter/material.dart';
import '../painters/consciousness_wave_painter.dart';

class AILoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;

  const AILoadingAnimation({
    super.key,
    this.size = 40.0,
    this.color,
  });

  @override
  State<AILoadingAnimation> createState() => _AILoadingAnimationState();
}

class _AILoadingAnimationState extends State<AILoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _phaseController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    
    _phaseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _phaseController,
          _pulseController,
          _shimmerController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: ConsciousnessWavePainter(
              phase: _phaseController.value,
              pulseIntensity: _pulseController.value,
              shimmerPhase: _shimmerController.value,
              color: widget.color ?? const Color(0xFF89A8B2),
            ),
          );
        },
      ),
    );
  }
}
