import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/homepage_screen.dart';

void main() => runApp(const ClaudeKillerApp());

class ClaudeKillerApp extends StatelessWidget {
  const ClaudeKillerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomepageScreen(),
    );
  }
}
