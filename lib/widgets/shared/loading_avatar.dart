import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Dedicated loading avatar widget for waiting states
/// Optimized for loading animations without Hero conflicts
class LoadingAvatar extends StatefulWidget {
  final double size;
  final bool showGlow;
  final String? loadingText;

  const LoadingAvatar({
    super.key,
    this.size = 40.0,
    this.showGlow = true,
    this.loadingText,
  });

  @override
  State<LoadingAvatar> createState() => _LoadingAvatarState();
}

class _LoadingAvatarState extends State<LoadingAvatar>
    with TickerProviderStateMixin {
  late AnimationController _phaseController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    
    // Faster animations for loading state
    _phaseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _pulseController, // Use only the main pulse controller to reduce rebuilds
        builder: (context, child) {
          // Pre-calculate animation values to reduce computation during build
          final pulseValue = _pulseController.value;
          final phaseValue = _phaseController.value;
          final shimmerValue = _shimmerController.value;
          final breathingValue = _breathingController.value;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Enhanced glow effect for loading state
              if (widget.showGlow)
                ...List.generate(3, (layerIndex) {
                  final layerPhase = (phaseValue + layerIndex * 0.2) % 1.0;
                  final layerRadius = (widget.size * 0.4) + layerIndex * (widget.size * 0.1);
                  final layerOpacity = (sin(layerPhase * 4 * pi) * 0.3 + 0.2).abs();
                  final layerScale = 0.8 + (cos(layerPhase * 3 * pi) * 0.2).abs();
                  
                  return Transform.scale(
                    scale: layerScale,
                    child: Transform.rotate(
                      angle: layerPhase * 3 * pi * (layerIndex.isEven ? 1 : -1),
                      child: Container(
                        width: layerRadius * 2,
                        height: layerRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.mediumBlue.withOpacity(layerOpacity * 0.15),
                              AppColors.darkBlue.withOpacity(layerOpacity * 0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              // Pulsating dots around the avatar (reduced count for performance)
              if (widget.showGlow)
                ...List.generate(6, (dotIndex) { // Reduced from 8 to 6
                  final dotPhase = (shimmerValue + dotIndex * 0.167) % 1.0; // Adjusted for 6 dots
                  final angle = (dotIndex / 6) * 2 * pi;
                  final radius = (widget.size * 0.3) + sin(dotPhase * 3 * pi) * (widget.size * 0.05);
                  final dotX = cos(angle + dotPhase * pi) * radius;
                  final dotY = sin(angle + dotPhase * pi) * radius;
                  final dotOpacity = (sin(dotPhase * 4 * pi) * 0.4 + 0.6).abs();
                  final dotSize = 1.5 + sin(dotPhase * 2 * pi) * 0.5;
                  
                  return Transform.translate(
                    offset: Offset(dotX, dotY),
                    child: Opacity(
                      opacity: dotOpacity,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              AppColors.mediumBlue.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

              // Main avatar container with breathing effect
              Transform.scale(
                scale: 1.0 + sin(breathingValue * 2 * pi) * 0.05,
                child: Container(
                  width: widget.size * 0.65,
                  height: widget.size * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.darkBlue.withOpacity(0.5 + pulseValue * 0.3),
                        AppColors.mediumBlue.withOpacity(0.4 + pulseValue * 0.2),
                        AppColors.lightBackground.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: [
                        0.0,
                        0.3 + shimmerValue * 0.2,
                        0.7 + phaseValue * 0.1,
                        1.0,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkBlue.withOpacity(0.4 + pulseValue * 0.3),
                        blurRadius: 15 + pulseValue * 8,
                        spreadRadius: 2 + pulseValue * 3,
                        offset: Offset(0, sin(pulseValue * 2 * pi) * 1),
                      ),
                    ],
                  ),
                  child: _buildAvatarCore(pulseValue, phaseValue, shimmerValue),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatarCore(double pulseValue, double phaseValue, double shimmerValue) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(
            -1.0 + 2.0 * shimmerValue,
            -1.0 + sin(phaseValue * 4 * pi) * 0.4,
          ),
          end: Alignment(
            1.0 + 2.0 * shimmerValue,
            1.0 + cos(phaseValue * 3 * pi) * 0.4,
          ),
          colors: [
            AppColors.darkBlue,
            AppColors.mediumBlue.withOpacity(0.9 + pulseValue * 0.1),
            AppColors.lightBackground.withOpacity(0.8 + shimmerValue * 0.15),
            AppColors.darkBlue,
          ],
          stops: [
            0.0,
            0.25 + sin(shimmerValue * 4 * pi) * 0.15,
            0.75 + cos(shimmerValue * 3 * pi) * 0.15,
            1.0,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: Offset(0, 2 + sin(phaseValue * pi) * 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Core consciousness icon with enhanced animation
          Center(
            child: Transform.scale(
              scale: 1.0 + pulseValue * 0.12,
              child: Transform.rotate(
                angle: shimmerValue * 0.2 * pi,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      stops: [
                        0.0,
                        0.4 + pulseValue * 0.3,
                        0.7 + pulseValue * 0.2,
                        1.0,
                      ],
                    ).createShader(bounds);
                  },
                  child: Icon(
                    Icons.psychology_outlined,
                    color: Colors.white,
                    size: widget.size * 0.3,
                  ),
                ),
              ),
            ),
          ),

          // Enhanced shimmer overlay for loading
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  center: Alignment.center,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                  ],
                  stops: [
                    0.0,
                    0.1 + shimmerValue * 0.3,
                    0.5,
                    0.6 + shimmerValue * 0.3,
                    1.0,
                  ],
                  transform: GradientRotation(shimmerValue * 2 * pi),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
