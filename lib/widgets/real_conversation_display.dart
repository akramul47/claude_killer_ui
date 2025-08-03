import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../models/api_model.dart';
import '../services/chat_controller.dart';
import 'ai_loading_animation.dart';
import 'streaming_text.dart';

class RealConversationDisplay extends StatefulWidget {
  final ChatController chatController;
  final ScrollController scrollController;
  final bool isListening;
  final AnimationController glowAnimation;
  final bool showStatusText;

  const RealConversationDisplay({
    super.key,
    required this.chatController,
    required this.scrollController,
    required this.isListening,
    required this.glowAnimation,
    this.showStatusText = true,
  });

  @override
  State<RealConversationDisplay> createState() => _RealConversationDisplayState();
}

class _RealConversationDisplayState extends State<RealConversationDisplay>
    with TickerProviderStateMixin {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current API Model indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: widget.chatController.currentApiModel.isFree
                ? const Color(0xFFE8F5E8)
                : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.chatController.currentApiModel.isFree
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFF9800),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.chatController.currentApiModel.isFree
                    ? Icons.check_circle
                    : Icons.star,
                color: widget.chatController.currentApiModel.isFree
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.chatController.currentApiModel.displayName} by ${widget.chatController.currentApiModel.provider}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.chatController.currentApiModel.isFree
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                  ),
                ),
              ),
              if (widget.chatController.currentApiModel.isFree)
                Text(
                  'FREE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
            ],
          ),
        ),
        
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
        
        // Status section - only show when status text is enabled
        if (widget.showStatusText) ...[
          AnimatedBuilder(
            animation: widget.glowAnimation,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
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
                      color: const Color(0xFF89A8B2).withOpacity(0.15 + widget.glowAnimation.value * 0.25),
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
        final messages = widget.chatController.messages;
        final isLoading = widget.chatController.isLoading;
        final isStreaming = widget.chatController.isStreaming;
        final error = widget.chatController.error;

        print('💬 UI: Messages count: ${messages.length}, isLoading: $isLoading, isStreaming: $isStreaming');
        for (int i = 0; i < messages.length; i++) {
          print('💬 UI: Message $i: "${messages[i].text}" (isUser: ${messages[i].isUser})');
        }

        if (messages.isEmpty && !isLoading) {
          return _buildWelcomeMessage();
        }

        return Column(
          children: [
            // Error message at the top if present
            if (error != null) _buildErrorMessage(error),
            
            // Messages list with proper keyboard handling
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: 8 + MediaQuery.of(context).viewInsets.bottom * 0.1, // Add small padding for keyboard
                  left: 0,
                  right: 0,
                ),
                itemCount: messages.length + (isLoading && !isStreaming ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= messages.length) {
                    // Loading indicator
                    return _buildLoadingMessage();
                  }
                  
                  final message = messages[index];
                  return _buildMessageBubble(message, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
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
                  blurRadius: 20,
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
          const SizedBox(height: 24),
          Text(
            "Welcome to Claude Killer!",
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "I'm here to help with anything you need.\nWhat would you like to know?",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF89A8B2),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          // AI consciousness wave animation instead of avatar
          const AILoadingAnimation(size: 32),
          const SizedBox(width: 12),
          // Typing indicator
          Container(
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
            ),
            child: Text(
              'Just a sec..',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A5568),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final timeFormatter = DateFormat('HH:mm');
    final isStreaming = message.status == MessageStatus.streaming;
    
    return Padding(
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
                          : Text(
                              message.text,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF4A5568),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: 0.2,
                              ),
                            ),
                      if (isStreaming) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: message.isUser 
                                ? Colors.white.withOpacity(0.7)
                                : const Color(0xFF89A8B2),
                          ),
                        ),
                      ],
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
