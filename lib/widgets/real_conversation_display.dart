import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../models/api_model.dart';
import '../services/chat_controller.dart';
import 'streaming_text.dart';
import 'premium_loading_indicator.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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

        print('💬 UI: Messages count: ${messages.length}, isLoading: $isLoading, isStreaming: $isStreaming');
        for (int i = 0; i < messages.length; i++) {
          print('💬 UI: Message $i: "${messages[i].text}" (isUser: ${messages[i].isUser}, length: ${messages[i].text.length})');
        }

        // If no messages and not loading, show empty container
        // The main screen will handle showing the welcome avatar
        if (messages.isEmpty && !isLoading) {
          return const SizedBox.expand();
        }

        return Column(
          children: [
            // Error message at the top if present
            if (error != null) _buildErrorMessage(error),
            
            // Messages list with stable key
            Expanded(
              child: ListView.builder(
                key: const ValueKey('conversation_listview'), // Fixed stable key
                controller: widget.scrollController,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 16,
                  left: 0,
                  right: 0,
                ),
                itemCount: messages.length + (isLoading && !isStreaming ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= messages.length) {
                    // Loading indicator
                    return Container(
                      key: ValueKey('loading_$index'),
                      child: _buildLoadingMessage(),
                    );
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
    return PremiumLoadingIndicator(
      uniqueId: 'conversation_loading',
      avatarSize: 40.0,
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final timeFormatter = DateFormat('HH:mm');
    final isStreaming = message.status == MessageStatus.streaming;
    
    return Padding(
      key: ValueKey('msg_${message.id}_${index}'), // Include index for extra uniqueness
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
                              ? WordStreamingText(
                                  key: ValueKey('stream_${message.id}_${index}'), // Include index for uniqueness
                                  text: message.text,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF4A5568),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    letterSpacing: 0.2,
                                  ),
                                  wordDelay: const Duration(milliseconds: 150), // Slower for smoother fade
                                )
                              : message.text.isEmpty
                                ? (isStreaming 
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            PremiumLoadingIndicator(
                                              avatarSize: 24.0,
                                            ),
                                          ],
                                        ),
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
                                      ))
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
