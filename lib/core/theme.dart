import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Application theme constants
class AppColors {
  // New modern color palette
  static const Color primaryBackground = Color(0xFFF1F0E8);
  static const Color lightBackground = Color(0xFFE5E1DA);
  static const Color mediumBlue = Color(0xFFB3C8CF);
  static const Color darkBlue = Color(0xFF89A8B2);
  
  // Legacy colors (kept for gradual migration)
  static const Color coral = Color(0xFFD9A299);
  static const Color warmBeige = Color(0xFFDCC5B2);
  static const Color lightCream = Color(0xFFF0E4D3);
  static const Color softPink = Color(0xFFE8B4A8);
  static const Color warmBrown = Color(0xFFCFA68A);
  static const Color creamyBeige = Color(0xFFE6D2C3);
  static const Color textBrown = Color(0xFF8B5A3C);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textDark = Color(0xFF4A5568);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    textTheme: GoogleFonts.interTextTheme(),
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.primaryBackground,
  );
}

class AppSizes {
  // Avatar
  static const double avatarSize = 120.0;
  static const double avatarIconSize = 40.0;
  
  // Control buttons
  static const double mainButtonSize = 84.0;
  static const double controlButtonSize = 64.0;
  static const double controlButtonIconSize = 26.0;
  static const double mainButtonIconSize = 36.0;
  
  // Wave visualization
  static const double waveHeight = 400.0;
  static const double controlPanelBottomOffset = 40.0;
  
  // Spacing
  static const double topPadding = 60.0;
  static const double statusTextSpacing = 80.0;
  static const double messageSpacing = 8.0;
  static const double sectionSpacing = 20.0;
  
  // Text
  static const double statusTextSize = 16.0;
  static const double messageTextSize = 15.0;
  
  // Particles
  static const int particleCount = 8;
  static const double minParticleSize = 1.5;
  static const double maxParticleSize = 4.0;
}
