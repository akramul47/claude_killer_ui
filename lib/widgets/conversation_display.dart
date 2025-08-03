import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shimmer_text.dart';
import 'smooth_streaming_text.dart';
import '../models/chat_message.dart';

class ConversationDisplay extends StatefulWidget {
  final bool isListening;
  final AnimationController glowAnimation;
  final bool showStatusText;

  const ConversationDisplay({
    super.key,
    required this.isListening,
    required this.glowAnimation,
    this.showStatusText = true,
  });

  @override
  State<ConversationDisplay> createState() => _ConversationDisplayState();
}

class _ConversationDisplayState extends State<ConversationDisplay> {
  final ScrollController _scrollController = ScrollController();
  
  // Sample conversation for demo
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: "Hey, can you explain Crime and Punishment?",
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      id: '2',
      text: "It's about moral redemption through suffering",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      id: '3',
      text: "Tell me about Raskolnikov",
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      id: '4',
      text: "He's a tortured intellectual who commits murder",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ChatMessage(
      id: '5',
      text: "What about Sonya?",
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    ChatMessage(
      id: '6',
      text: "She represents faith and unconditional love",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When status text is hidden, show just the conversation
    if (!widget.showStatusText) {
      return SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            // Chat conversation list with transparent background
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                controller: _scrollController,
                reverse: false,
                itemCount: _messages.length,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildChatBubble(message),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    
    // Original layout when status text is shown
    return Flexible(
      child: Column(
        children: [
          // Status text positioned at the top - more visible
          if (widget.showStatusText)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ShimmerText(
                text: widget.isListening ? "Listening..." : "Ready and listening",
                style: GoogleFonts.inter(
                  color: const Color(0xFF89A8B2),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          
          // AI Avatar with glow effect
          AnimatedBuilder(
            animation: widget.glowAnimation,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
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
                      color: const Color(0xFF89A8B2).withOpacity(0.2 + widget.glowAnimation.value * 0.3),
                      blurRadius: 30 + widget.glowAnimation.value * 15,
                      spreadRadius: 3 + widget.glowAnimation.value * 7,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(15),
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
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Chat conversation - flexible to fill available space
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: false,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildChatBubble(message),
                        );
                      },
                    ),
                  ),
                ),
                // Gradient overlay at bottom to blend with wave
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFF1F0E8).withOpacity(0.0),
                          const Color(0xFFF1F0E8).withOpacity(0.3),
                          const Color(0xFFF1F0E8).withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Row(
      mainAxisAlignment: message.isUser 
          ? MainAxisAlignment.end 
          : MainAxisAlignment.start,
      children: [
        // Message bubble - removed avatars for cleaner look
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8, // Increased width since no avatars
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: message.isUser
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
                        const Color(0xFFE5E1DA).withOpacity(0.95),
                        const Color(0xFFF1F0E8).withOpacity(0.9),
                      ],
                    ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: message.isUser 
                    ? const Radius.circular(24) 
                    : const Radius.circular(6),
                bottomRight: message.isUser 
                    ? const Radius.circular(6) 
                    : const Radius.circular(24),
              ),
              border: message.isUser
                  ? null
                  : Border.all(
                      color: const Color(0xFFB3C8CF).withOpacity(0.3),
                      width: 1.0,
                    ),
            ),
            child: message.isUser 
                ? Text(
                    message.text,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  )
                : SmoothStreamingText(
                    text: message.text,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF4A5568),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                    wordDelay: const Duration(milliseconds: 100),
                  ),
          ),
        ),
      ],
    );
  }
}
