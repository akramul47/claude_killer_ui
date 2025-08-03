import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Enhanced loading indicator with proper avatar animation
class PremiumLoadingIndicator extends StatelessWidget {
  final double avatarSize;
  final Color? color;
  final String? uniqueId;
  final String? loadingText;

  const PremiumLoadingIndicator({
    super.key,
    this.avatarSize = 48.0,
    this.color,
    this.uniqueId,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    print('🔵 PremiumLoadingIndicator building with text: ${loadingText ?? "Thinking..."}');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Message bubble that matches the exact layout of streaming text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE5E1DA).withOpacity(0.95),
                        const Color(0xFFF1F0E8).withOpacity(0.9),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: const Color(0xFFB3C8CF).withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  child: _buildLoadingContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main loading text - matches streaming text style exactly
        Text(
          loadingText ?? 'Wait a sec...',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A5568),
            height: 1.4,
            letterSpacing: 0.2,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Animated typing indicator
        _TypewriterDots(key: ValueKey('typewriter_${uniqueId ?? 'default'}')),
      ],
    );
  }
}

/// Animated dots to simulate typing
class _TypewriterDots extends StatefulWidget {
  const _TypewriterDots({super.key});

  @override
  _TypewriterDotsState createState() => _TypewriterDotsState();
}

class _TypewriterDotsState extends State<_TypewriterDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final opacity = (sin(animationValue * pi) * 0.7 + 0.3).clamp(0.0, 1.0);
            
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF89A8B2).withOpacity(opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
