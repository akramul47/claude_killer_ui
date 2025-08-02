import 'package:flutter/material.dart';
import '../constants/animation_constants.dart';

class NavigationUtils {
  static Future<T?> navigateToPage<T>(
    BuildContext context,
    Widget page, {
    PageRouteBuilder<T> Function(Widget)? transition,
  }) {
    if (transition != null) {
      return Navigator.of(context).push<T>(transition(page));
    }
    
    return Navigator.of(context).push<T>(
      AppTransitions.slideUpTransition(page) as Route<T>,
    );
  }

  static void navigateAndReplace<T>(
    BuildContext context,
    Widget page, {
    PageRouteBuilder<T> Function(Widget)? transition,
  }) {
    if (transition != null) {
      Navigator.of(context).pushReplacement<T, void>(transition(page));
    } else {
      Navigator.of(context).pushReplacement<T, void>(
        AppTransitions.fadeTransition(page) as Route<T>,
      );
    }
  }

  static void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}
