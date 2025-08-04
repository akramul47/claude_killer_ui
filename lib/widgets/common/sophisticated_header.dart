import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../services/greeting_service.dart';
import '../../screens/settings_screen.dart';

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
    return Container(
      height: 180,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Clean glassmorphic backdrop
            AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                final pulseValue = pulseController.value;
                
                return Container(
                  decoration: BoxDecoration(
                    // Subtle gradient with accent color for better readability
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E3A8A).withOpacity(0.12 + pulseValue * 0.02),
                        const Color(0xFF3B82F6).withOpacity(0.08 + pulseValue * 0.01),
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.08),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                    // Professional glass border with accent tint
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.15 + pulseValue * 0.02),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    // Subtle backdrop blur effect
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 1,
                        offset: const Offset(0, -1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Subtle mesh pattern for professional texture
                      Positioned.fill(
                        child: CustomPaint(
                          painter: EnterprisePatternPainter(
                            animation: pulseController,
                            primaryColor: const Color(0xFF3B82F6).withOpacity(0.04),
                            secondaryColor: Colors.white.withOpacity(0.02),
                          ),
                        ),
                      ),
                      
                      // Gentle light reflection with accent tint
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.center,
                              colors: [
                                const Color(0xFF60A5FA).withOpacity(0.08 + pulseValue * 0.02),
                                Colors.white.withOpacity(0.05 + pulseValue * 0.01),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Content container without interfering backgrounds
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(left: 6, right: 6, top: 12, bottom: 6),
                child: AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    final pulseValue = pulseController.value;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: FadeTransition(
                        opacity: fadeController,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text content with enhanced layout
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4, right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Enhanced greeting with micro-interactions
                                    AnimatedBuilder(
                                      animation: pulseController,
                                      builder: (context, child) {
                                        return AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 800),
                                          switchInCurve: Curves.easeOutCubic,
                                          switchOutCurve: Curves.easeInCubic,
                                          child: Transform.translate(
                                            offset: Offset(0, -pulseValue * 0.5),
                                            child: Text(
                                              GreetingService.getTimeBasedGreeting(),
                                              key: ValueKey(GreetingService.getTimeBasedGreeting()),
                                              style: GoogleFonts.inter(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.black54,
                                                letterSpacing: -1.2,
                                                height: 1.3,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.white.withOpacity(0.8),
                                                    offset: const Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                  Shadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    offset: const Offset(0, -1),
                                                    blurRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Enhanced subtitle with professional styling
                                    Text(
                                      'Ready to assist with your tasks',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                        letterSpacing: 0.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.white.withOpacity(0.6),
                                            offset: const Offset(0, 0.5),
                                            blurRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Ultra-premium profile section
                            UltraPremiumProfileSection(
                              pulseController: pulseController,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UltraPremiumProfileSection extends StatelessWidget {
  final AnimationController pulseController;
  
  const UltraPremiumProfileSection({
    super.key,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulseValue = pulseController.value;
        final breatheScale = 1.0 + (pulseValue * 0.03);
        
        return Container(
          width: 76,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Ambient background aura
              Positioned(
                top: 16,
                child: Transform.scale(
                  scale: breatheScale,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.15 + pulseValue * 0.03),
                          Colors.black.withOpacity(0.08 + pulseValue * 0.02),
                          Colors.black.withOpacity(0.04 + pulseValue * 0.01),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Floating settings button with advanced styling
              Positioned(
                top: 0,
                right: 2,
                child: Transform.scale(
                  scale: 1.0 + pulseValue * 0.02,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                              const SettingsScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            const Color(0xFFFBFBFB),
                            const Color(0xFFF6F7F8),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        boxShadow: [
                          // Primary elevation shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15 + pulseValue * 0.02),
                            blurRadius: 12 + pulseValue * 3,
                            offset: Offset(0, 3 + pulseValue),
                            spreadRadius: 0,
                          ),
                          // Secondary ambient shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                            spreadRadius: -4,
                          ),
                          // Inner light reflection
                          BoxShadow(
                            color: Colors.white.withOpacity(0.9),
                            blurRadius: 1,
                            offset: const Offset(0, -1),
                            spreadRadius: -1,
                          ),
                          // Subtle outer glow
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                            spreadRadius: -2,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFE1E5E9).withOpacity(0.8),
                          width: 0.6,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: Colors.black54,
                          size: 17,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(0, -0.5),
                              blurRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Main profile avatar with enterprise-grade styling
              Positioned(
                bottom: -3,
                child: Transform.scale(
                  scale: breatheScale,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4169E1), // royal blue
                          const Color(0xFF6A89CC), // lighter royal blue
                          const Color(0xFF4169E1).withOpacity(0.85),
                          const Color(0xFF6A89CC).withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                      boxShadow: [
                        // Primary depth shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25 + pulseValue * 0.05),
                          blurRadius: 20 + pulseValue * 6,
                          offset: Offset(0, 6 + pulseValue * 2),
                          spreadRadius: 0,
                        ),
                        // Secondary ambient shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                          spreadRadius: -2,
                        ),
                        // Tertiary subtle shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                          spreadRadius: -8,
                        ),
                        // Inner highlight
                        BoxShadow(
                          color: Colors.white.withOpacity(0.35),
                          blurRadius: 2,
                          offset: const Offset(0, -1.5),
                          spreadRadius: -3,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.8,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.05),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Profile icon with micro-animations
                          Center(
                            child: Transform.scale(
                              scale: 1.0 + pulseValue * 0.06,
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 28,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1.5),
                                    blurRadius: 3,
                                  ),
                                  Shadow(
                                    color: Colors.white.withOpacity(0.3),
                                    offset: const Offset(0, -0.5),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Ultra-premium status indicator
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Transform.scale(
                              scale: 1.0 + pulseValue * 0.04,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFBBF7D0), // light green
                                      Color(0xFF22C55E), // vibrant green
                                      Color(0xFFFDE047), // yellow accent
                                    ],
                                    stops: [0.0, 0.6, 1.0],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22C55E).withOpacity(0.5),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      blurRadius: 1,
                                      offset: const Offset(0, -0.5),
                                      spreadRadius: -1,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

// Enterprise-grade pattern painter for professional backdrop effects
class EnterprisePatternPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  EnterprisePatternPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final animationValue = animation.value;
    
    // Professional mesh grid pattern
    final gridSpacing = 40.0;
    final gridOpacity = 0.02 + (animationValue * 0.01);
    
    paint.color = primaryColor.withOpacity(gridOpacity);
    
    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSpacing) {
      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x, size.height);
      canvas.drawPath(path, paint);
    }
    
    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSpacing) {
      final path = Path();
      path.moveTo(0, y);
      path.lineTo(size.width, y);
      canvas.drawPath(path, paint);
    }
    
    // Enterprise geometric accent patterns
    paint.color = secondaryColor.withOpacity(0.03 + animationValue * 0.02);
    paint.strokeWidth = 1.0;
    
    // Subtle hexagonal patterns
    final hexSize = 60.0;
    final hexOpacity = 0.015 + (animationValue * 0.01);
    
    paint.color = primaryColor.withOpacity(hexOpacity);
    
    for (double x = hexSize; x < size.width; x += hexSize * 1.5) {
      for (double y = hexSize; y < size.height; y += hexSize * 1.3) {
        _drawHexagon(canvas, paint, x, y, hexSize * 0.3);
      }
    }
  }
  
  void _drawHexagon(Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * (pi / 180.0);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EnterprisePatternPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value;
  }
}
