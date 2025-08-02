import 'package:flutter/material.dart';
import '../services/chat_controller.dart';
import '../constants/app_config.dart';

class AppController extends ChangeNotifier {
  static final AppController _instance = AppController._internal();
  factory AppController() => _instance;
  AppController._internal();

  late ChatController _chatController;
  bool _isInitialized = false;

  ChatController get chatController => _chatController;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _chatController = ChatController();
    _isInitialized = true;
    
    notifyListeners();
  }

  void setApiKey(String apiKey) {
    if (_isInitialized) {
      _chatController.setApiKey(apiKey);
      ApiKeys.setClaudeApiKey(apiKey);
    }
  }

  void dispose() {
    _chatController.dispose();
    super.dispose();
  }
}
