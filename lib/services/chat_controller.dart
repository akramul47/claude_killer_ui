import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../constants/app_config.dart';

class ChatController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  late ApiService _apiService;
  
  bool _isLoading = false;
  String? _error;

  ChatController() {
    _apiService = AppConfig.useMockApi ? MockApiService() : ClaudeApiService();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    notifyListeners();

    // Set loading state
    _setLoading(true);
    _setError(null);

    try {
      // Get AI response
      final response = await _apiService.sendMessage(text.trim());
      
      // Add AI message
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(aiMessage);
      
    } catch (e) {
      _setError('Failed to get response: ${e.toString()}');
      
      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendStreamMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    notifyListeners();

    // Create placeholder AI message for streaming
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    _messages.add(aiMessage);
    _setLoading(true);
    _setError(null);

    try {
      final stream = await _apiService.sendStreamMessage(text.trim());
      
      await for (final chunk in stream) {
        // Update the last message with new content
        final lastIndex = _messages.length - 1;
        if (lastIndex >= 0 && !_messages[lastIndex].isUser) {
          _messages[lastIndex] = _messages[lastIndex].copyWith(
            text: _messages[lastIndex].text + chunk,
          );
          notifyListeners();
        }
      }
      
    } catch (e) {
      _setError('Failed to get response: ${e.toString()}');
      
      // Update last message with error
      final lastIndex = _messages.length - 1;
      if (lastIndex >= 0 && !_messages[lastIndex].isUser) {
        _messages[lastIndex] = _messages[lastIndex].copyWith(
          text: 'Sorry, I encountered an error. Please try again.',
        );
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  void clearMessages() {
    _messages.clear();
    _setError(null);
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
  
  void setApiKey(String apiKey) {
    if (!AppConfig.useMockApi) {
      _apiService = ClaudeApiService(apiKey: apiKey);
    }
    ApiKeys.setClaudeApiKey(apiKey);
  }
}
