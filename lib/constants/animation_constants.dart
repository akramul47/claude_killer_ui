import 'package:flutter/material.dart';

class AnimationConstants {
  // Duration constants
  static const Duration backgroundAnimation = Duration(seconds: 18);
  static const Duration buttonAnimation = Duration(milliseconds: 4500);
  static const Duration fadeAnimation = Duration(milliseconds: 1200);
  static const Duration cardAnimation = Duration(milliseconds: 1800);
  static const Duration pulseAnimation = Duration(milliseconds: 3000);
  static const Duration shimmerAnimation = Duration(milliseconds: 5000);
  static const Duration textRotation = Duration(seconds: 6);
  static const Duration textTransition = Duration(milliseconds: 1000);
  static const Duration apiDelay = Duration(milliseconds: 1500);
  
  // Curve constants
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve slideInCurve = Curves.easeInOutCubic;
  
  // Animation values
  static const double pulseScaleMin = 0.95;
  static const double pulseScaleMax = 1.05;
  static const double shimmerOpacityMin = 0.3;
  static const double shimmerOpacityMax = 0.8;
  static const double waveOpacityMin = 0.2;
  static const double waveOpacityMax = 0.8;
}

class AppTransitions {
  static PageRouteBuilder slideUpTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: AnimationConstants.slideInCurve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: AnimationConstants.fadeAnimation,
    );
  }
}
