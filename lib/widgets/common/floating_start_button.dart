import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../constants/app_config.dart';

class FloatingStartButton extends StatelessWidget {
  final AnimationController buttonController;
  final AnimationController pulseController;
  final AnimationController shimmerController;
  final VoidCallback onTap;

  const FloatingStartButton({
    super.key,
    required this.buttonController,
    required this.pulseController,
    required this.shimmerController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppConfig.defaultPadding,
      right: AppConfig.defaultPadding,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: AnimatedBuilder(
        animation: Listenable.merge([buttonController, pulseController]),
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onTap();
            },
            child: Container(
              width: double.infinity,
              height: AppConfig.floatingButtonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkBlue,
                    AppColors.mediumBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBlue.withOpacity(0.4 + buttonController.value * 0.3),
                    blurRadius: 25 + buttonController.value * 15,
                    offset: Offset(0, 10 + buttonController.value * 5),
                  ),
                  BoxShadow(
                    color: AppColors.mediumBlue.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Button content
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Start Chat",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedBuilder(
                          animation: pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 8,
                              height: 8,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Premium angled shimmer effect
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: shimmerController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                            gradient: LinearGradient(
                              transform: GradientRotation(0.5),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                              stops: [
                                0.0,
                                shimmerController.value,
                                1.0,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
