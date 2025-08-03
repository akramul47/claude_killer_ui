import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/animation_constants.dart';
import '../constants/app_config.dart';
import '../services/greeting_service.dart';
import '../widgets/animations/advanced_background.dart';
import '../widgets/shared/shared_premium_avatar.dart';
import '../widgets/animations/advanced_changing_text.dart';
import '../widgets/common/sophisticated_header.dart';
import '../widgets/common/recent_activity.dart';
import '../widgets/common/floating_start_button.dart';
import '../widgets/cards/premium_expertise_cards.dart';
import '../utils/page_transitions.dart';
import 'voice_assistant_screen.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _buttonController;
  late AnimationController _fadeController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Timer _textTimer;
  
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: AnimationConstants.backgroundAnimation,
      vsync: this,
    )..repeat();
    
    _buttonController = AnimationController(
      duration: AnimationConstants.buttonAnimation,
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: AnimationConstants.fadeAnimation,
      vsync: this,
    );

    _cardController = AnimationController(
      duration: AnimationConstants.cardAnimation,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: AnimationConstants.pulseAnimation,
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: AnimationConstants.shimmerAnimation,
      vsync: this,
    )..repeat();
    
    _startTextRotation();
    _fadeController.forward();
    _cardController.forward();
  }

  void _startTextRotation() {
    _textTimer = Timer.periodic(AnimationConstants.textRotation, (timer) {
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % GreetingService.promptCount;
      });
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _buttonController.dispose();
    _fadeController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _textTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Sophisticated animated background
          AdvancedBackground(backgroundController: _backgroundController),
          
          // Main content with ScrollView to prevent overflow
          SafeArea(
            child: Column(
              children: [
                // Main scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: AppConfig.defaultPadding,
                      right: AppConfig.defaultPadding,
                      top: 40.0,
                      bottom: 100.0, // Space for floating button
                    ),
                    child: Column(
                      children: [
                        // Enhanced header with stats
                        SophisticatedHeader(
                          fadeController: _fadeController,
                          pulseController: _pulseController,
                        ),
                        
                        const SizedBox(height: 110),
                        
                        // Premium AI avatar with hero animation
                        SharedPremiumAvatar(
                          size: 120.0,
                          heroTag: 'premium_avatar',
                          onTap: _navigateToChat,
                        ),
                        
                        const SizedBox(height: 70),
                        
                        // Sophisticated changing text with typewriter effect
                        AdvancedChangingText(
                          shimmerController: _shimmerController,
                          backgroundController: _backgroundController,
                          pulseController: _pulseController,
                          currentTextIndex: _currentTextIndex,
                        ),
                        
                        const SizedBox(height: 200), // Extra space to hide recent work section

                        // Recent activity preview
                        RecentActivity(),
                        
                        const SizedBox(height: 35),
                        
                        // Premium expertise cards with advanced animations
                        PremiumExpertiseCards(
                          onCardTap: _navigateToChat,
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating start chat button - always visible at bottom
          FloatingStartButton(
            buttonController: _buttonController,
            pulseController: _pulseController,
            shimmerController: _shimmerController,
            onTap: _navigateToChat,
          ),
        ],
      ),
    );
  }

  void _navigateToChat() {
    Navigator.of(context).push(
      FadeWithHeroTransition(
        page: const VoiceAssistantUI(),
        heroTag: 'premium_avatar',
      ),
    );
  }
}
