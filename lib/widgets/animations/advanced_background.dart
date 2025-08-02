import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../floating_particle.dart';

class AdvancedBackground extends StatelessWidget {
  final AnimationController backgroundController;

  const AdvancedBackground({
    super.key,
    required this.backgroundController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBackground,
                AppColors.lightBackground.withOpacity(0.9),
                AppColors.mediumBlue.withOpacity(0.05),
                AppColors.primaryBackground,
              ],
              stops: [
                0.0,
                0.3 + sin(backgroundController.value * 2 * pi) * 0.1,
                0.7 + cos(backgroundController.value * 2 * pi) * 0.1,
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Enhanced floating particles
              ...List.generate(20, (index) {
                return FloatingParticle(
                  index: index,
                  animation: backgroundController,
                );
              }),
              
              // Subtle mesh gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      sin(backgroundController.value * pi) * 0.3,
                      cos(backgroundController.value * pi * 0.7) * 0.2,
                    ),
                    radius: 1.5,
                    colors: [
                      AppColors.darkBlue.withOpacity(0.03),
                      Colors.transparent,
                      AppColors.mediumBlue.withOpacity(0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
