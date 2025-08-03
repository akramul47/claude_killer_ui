import 'package:flutter/material.dart';

/// Custom page transition that fades in the new page while keeping
/// the hero avatar smoothly transitioning in place
class FadeWithHeroTransition extends PageRouteBuilder {
  final Widget page;
  final String heroTag;

  FadeWithHeroTransition({
    required this.page,
    this.heroTag = 'premium_avatar',
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 800),
    reverseTransitionDuration: const Duration(milliseconds: 600),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Create a fade transition for the entire page
      const begin = 0.0;
      const end = 1.0;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end);
      var curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );

      return FadeTransition(
        opacity: tween.animate(curvedAnimation),
        child: child,
      );
    },
  );
}

/// A slide fade transition for smoother avatar transitions
class SlideFadeTransition extends PageRouteBuilder {
  final Widget page;

  SlideFadeTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.3);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var slideTween = Tween(begin: begin, end: end);
            var slideAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            var fadeTween = Tween(begin: 0.0, end: 1.0);
            var fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
            );

            return SlideTransition(
              position: slideTween.animate(slideAnimation),
              child: FadeTransition(
                opacity: fadeTween.animate(fadeAnimation),
                child: child,
              ),
            );
          },
        );
}
