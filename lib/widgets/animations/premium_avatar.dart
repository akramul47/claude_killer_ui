import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../painters/consciousness_wave_painter.dart';
import '../../constants/app_config.dart';

class PremiumAvatar extends StatelessWidget {
  final AnimationController buttonController;
  final AnimationController shimmerController;
  final AnimationController backgroundController;
  final AnimationController pulseController;

  const PremiumAvatar({
    super.key,
    required this.buttonController,
    required this.shimmerController,
    required this.backgroundController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([buttonController, shimmerController, backgroundController, pulseController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Quantum consciousness field - smaller and more subtle
            ...List.generate(6, (layerIndex) {
              final layerPhase = (backgroundController.value + layerIndex * 0.125) % 1.0;
              final layerRadius = 35 + layerIndex * 12.0;
              final layerOpacity = (sin(layerPhase * 3 * pi) * 0.3 + 0.15).abs();
              final layerScale = 0.8 + (cos(layerPhase * 2 * pi) * 0.2).abs();
              
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
                          AppColors.mediumBlue.withOpacity(layerOpacity * 0.15),
                          AppColors.darkBlue.withOpacity(layerOpacity * 0.1),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Neural synapses firing around the avatar
            ...List.generate(8, (synapseIndex) {
              final synapsePhase = (shimmerController.value + synapseIndex * 0.125) % 1.0;
              final angle = (synapseIndex / 8) * 2 * pi;
              final radius = 40 + sin(synapsePhase * 2 * pi) * 10;
              final synapseX = cos(angle + synapsePhase * 0.5 * pi) * radius;
              final synapseY = sin(angle + synapsePhase * 0.5 * pi) * radius;
              final synapseOpacity = (sin(synapsePhase * 2 * pi) * 0.2 + 0.3).abs();
              
              return Transform.translate(
                offset: Offset(synapseX, synapseY),
                child: Transform.rotate(
                  angle: synapsePhase * 2 * pi,
                  child: Opacity(
                    opacity: synapseOpacity,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 6,
                            offset: Offset.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Sentient energy waves emanating from core
            CustomPaint(
              size: const Size(200, 200),
              painter: ConsciousnessWavePainter(
                phase: backgroundController.value,
                pulseIntensity: pulseController.value,
                shimmerPhase: shimmerController.value,
                color: AppColors.mediumBlue,
              ),
            ),

            // Main avatar container with revolutionary depth
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(sin(backgroundController.value * 2 * pi) * 0.04)
                ..rotateY(cos(backgroundController.value * 1.8 * pi) * 0.03)
                ..scale(1.0 + sin(pulseController.value * 2 * pi) * 0.015),
              child: Container(
                width: AppConfig.avatarSize,
                height: AppConfig.avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.darkBlue.withOpacity(0.6 + buttonController.value * 0.3),
                      AppColors.mediumBlue.withOpacity(0.4 + buttonController.value * 0.2),
                      AppColors.lightBackground.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: [
                      0.0,
                      0.3 + shimmerController.value * 0.2,
                      0.7 + backgroundController.value * 0.2,
                      1.0,
                    ],
                  ),
                  boxShadow: [
                    // Primary consciousness glow
                    BoxShadow(
                      color: AppColors.darkBlue.withOpacity(0.4 + buttonController.value * 0.4),
                      blurRadius: 60 + buttonController.value * 40,
                      spreadRadius: 12 + buttonController.value * 18,
                      offset: Offset(0, sin(pulseController.value * 2 * pi) * 5),
                    ),
                    // Secondary energy field
                    BoxShadow(
                      color: AppColors.mediumBlue.withOpacity(0.3 + pulseController.value * 0.3),
                      blurRadius: 40 + pulseController.value * 20,
                      spreadRadius: 8 + pulseController.value * 12,
                      offset: Offset(cos(backgroundController.value * pi) * 3, 0),
                    ),
                    // Quantum fluctuation layer
                    BoxShadow(
                      color: AppColors.lightBackground.withOpacity(0.2 + shimmerController.value * 0.2),
                      blurRadius: 80 + shimmerController.value * 30,
                      spreadRadius: 20,
                      offset: Offset.zero,
                    ),
                  ],
                ),
                child: _buildAvatarContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarContent() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(
            -1.0 + 2.0 * shimmerController.value,
            -1.0 + sin(backgroundController.value * 3 * pi) * 0.5,
          ),
          end: Alignment(
            1.0 + 2.0 * shimmerController.value,
            1.0 + cos(backgroundController.value * 2 * pi) * 0.5,
          ),
          colors: [
            AppColors.darkBlue,
            AppColors.mediumBlue.withOpacity(0.9 + pulseController.value * 0.1),
            AppColors.lightBackground.withOpacity(0.8 + shimmerController.value * 0.2),
            AppColors.darkBlue,
          ],
          stops: [
            0.0,
            0.3 + sin(shimmerController.value * 3 * pi) * 0.2,
            0.7 + cos(shimmerController.value * 2 * pi) * 0.2,
            1.0,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: Offset(0, 10 + sin(backgroundController.value * pi) * 2),
          ),
          BoxShadow(
            color: AppColors.mediumBlue.withOpacity(0.3 + pulseController.value * 0.2),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Consciousness emanation from center
          Center(
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + pulseController.value * 0.15,
                  child: Transform.rotate(
                    angle: backgroundController.value * 2 * pi,
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
                            0.5 + pulseController.value * 0.3,
                            1.0,
                          ],
                        ).createShader(bounds);
                      },
                      child: const Icon(
                        Icons.psychology_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Multi-dimensional shimmer layers
          Positioned.fill(
            child: AnimatedBuilder(
              animation: shimmerController,
              builder: (context, child) {
                return Container(
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
                        0.15 + shimmerController.value * 0.6,
                        0.35 + shimmerController.value * 0.6,
                        0.65 + shimmerController.value * 0.6,
                        1.0,
                      ],
                      transform: GradientRotation(shimmerController.value * 1.5 * pi),
                    ),
                  ),
                );
              },
            ),
          ),

          // Neural activity indicators
          ...List.generate(6, (index) {
            final activityPhase = (pulseController.value + index * 0.167) % 1.0;
            final angle = (index / 6) * 2 * pi;
            final radius = 25;
            final x = cos(angle) * radius;
            final y = sin(angle) * radius;
            
            return Positioned(
              left: 23 + x - 2,
              top: 23 + y - 2,
              child: Opacity(
                opacity: (sin(activityPhase * 2 * pi) * 0.3 + 0.2).abs(),
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
