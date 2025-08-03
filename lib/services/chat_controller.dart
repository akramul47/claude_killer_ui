import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/api_model.dart';
import '../services/api_service.dart';
import '../services/api_factory.dart';
import '../services/database_service.dart';

class ChatController extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  String? _currentConversationId;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _isStreaming = false;

  ChatController() {
    _initializeDatabase();
    _initializeApiFactory();
  }

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;
  bool get isStreaming => _isStreaming;
  String? get currentConversationId => _currentConversationId;
  ApiModel get currentApiModel => ApiFactory.getCurrentModel();
  ApiService get currentApiService => ApiFactory.getCurrentService();

  Future<void> _initializeApiFactory() async {
    await ApiFactory.initialize();
  }

  Future<void> _initializeDatabase() async {
    try {
      await _databaseService.database;
    } catch (e) {
      _setError('Failed to initialize database: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setStreaming(bool streaming) {
    _isStreaming = streaming;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> startNewConversation() async {
    try {
      // Generate a title based on the first message or use a default
      final title = _messages.isNotEmpty 
          ? _generateConversationTitle(_messages.first.text)
          : 'New Conversation';
      
      _currentConversationId = await _databaseService.createConversation(title);
      
      // Update all current messages with the new conversation ID
      for (int i = 0; i < _messages.length; i++) {
        final updatedMessage = _messages[i].copyWith(
          conversationId: _currentConversationId,
        );
        _messages[i] = updatedMessage;
        await _databaseService.insertMessage(updatedMessage);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to create conversation: $e');
    }
  }

  Future<void> loadConversation(String conversationId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final conversation = await _databaseService.getConversation(conversationId);
      if (conversation != null) {
        _currentConversationId = conversationId;
        _messages.clear();
        _messages.addAll(conversation.messages);
        notifyListeners();
      } else {
        _setError('Conversation not found');
      }
    } catch (e) {
      _setError('Failed to load conversation: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage(String text, {bool useStreaming = false}) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      conversationId: _currentConversationId,
      status: MessageStatus.sent,
    );
    
    _messages.add(userMessage);
    notifyListeners();

    // Save user message to database if we have a conversation
    if (_currentConversationId != null) {
      try {
        await _databaseService.insertMessage(userMessage);
      } catch (e) {
        print('Failed to save user message: $e');
      }
    } else {
      // Create new conversation if this is the first message
      await startNewConversation();
    }

    if (useStreaming) {
      await _sendStreamMessage(text);
    } else {
      await _sendRegularMessage(text);
    }
  }

  Future<void> _sendRegularMessage(String text) async {
    _setLoading(true);
    _setError(null);

    try {
      // Build conversation history for context
      final conversationHistory = _buildConversationHistory();
      
      // Get AI response
      final response = await currentApiService.sendMessage(
        text.trim(), 
        conversationHistory: conversationHistory,
      );
      
      print('🤖 Chat Controller received response: "$response"');
      
      // Add AI message
      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        conversationId: _currentConversationId,
        status: MessageStatus.sent,
      );
      
      print('🤖 Created AI message: ${aiMessage.text}');
      _messages.add(aiMessage);
      print('🤖 Added AI message to list. Total messages: ${_messages.length}');
      notifyListeners();
      print('🤖 Notified listeners');
      
      // Save AI message to database
      if (_currentConversationId != null) {
        await _databaseService.insertMessage(aiMessage);
      }
      
    } catch (e) {
      print('❌ API Error: $e');
      
      // Check if this is a quota/billing error and switch to mock API
      if (e.toString().contains('quota') || 
          e.toString().contains('billing') || 
          e.toString().contains('insufficient_quota')) {
        
        print('🔄 Switching to Mock API due to quota error...');
        await ApiFactory.switchModel(ApiModel.mock);
        notifyListeners();
        
        // Retry with mock API
        try {
          final conversationHistory = _buildConversationHistory();
          final response = await currentApiService.sendMessage(
            text.trim(), 
            conversationHistory: conversationHistory,
          );
          
          final aiMessage = ChatMessage(
            text: "⚠️ OpenAI API quota exceeded. Switched to demo mode.\n\n$response",
            isUser: false,
            conversationId: _currentConversationId,
            status: MessageStatus.sent,
          );
          
          _messages.add(aiMessage);
          
          if (_currentConversationId != null) {
            await _databaseService.insertMessage(aiMessage);
          }
        } catch (mockError) {
          _setError('Both OpenAI and mock API failed: $mockError');
          
          // Add error message
          final errorMessage = ChatMessage(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            conversationId: _currentConversationId,
            status: MessageStatus.failed,
          );
          
          _messages.add(errorMessage);
        }
      } else {
        _setError('Failed to get response: ${e.toString()}');
        
        // Add error message
        final errorMessage = ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          conversationId: _currentConversationId,
          status: MessageStatus.failed,
        );
        
        _messages.add(errorMessage);
        
        if (_currentConversationId != null) {
          try {
            await _databaseService.insertMessage(errorMessage);
          } catch (dbError) {
            print('Failed to save error message: $dbError');
          }
        }
      }
    } finally {
      _setLoading(false);
    }
  }  Future<void> _sendStreamMessage(String text) async {
    _setStreaming(true);
    _setError(null);

    // Create placeholder AI message for streaming
    final aiMessage = ChatMessage(
      text: '',
      isUser: false,
      conversationId: _currentConversationId,
      status: MessageStatus.streaming,
    );
    
    _messages.add(aiMessage);
    notifyListeners();

    try {
      // Build conversation history for context
      final conversationHistory = _buildConversationHistory();
      
      final stream = await currentApiService.sendStreamMessage(
        text.trim(),
        conversationHistory: conversationHistory,
      );
      
      String fullResponse = '';
      
      await for (final chunk in stream) {
        fullResponse += chunk;
        
        // Update the last message with new content
        final lastIndex = _messages.length - 1;
        if (lastIndex >= 0 && !_messages[lastIndex].isUser) {
          _messages[lastIndex] = _messages[lastIndex].copyWith(
            text: fullResponse,
            status: MessageStatus.streaming,
          );
          notifyListeners();
        }
      }
      
      // Mark message as sent when streaming is complete
      final lastIndex = _messages.length - 1;
      if (lastIndex >= 0 && !_messages[lastIndex].isUser) {
        _messages[lastIndex] = _messages[lastIndex].copyWith(
          status: MessageStatus.sent,
        );
        
        // Save the complete message to database
        if (_currentConversationId != null) {
          await _databaseService.insertMessage(_messages[lastIndex]);
        }
        
        notifyListeners();
      }
      
    } catch (e) {
      _setError('Failed to get response: ${e.toString()}');
      
      // Update last message with error
      final lastIndex = _messages.length - 1;
      if (lastIndex >= 0 && !_messages[lastIndex].isUser) {
        _messages[lastIndex] = _messages[lastIndex].copyWith(
          text: 'Sorry, I encountered an error. Please try again.',
          status: MessageStatus.failed,
        );
        
        // Save error message to database
        if (_currentConversationId != null) {
          try {
            await _databaseService.insertMessage(_messages[lastIndex]);
          } catch (dbError) {
            print('Failed to save error message: $dbError');
          }
        }
        
        notifyListeners();
      }
    } finally {
      _setStreaming(false);
    }
  }

  List<Map<String, String>> _buildConversationHistory() {
    final history = <Map<String, String>>[];
    
    // Include last 10 messages for context (excluding current messages)
    final contextMessages = _messages.length > 2 
        ? _messages.take(_messages.length - 1).toList().reversed.take(10).toList().reversed
        : <ChatMessage>[];
    
    for (final message in contextMessages) {
      if (message.status != MessageStatus.failed && message.text.isNotEmpty) {
        history.add({
          'role': message.isUser ? 'user' : 'assistant',
          'content': message.text,
        });
      }
    }
    
    return history;
  }

  String _generateConversationTitle(String firstMessage) {
    final words = firstMessage.split(' ');
    if (words.length <= 5) {
      return firstMessage;
    }
    return '${words.take(5).join(' ')}...';
  }

  Future<List<Conversation>> getConversationHistory({int? limit, int? offset}) async {
    try {
      return await _databaseService.getConversations(limit: limit, offset: offset);
    } catch (e) {
      _setError('Failed to load conversation history: $e');
      return [];
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _databaseService.deleteConversation(conversationId);
      
      // If this is the current conversation, clear messages
      if (_currentConversationId == conversationId) {
        _currentConversationId = null;
        _messages.clear();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to delete conversation: $e');
    }
  }

  void clearCurrentConversation() {
    _currentConversationId = null;
    _messages.clear();
    _setError(null);
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
  
  // Set API key for current model
  Future<void> setApiKey(String apiKey) async {
    await ApiFactory.setApiKey(currentApiModel, apiKey);
    notifyListeners();
  }

  // Switch to a different API model
  Future<void> switchApiModel(ApiModel model) async {
    await ApiFactory.switchModel(model);
    notifyListeners();
  }

  // Check if current model has API key
  Future<bool> hasApiKey() async {
    return await ApiFactory.hasApiKey(currentApiModel);
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }
}
