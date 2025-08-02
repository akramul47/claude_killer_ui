import 'package:flutter/material.dart';
import '../constants/animation_constants.dart';

class NavigationUtils {
  static void navigateToPage(BuildContext context, Widget page, {String transition = 'slideUp'}) {
    late PageRouteBuilder route;
    
    switch (transition) {
      case 'slideUp':
        route = AppTransitions.slideUpTransition(page);
        break;
      case 'fade':
        route = AppTransitions.fadeTransition(page);
        break;
      default:
        route = AppTransitions.slideUpTransition(page);
    }
    
    Navigator.of(context).push(route);
  }

  static void navigateAndReplace(BuildContext context, Widget page, {String transition = 'fade'}) {
    late PageRouteBuilder route;
    
    switch (transition) {
      case 'slideUp':
        route = AppTransitions.slideUpTransition(page);
        break;
      case 'fade':
        route = AppTransitions.fadeTransition(page);
        break;
      default:
        route = AppTransitions.fadeTransition(page);
    }
    
    Navigator.of(context).pushReplacement(route);
  }

  static void goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
