import 'package:flutter/material.dart';
import '../widgets/shared/shared_premium_avatar.dart';

/// Simple loading indicator using the shared premium avatar
class PremiumLoadingIndicator extends StatelessWidget {
  final double avatarSize;
  final Color? color;
  final String? uniqueId;

  const PremiumLoadingIndicator({
    super.key,
    this.avatarSize = 48.0,
    this.color,
    this.uniqueId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Use shared premium avatar for consistency
          SharedPremiumAvatar(
            size: avatarSize,
            heroTag: 'loading_avatar_${uniqueId ?? DateTime.now().millisecondsSinceEpoch}',
            showGlow: true,
          ),
          
          const SizedBox(width: 16),
          
          // Loading message
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(6),
                ),
                border: Border.all(
                  color: const Color(0xFFB3C8CF).withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: const Text(
                'Wait a sec...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A5568),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
