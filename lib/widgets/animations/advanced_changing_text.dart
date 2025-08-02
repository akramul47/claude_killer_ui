import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../painters/neural_connection_painter.dart';
import '../../services/greeting_service.dart';
import '../../constants/animation_constants.dart';

class AdvancedChangingText extends StatelessWidget {
  final AnimationController shimmerController;
  final AnimationController backgroundController;
  final AnimationController pulseController;
  final int currentTextIndex;

  const AdvancedChangingText({
    super.key,
    required this.shimmerController,
    required this.backgroundController,
    required this.pulseController,
    required this.currentTextIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: Listenable.merge([shimmerController, backgroundController, pulseController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Minimal neural network connections
              ...List.generate(2, (index) {
                final connectionPhase = (shimmerController.value + index * 0.5) % 1.0;
                final startX = 80.0 + index * 120;
                final endX = startX + 40 + sin(connectionPhase * 2 * pi) * 10;
                final connectionOpacity = (sin(connectionPhase * pi) * 0.15 + 0.05).abs();
                
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 100),
                  painter: NeuralConnectionPainter(
                    startX: startX,
                    startY: 40 + cos(connectionPhase * pi) * 8,
                    endX: endX,
                    endY: 60 + sin(connectionPhase * pi) * 8,
                    opacity: connectionOpacity,
                    color: AppColors.mediumBlue,
                    phase: connectionPhase,
                  ),
                );
              }),
              
              // Flawless text transition with scale and rotation
              AnimatedSwitcher(
                duration: AnimationConstants.textTransition,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: Transform.scale(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                      ).value,
                      child: Transform.rotate(
                        angle: Tween<double>(begin: 0.05, end: 0.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOut),
                        ).value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<int>(currentTextIndex),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Smooth typewriter effect with bounce
                      TweenAnimationBuilder<int>(
                        duration: const Duration(milliseconds: 1800),
                        tween: IntTween(
                          begin: 0,
                          end: GreetingService.getSophisticatedPrompt(currentTextIndex).length,
                        ),
                        curve: Curves.easeOutQuart,
                        builder: (context, charCount, child) {
                          final promptText = GreetingService.getSophisticatedPrompt(currentTextIndex);
                          final displayText = promptText.substring(0, charCount.clamp(0, promptText.length));
                          
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            tween: Tween<double>(begin: 0.95, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Text(
                                  displayText,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    height: 1.25,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Reduced consciousness particles
              ...List.generate(6, (index) {
                final particlePhase = (shimmerController.value + index * 0.16) % 1.0;
                final particleLife = (sin(particlePhase * pi) + 1) * 0.5;
                final xPos = 60 + (index * 40.0) + sin(particlePhase * 2 * pi) * 15;
                final yPos = 20 + particleLife * 60 + cos(particlePhase * pi) * 10;
                
                return Positioned(
                  left: xPos,
                  top: yPos,
                  child: Opacity(
                    opacity: (1 - particleLife) * 0.3,
                    child: Container(
                      width: 1.5 + particleLife * 2,
                      height: 1.5 + particleLife * 2,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.mediumBlue.withOpacity(0.5),
                            AppColors.mediumBlue.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
