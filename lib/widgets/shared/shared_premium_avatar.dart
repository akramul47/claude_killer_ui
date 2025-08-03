import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../painters/consciousness_wave_painter.dart';

/// Shared premium avatar that can be used across different screens
/// with consistent animation and performance optimization
class SharedPremiumAvatar extends StatefulWidget {
  final double size;
  final String heroTag;
  final bool showGlow;
  final VoidCallback? onTap;

  const SharedPremiumAvatar({
    super.key,
    this.size = 120.0,
    this.heroTag = 'premium_avatar',
    this.showGlow = true,
    this.onTap,
  });

  @override
  State<SharedPremiumAvatar> createState() => _SharedPremiumAvatarState();
}

class _SharedPremiumAvatarState extends State<SharedPremiumAvatar>
    with TickerProviderStateMixin {
  late AnimationController _phaseController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _backgroundController;

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

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _phaseController,
              _pulseController,
              _shimmerController,
              _backgroundController,
            ]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Quantum consciousness field layers
                  if (widget.showGlow)
                    ...List.generate(4, (layerIndex) {
                      final layerPhase = (_backgroundController.value + layerIndex * 0.125) % 1.0;
                      final layerRadius = (widget.size * 0.3) + layerIndex * (widget.size * 0.08);
                      final layerOpacity = (sin(layerPhase * 3 * pi) * 0.2 + 0.1).abs();
                      final layerScale = 0.9 + (cos(layerPhase * 2 * pi) * 0.1).abs();
                      
                      return Transform.scale(
                        scale: layerScale,
                        child: Transform.rotate(
                          angle: layerPhase * 2 * pi * (layerIndex.isEven ? 1 : -1),
                          child: Container(
                            width: layerRadius * 2,
                            height: layerRadius * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.mediumBlue.withOpacity(layerOpacity * 0.1),
                                  AppColors.darkBlue.withOpacity(layerOpacity * 0.05),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 0.8, 1.0],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                  // Neural synapses firing
                  if (widget.showGlow)
                    ...List.generate(6, (synapseIndex) {
                      final synapsePhase = (_shimmerController.value + synapseIndex * 0.125) % 1.0;
                      final angle = (synapseIndex / 6) * 2 * pi;
                      final radius = (widget.size * 0.25) + sin(synapsePhase * 2 * pi) * (widget.size * 0.03);
                      final synapseX = cos(angle + synapsePhase * 0.5 * pi) * radius;
                      final synapseY = sin(angle + synapsePhase * 0.5 * pi) * radius;
                      final synapseOpacity = (sin(synapsePhase * 2 * pi) * 0.15 + 0.2).abs();
                      
                      return Transform.translate(
                        offset: Offset(synapseX, synapseY),
                        child: Opacity(
                          opacity: synapseOpacity,
                          child: Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),

                  // Consciousness waves
                  Builder(
                    builder: (context) {
                      try {
                        return CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: ConsciousnessWavePainter(
                            phase: _phaseController.value,
                            pulseIntensity: _pulseController.value,
                            shimmerPhase: _shimmerController.value,
                            color: AppColors.mediumBlue,
                          ),
                        );
                      } catch (e) {
                        // Fallback if CustomPaint fails
                        return Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                        );
                      }
                    },
                  ),

                  // Main avatar container
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(sin(_backgroundController.value * 2 * pi) * 0.02)
                      ..rotateY(cos(_backgroundController.value * 1.8 * pi) * 0.015)
                      ..scale(1.0 + sin(_pulseController.value * 2 * pi) * 0.02),
                    child: Container(
                      width: widget.size * 0.6,
                      height: widget.size * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.darkBlue.withOpacity(0.4 + _pulseController.value * 0.2),
                            AppColors.mediumBlue.withOpacity(0.3 + _pulseController.value * 0.1),
                            AppColors.lightBackground.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: [
                            0.0,
                            0.4 + _shimmerController.value * 0.1,
                            0.8 + _backgroundController.value * 0.1,
                            1.0,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkBlue.withOpacity(0.3 + _pulseController.value * 0.2),
                            blurRadius: 20 + _pulseController.value * 10,
                            spreadRadius: 3 + _pulseController.value * 5,
                            offset: Offset(0, sin(_pulseController.value * 2 * pi) * 2),
                          ),
                        ],
                      ),
                      child: _buildAvatarCore(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCore() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(
            -1.0 + 2.0 * _shimmerController.value,
            -1.0 + sin(_backgroundController.value * 3 * pi) * 0.3,
          ),
          end: Alignment(
            1.0 + 2.0 * _shimmerController.value,
            1.0 + cos(_backgroundController.value * 2 * pi) * 0.3,
          ),
          colors: [
            AppColors.darkBlue,
            AppColors.mediumBlue.withOpacity(0.9 + _pulseController.value * 0.05),
            AppColors.lightBackground.withOpacity(0.8 + _shimmerController.value * 0.1),
            AppColors.darkBlue,
          ],
          stops: [
            0.0,
            0.3 + sin(_shimmerController.value * 3 * pi) * 0.1,
            0.7 + cos(_shimmerController.value * 2 * pi) * 0.1,
            1.0,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 3 + sin(_backgroundController.value * pi) * 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Core consciousness icon
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _pulseController.value * 0.08,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          0.6 + _pulseController.value * 0.2,
                          1.0,
                        ],
                      ).createShader(bounds);
                    },
                    child: Icon(
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: widget.size * 0.25,
                    ),
                  ),
                );
              },
            ),
          ),

          // Subtle shimmer overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      center: Alignment.center,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: [
                        0.0,
                        0.1 + _shimmerController.value * 0.8,
                        1.0,
                      ],
                      transform: GradientRotation(_shimmerController.value * pi),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
