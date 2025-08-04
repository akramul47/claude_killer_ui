import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../models/api_model.dart';
import '../services/chat_controller.dart';
import 'shimmer_text.dart';

class RealConversationDisplay extends StatefulWidget {
  final ChatController chatController;
  final ScrollController scrollController;
  final bool isListening;
  final bool showStatusText;

  const RealConversationDisplay({
    super.key,
    required this.chatController,
    required this.scrollController,
    required this.isListening,
    this.showStatusText = true,
  });

  @override
  State<RealConversationDisplay> createState() => _RealConversationDisplayState();
}

class _RealConversationDisplayState extends State<RealConversationDisplay>
    with TickerProviderStateMixin {
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mock API status indicator (keep for backward compatibility)
        if (widget.chatController.currentApiModel == ApiModel.mock)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF9800),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFFF9800),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Mode: Using mock responses for testing',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Status section - simplified for shared avatar approach
        if (widget.showStatusText) ...[
          const SizedBox(height: 24),
        ],
        
        // Chat conversation - flexible to fill available space
        Expanded(
          child: _buildConversationArea(),
        ),
      ],
    );
  }

  Widget _buildConversationArea() {
    return ListenableBuilder(
      listenable: widget.chatController,
      builder: (context, child) {
        // Capture state once to avoid multiple notifications during build
        final messages = List.from(widget.chatController.messages);
        final isLoading = widget.chatController.isLoading;
        final isStreaming = widget.chatController.isStreaming;
        final error = widget.chatController.error;

        print('💬 UI: Messages: ${messages.length}, isLoading: $isLoading, isStreaming: $isStreaming');
        print('🔄 Should show loading? ${isLoading && !isStreaming}');

        // If no messages and not loading, show empty container
        if (messages.isEmpty && !isLoading && !isStreaming) {
          return const SizedBox.expand();
        }

        return Column(
          children: [
            // Error message at the top if present
            if (error != null) _buildErrorMessage(error),
            
            // Messages list - use Column instead of ListView to avoid conflicts
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 16,
                  left: 0,
                  right: 0,
                ),
                child: Column(
                  children: [
                    // Show all messages
                    ...messages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final message = entry.value;
                      return _buildMessageBubble(message, index);
                    }),
                    
                    // Show loading indicator when loading (with proper logic)
                    if (isLoading) ...[
                      _buildLoadingMessage(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.inter(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => widget.chatController.clearError(),
            child: Icon(
              Icons.close,
              color: Colors.red,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    print('🔄 Building loading message widget'); // Debug print
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to left like AI messages
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: const ValueKey('loading_message'),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                    minHeight: 56,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E1DA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                      bottomLeft: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: const Color(0xFFB3C8CF).withOpacity(0.3),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF89A8B2).withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Wait a sec..." text
                      Text(
                        "Wait a sec...",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A5568),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Animated typing dots
                      SizedBox(
                        height: 6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            return AnimatedBuilder(
                              animation: _dotsController,
                              builder: (context, child) {
                                final animationValue = (_dotsController.value * 3 - index).abs();
                                final opacity = (1 - (animationValue % 1)).clamp(0.4, 1.0);
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF89A8B2).withOpacity(opacity),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final timeFormatter = DateFormat('HH:mm');
    
    return Container(
      key: ValueKey('message_${message.id}'), // Use only message ID for stability
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Message bubble - removed avatars for cleaner look
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85, // Increased since no avatars
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      message.isUser 
                          ? Text(
                              message.text,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: 0.2,
                              ),
                            )
                          : message.text.isNotEmpty
                              ? ShimmerText(
                                  key: ValueKey('shimmer_${message.id}'), // Stable key using message ID
                                  text: message.text,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF4A5568),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    letterSpacing: 0.2,
                                  ),
                                  shimmerDuration: const Duration(milliseconds: 400), // Quick shimmer
                                )
                              : Text(
                                  'No response received',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF4A5568).withOpacity(0.6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    letterSpacing: 0.2,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                    ],
                  ),
                ),
                
                // Timestamp and status
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeFormatter.format(message.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF89A8B2).withOpacity(0.6),
                        ),
                      ),
                      if (message.isUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _getStatusIcon(message.status),
                          size: 12,
                          color: _getStatusColor(message.status),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
      case MessageStatus.streaming:
        return Icons.more_horiz;
    }
  }

  Color _getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Color(0xFF89A8B2).withOpacity(0.5);
      case MessageStatus.sent:
        return const Color(0xFF89A8B2);
      case MessageStatus.delivered:
        return Colors.green;
      case MessageStatus.failed:
        return Colors.red;
      case MessageStatus.streaming:
        return const Color(0xFF89A8B2);
    }
  }
}
