import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/greeting_service.dart';

class SophisticatedHeader extends StatelessWidget {
  final AnimationController fadeController;
  final AnimationController pulseController;
  
  const SophisticatedHeader({
    super.key,
    required this.fadeController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeController,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time-based greeting with animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    GreetingService.getTimeBasedGreeting(),
                    key: ValueKey(GreetingService.getTimeBasedGreeting()),
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -1.2,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Dynamic subtitle with context
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    GreetingService.getContextualSubtitle(),
                    key: ValueKey(GreetingService.getContextualSubtitle()),
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGray,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Enhanced profile section
          ProfileSection(pulseController: pulseController),
        ],
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final AnimationController pulseController;
  
  const ProfileSection({
    super.key,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
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
                color: AppColors.darkBlue.withOpacity(0.3 + pulseController.value * 0.2),
                blurRadius: 16 + pulseController.value * 8,
                offset: Offset(0, 4 + pulseController.value * 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Profile icon
              const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              // Online indicator
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
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
