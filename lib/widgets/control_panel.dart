import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ControlPanel extends StatelessWidget {
  final bool isListening;
  final VoidCallback onToggleListening;
  final AnimationController breathingAnimation;
  final AnimationController glowAnimation;

  const ControlPanel({
    super.key,
    required this.isListening,
    required this.onToggleListening,
    required this.breathingAnimation,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Add button
        _buildControlButton(
          icon: Icons.add,
          onPressed: () => HapticFeedback.lightImpact(),
        ),
        
        const SizedBox(width: 32),
        
        // Main recording button
        AnimatedBuilder(
          animation: Listenable.merge([breathingAnimation, glowAnimation]),
          builder: (context, child) {
            final breathScale = 1.0 + (breathingAnimation.value * 0.04);
            final glowIntensity = 0.15 + glowAnimation.value * 0.25;
            
            return Transform.scale(
              scale: breathScale,
              child: GestureDetector(
                onTap: onToggleListening,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFF1F0E8).withOpacity(0.95),
                        const Color(0xFFE5E1DA).withOpacity(0.85),
                        const Color(0xFFB3C8CF).withOpacity(0.9),
                      ],
                    ),
                    boxShadow: [
                      // Main glow
                      BoxShadow(
                        color: const Color(0xFF89A8B2).withOpacity(glowIntensity),
                        blurRadius: 30 + glowAnimation.value * 20,
                        spreadRadius: 4 + glowAnimation.value * 6,
                      ),
                      // Outer shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      // Inner highlight
                      BoxShadow(
                        color: Colors.white.withOpacity(0.9),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                        spreadRadius: -2,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFB3C8CF).withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isListening ? [
                          const Color(0xFFD9A299),
                          const Color(0xFFDCC5B2),
                          const Color(0xFFF0E4D3),
                        ] : [
                          const Color(0xFFFAF7F3),
                          const Color(0xFFF0E4D3),
                          const Color(0xFFDCC5B2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isListening ? Icons.stop_rounded : Icons.keyboard_voice_rounded,
                      color: isListening ? const Color(0xFFFAF7F3) : const Color(0xFF8B5A3C),
                      size: 36,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 32),
        
        // Close button
        _buildControlButton(
          icon: Icons.close,
          onPressed: () => HapticFeedback.lightImpact(),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF1F0E8),
              Color(0xFFE5E1DA),
              Color(0xFFB3C8CF),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFB3C8CF).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFFF1F0E8).withOpacity(0.9),
              blurRadius: 8,
              offset: const Offset(0, -2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4A5568),
          size: 26,
        ),
      ),
    );
  }
}
