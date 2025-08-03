import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/floating_particle.dart';
import '../widgets/real_conversation_display.dart';
import '../widgets/audio_visualization.dart';
import '../widgets/control_panel.dart';
import '../widgets/multi_model_api_dialog.dart';
import '../widgets/shared/shared_premium_avatar.dart';
import '../services/chat_controller.dart';
import '../constants/app_config.dart';
import 'settings_screen.dart';

class VoiceAssistantUI extends StatefulWidget {
  const VoiceAssistantUI({super.key});

  @override
  State<VoiceAssistantUI> createState() => _VoiceAssistantUIState();
}

class _VoiceAssistantUIState extends State<VoiceAssistantUI> 
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _breathingController;
  late AnimationController _fadeController;
  // late AnimationController _modelInfoFadeController; // DISABLED - banner functionality turned off
  late ChatController _chatController;
  late ScrollController _scrollController;
  
  bool _isListening = false;
  bool _isVoiceMode = false;
  // bool _showModelInfo = true; // Show model info banner initially - DISABLED
  final TextEditingController _textController = TextEditingController();
  String _conversationTitle = 'Claude Killer';

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // DISABLED - Banner functionality turned off
    // _modelInfoFadeController = AnimationController(
    //   duration: const Duration(milliseconds: 500),
    //   vsync: this,
    //   value: 1.0, // Start fully visible
    // );
    
    _scrollController = ScrollController();
    _chatController = ChatController();
    
    // Start fade in animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });

    // DISABLED - Banner fade out functionality
    // Start model info fade out after 3 seconds
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (mounted) {
    //     _modelInfoFadeController.animateTo(0.0).then((_) {
    //       if (mounted) {
    //         setState(() {
    //           _showModelInfo = false;
    //         });
    //       }
    //     });
    //   }
    // });
    
    // Add listener to update send button state
    _textController.addListener(() {
      setState(() {});
    });
    
    // Listen to chat controller changes
    _chatController.addListener(_onChatControllerChanged);
    
    // Check API key when entering chat mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AppConfig.useMockApi) {
        _showApiKeyDialog();
      }
    });
  }

  void _onChatControllerChanged() {
    if (mounted) {
      setState(() {
        // Update conversation title when messages exist
        if (_chatController.hasMessages && _conversationTitle == 'Claude Killer') {
          _updateConversationTitle();
        }
      });
      
      // Auto-scroll to bottom when new messages arrive or during streaming
      if (_chatController.hasMessages) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }
  }

  void _updateConversationTitle() {
    if (_chatController.messages.isNotEmpty) {
      final firstUserMessage = _chatController.messages
          .where((msg) => msg.isUser)
          .first
          .text;
      
      // Generate a short title from the first message
      List<String> words = firstUserMessage.split(' ');
      if (words.length <= 3) {
        _conversationTitle = firstUserMessage;
      } else {
        _conversationTitle = '${words.take(3).join(' ')}...';
      }
      
      // Capitalize first letter
      if (_conversationTitle.isNotEmpty) {
        _conversationTitle = _conversationTitle[0].toUpperCase() + 
                           _conversationTitle.substring(1);
      }
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _breathingController.dispose();
    _fadeController.dispose();
    // _modelInfoFadeController.dispose(); // DISABLED - banner functionality turned off
    _scrollController.dispose();
    _textController.dispose();
    _chatController.removeListener(_onChatControllerChanged);
    _chatController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
    
    HapticFeedback.lightImpact();
  }

  void _toggleVoiceMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
      if (!_isVoiceMode) {
        _isListening = false; // Stop listening when exiting voice mode
      }
    });
    
    HapticFeedback.lightImpact();
  }

  void _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    // Clear the input field immediately for better UX
    _textController.clear();
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Provide haptic feedback
    HapticFeedback.lightImpact();
    
    // Scroll to bottom to show the new message
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
    
    // Send message with streaming for better UX
    try {
      await _chatController.sendMessage(message, useStreaming: true);
      // Scroll to bottom after message is sent
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollToBottom();
      });
    } catch (e) {
      // Handle any errors gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send message. Please try again.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showApiKeyDialog() async {
    final hasKey = await _chatController.hasApiKey();
    if (!hasKey) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MultiModelApiDialog(
          onApiKeysUpdated: () {
            setState(() {}); // Refresh UI
          },
        ),
      );
    }
  }

  void _showSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  Widget _buildTextInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0E8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF89A8B2).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Mic button to toggle voice mode
              GestureDetector(
                onTap: _toggleVoiceMode,
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF89A8B2),
                        Color(0xFFB3C8CF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF89A8B2).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Text input field with proper constraints
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 44,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE5E1DA).withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF89A8B2).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF89A8B2).withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2C3E50),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onTap: () {
                      // Ensure latest messages are visible when keyboard appears
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _scrollToBottom();
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Send button with better interaction
              GestureDetector(
                onTap: _textController.text.trim().isNotEmpty ? _sendMessage : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _textController.text.trim().isNotEmpty 
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF89A8B2),
                            Color(0xFFB3C8CF),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF89A8B2).withOpacity(0.4),
                            const Color(0xFFB3C8CF).withOpacity(0.4),
                          ],
                        ),
                    boxShadow: _textController.text.trim().isNotEmpty 
                      ? [
                          BoxShadow(
                            color: const Color(0xFF89A8B2).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: _textController.text.trim().isNotEmpty 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (mounted && _scrollController.hasClients) {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        // Silently handle scroll controller conflicts
        print('Scroll controller conflict: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F0E8),
      resizeToAvoidBottomInset: true, // This is crucial for keyboard handling
      body: Column(
        children: [
          // Background and particles container
          Expanded(
            child: Stack(
              children: [
                // Cool gradient background with new color palette
                AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            sin(_backgroundController.value * 2 * pi) * 0.2,
                            cos(_backgroundController.value * 2 * pi) * 0.15,
                          ),
                          radius: 1.8,
                          colors: [
                            const Color(0xFF89A8B2).withOpacity(0.3),
                            const Color(0xFFB3C8CF).withOpacity(0.2),
                            const Color(0xFFE5E1DA).withOpacity(0.15),
                            const Color(0xFFF1F0E8),
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                    );
                  },
                ),

                // Floating particles
                ...List.generate(8, (index) => 
                  FloatingParticle(
                    index: index,
                    animation: _backgroundController,
                  ),
                ),

                // Main content area
                SafeArea(
                  child: Column(
                    children: [
                      // Header with back button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF89A8B2).withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Color(0xFF89A8B2),
                                  size: 20,
                                ),
                              ),
                            ),

                            const Spacer(),
                            Text(
                              _conversationTitle,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF89A8B2),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Model switcher button
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => MultiModelApiDialog(
                                        onApiKeysUpdated: () {
                                          setState(() {}); // Refresh UI
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.9),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF89A8B2).withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy,
                                      color: Color(0xFF89A8B2),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _showSettings,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.9),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF89A8B2).withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.settings,
                                      color: Color(0xFF89A8B2),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Part 1: Premium Avatar and welcome text - Only show in text mode when no messages
                      if (!_isVoiceMode && !_chatController.hasMessages) 
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                              final isKeyboardVisible = keyboardHeight > 0;
                              final availableHeight = constraints.maxHeight;
                              
                              // More defensive layout calculation with keyboard handling
                              final textHeight = 50.0; // Reserve space for welcome text
                              final minAvatarSize = 50.0;
                              final maxAvatarSize = 120.0;
                              
                              // When keyboard is visible, use much smaller spacing and avatar
                              if (isKeyboardVisible || availableHeight < 300) {
                                final compactAvatarSize = 60.0;
                                final compactSpacing = 16.0;
                                final compactTextHeight = 40.0;
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: FadeTransition(
                                    opacity: _fadeController,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Compact top spacing
                                        SizedBox(height: compactSpacing),
                                        
                                        // Compact Premium Avatar
                                        SharedPremiumAvatar(
                                          size: compactAvatarSize,
                                          heroTag: 'premium_avatar',
                                          showGlow: true,
                                        ),
                                        
                                        // Compact middle spacing
                                        SizedBox(height: compactSpacing),
                                        
                                        // Compact welcome text
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: 280,
                                            maxHeight: compactTextHeight,
                                          ),
                                          child: AnimatedBuilder(
                                            animation: _fadeController,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale: 0.95 + (_fadeController.value * 0.05),
                                                child: Text(
                                                  "How can I help you today?",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF4A5568),
                                                    height: 1.2,
                                                    letterSpacing: 0.2,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        
                                        // Compact bottom spacing
                                        SizedBox(height: compactSpacing),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              
                              // Normal layout when keyboard is hidden
                              final availableForAvatar = availableHeight - textHeight - 120; // More padding for spacing
                              final avatarSize = availableForAvatar.clamp(minAvatarSize, maxAvatarSize);
                              
                              // Calculate spacing proportionally
                              final totalSpacingAvailable = availableHeight - avatarSize - textHeight;
                              final topSpacing = (totalSpacingAvailable * 0.4).clamp(20.0, 80.0);
                              final middleSpacing = (totalSpacingAvailable * 0.35).clamp(24.0, 60.0);
                              final bottomSpacing = (totalSpacingAvailable * 0.25).clamp(20.0, 60.0);
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: FadeTransition(
                                  opacity: _fadeController,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Top spacing
                                      SizedBox(height: topSpacing),
                                      
                                      // Premium Avatar with optimal sizing
                                      SharedPremiumAvatar(
                                        size: avatarSize,
                                        heroTag: 'premium_avatar',
                                        showGlow: true,
                                      ),
                                      
                                      // Middle spacing - increased for better visual separation
                                      SizedBox(height: middleSpacing),
                                      
                                      // Welcome text - properly sized and spaced
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 320,
                                          maxHeight: textHeight,
                                        ),
                                        child: AnimatedBuilder(
                                          animation: _fadeController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: 0.95 + (_fadeController.value * 0.05),
                                              child: Text(
                                                "How can I help you today?",
                                                style: GoogleFonts.inter(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF4A5568),
                                                  height: 1.3,
                                                  letterSpacing: 0.3,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      
                                      // Bottom spacing
                                      SizedBox(height: bottomSpacing),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Part 1 Alternative: Status text and AI logo section - Only show in voice mode
                      if (_isVoiceMode) SizedBox(
                        height: 130, // Reduced height to accommodate header
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Status text
                            if (_isListening)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  "Listening...",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF89A8B2),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  "Ready and listening",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF89A8B2),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            
                            // Smaller avatar for voice mode
                            SharedPremiumAvatar(
                              size: 80.0,
                              heroTag: 'premium_avatar_voice',
                              showGlow: _isListening,
                            ),
                          ],
                        ),
                      ),
                      
                      // Part 2: Conversation area - always present to maintain scroll controller
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: RealConversationDisplay(
                            chatController: _chatController,
                            scrollController: _scrollController,
                            isListening: _isListening,
                            showStatusText: false,
                          ),
                        ),
                      ),
                      
                      // Part 3: Voice controls for voice mode
                      if (_isVoiceMode) 
                        SizedBox(
                          height: 200, // Fixed height for voice controls
                          child: Container(
                            color: Colors.transparent,
                            child: Stack(
                              children: [
                                // Wave visualization as background
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: -50,
                                  bottom: 0,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: AudioVisualization(
                                      isActive: true,
                                      backgroundController: _backgroundController,
                                    ),
                                  ),
                                ),
                                
                                // Exit voice mode button - top right
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: GestureDetector(
                                    onTap: _toggleVoiceMode,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.9),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.keyboard,
                                        color: Color(0xFF89A8B2),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Control panel centered in this section
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: ControlPanel(
                                      isListening: _isListening,
                                      onToggleListening: _toggleListening,
                                      breathingAnimation: _breathingController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Input section outside of the main stack for proper keyboard behavior
          if (!_isVoiceMode) 
            FadeTransition(
              opacity: _fadeController,
              child: _buildTextInputSection(),
            ),
        ],
      ),
    );
  }
}
