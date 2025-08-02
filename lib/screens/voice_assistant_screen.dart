import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/floating_particle.dart';
import '../widgets/conversation_display.dart';
import '../widgets/audio_visualization.dart';
import '../widgets/control_panel.dart';

class VoiceAssistantUI extends StatefulWidget {
  const VoiceAssistantUI({super.key});

  @override
  State<VoiceAssistantUI> createState() => _VoiceAssistantUIState();
}

class _VoiceAssistantUIState extends State<VoiceAssistantUI> 
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _breathingController;
  late AnimationController _glowController;
  bool _isListening = false;
  bool _isVoiceMode = false;
  final TextEditingController _textController = TextEditingController();

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
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Add listener to update send button state
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _breathingController.dispose();
    _glowController.dispose();
    _textController.dispose();
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

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      // Add message sending logic here
      print('Sending message: ${_textController.text}');
      _textController.clear();
      HapticFeedback.lightImpact();
    }
  }

  Widget _buildTextInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFE5E1DA).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF89A8B2).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Mic button to toggle voice mode
            GestureDetector(
              onTap: _toggleVoiceMode,
              child: Container(
                margin: const EdgeInsets.only(left: 4),
                width: 48,
                height: 48,
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
                ),
                child: const Icon(
                  Icons.mic_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            
            // Text input field
            Expanded(
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF89A8B2).withOpacity(0.5),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2C3E50),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: 1,
                    textInputAction: TextInputAction.send,
                  ),
                ),
              ),
            ),
            
            // Send button
            GestureDetector(
              onTap: _textController.text.trim().isNotEmpty ? _sendMessage : null,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                width: 48,
                height: 48,
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
                          const Color(0xFF89A8B2).withOpacity(0.3),
                          const Color(0xFFB3C8CF).withOpacity(0.3),
                        ],
                      ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F0E8),
      body: Stack(
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

          // Main content area - removed breathing effect
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
                        "Claude Killer",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF89A8B2),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44), // Balance the back button
                    ],
                  ),
                ),
                
                // Part 1: Status text and AI logo section - Only show in voice mode
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
                      
                      // AI Avatar
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF89A8B2).withOpacity(0.3),
                                  const Color(0xFFB3C8CF).withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF89A8B2).withOpacity(0.2 + _glowController.value * 0.3),
                                  blurRadius: 25 + _glowController.value * 10,
                                  spreadRadius: 2 + _glowController.value * 5,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF89A8B2),
                                    Color(0xFFB3C8CF),
                                    Color(0xFFE5E1DA),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.psychology_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Part 2: Conversation area - takes remaining space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConversationDisplay(
                      isListening: _isListening,
                      glowAnimation: _glowController,
                      showStatusText: false,
                    ),
                  ),
                ),
                
                // Part 3: Input section - Text input or voice controls
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
                                glowAnimation: _glowController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Text input section - fixed height, no flex
                  _buildTextInputSection(),
              ],
            ),
          ),

          // Ambient glass overlay - removed bottom shadow
          // Positioned.fill(
          //   child: BackdropFilter(
          //     filter: ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           begin: Alignment.topCenter,
          //           end: Alignment.center,
          //           colors: [
          //             const Color(0xFFF1F0E8).withOpacity(0.1),
          //             Colors.transparent,
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
