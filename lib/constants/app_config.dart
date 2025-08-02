class AppConfig {
  // API Configuration
  static const String claudeApiUrl = 'https://api.anthropic.com/v1';
  static const String claudeModel = 'claude-3-sonnet-20240229';
  static const int maxTokens = 1000;
  static const String anthropicVersion = '2023-06-01';
  
  // App Configuration
  static const String appName = 'Claude Killer UI';
  static const String appVersion = '1.0.0';
  
  // Animation Durations (in milliseconds)
  static const int backgroundAnimationDuration = 18000;
  static const int buttonAnimationDuration = 4500;
  static const int fadeAnimationDuration = 1200;
  static const int cardAnimationDuration = 1800;
  static const int pulseAnimationDuration = 3000;
  static const int shimmerAnimationDuration = 5000;
  static const int textRotationInterval = 6000;
  
  // UI Constants
  static const double defaultPadding = 24.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 36.0;
  static const double avatarSize = 70.0;
  static const double floatingButtonHeight = 72.0;
  
  // Development flags
  static const bool isDebugMode = true;
  static const bool useMockApi = true; // Set to false when using real API
}

class ApiKeys {
  static String? _claudeApiKey;
  
  static void setClaudeApiKey(String key) {
    _claudeApiKey = key;
  }
  
  static String? get claudeApiKey => _claudeApiKey;
  
  static bool get hasApiKey => _claudeApiKey != null && _claudeApiKey!.isNotEmpty;
}
