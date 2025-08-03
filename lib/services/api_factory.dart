import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_model.dart';
import 'api_service.dart';

class ApiFactory {
  static const String _selectedModelKey = 'selected_api_model';
  static const String _cohereKeyKey = 'cohere_api_key';
  static const String _geminiKeyKey = 'gemini_api_key';
  static const String _openaiKeyKey = 'openai_api_key';
  static const String _claudeKeyKey = 'claude_api_key';

  static ApiModel _currentModel = ApiModel.cohere; // Default to Cohere (most generous free tier)
  static final Map<ApiModel, ApiService> _services = {};

  // Get current API service
  static ApiService getCurrentService() {
    return _getService(_currentModel);
  }

  // Get current model
  static ApiModel getCurrentModel() {
    return _currentModel;
  }

  // Switch to a different model
  static Future<void> switchModel(ApiModel model) async {
    _currentModel = model;
    await _saveSelectedModel();
  }

  // Get API service for a specific model
  static ApiService _getService(ApiModel model) {
    if (!_services.containsKey(model)) {
      switch (model) {
        case ApiModel.cohere:
          _services[model] = CohereApiService();
          break;
        case ApiModel.gemini:
          _services[model] = GeminiApiService();
          break;
        case ApiModel.openai:
          _services[model] = OpenAIApiService();
          break;
        case ApiModel.claude:
          _services[model] = ClaudeApiService();
          break;
        case ApiModel.mock:
          _services[model] = MockApiService();
          break;
      }
    }
    return _services[model]!;
  }

  // Set API key for a specific model
  static Future<void> setApiKey(ApiModel model, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    
    switch (model) {
      case ApiModel.cohere:
        await prefs.setString(_cohereKeyKey, apiKey);
        if (_services.containsKey(model)) {
          (_services[model] as CohereApiService).setApiKey(apiKey);
        }
        break;
      case ApiModel.gemini:
        await prefs.setString(_geminiKeyKey, apiKey);
        if (_services.containsKey(model)) {
          (_services[model] as GeminiApiService).setApiKey(apiKey);
        }
        break;
      case ApiModel.openai:
        await prefs.setString(_openaiKeyKey, apiKey);
        if (_services.containsKey(model)) {
          (_services[model] as OpenAIApiService).setApiKey(apiKey);
        }
        break;
      case ApiModel.claude:
        await prefs.setString(_claudeKeyKey, apiKey);
        if (_services.containsKey(model)) {
          (_services[model] as ClaudeApiService).setApiKey(apiKey);
        }
        break;
      case ApiModel.mock:
        // No API key needed for mock
        break;
    }
  }

  // Get API key for a specific model
  static Future<String?> getApiKey(ApiModel model) async {
    final prefs = await SharedPreferences.getInstance();
    
    switch (model) {
      case ApiModel.cohere:
        return prefs.getString(_cohereKeyKey);
      case ApiModel.gemini:
        return prefs.getString(_geminiKeyKey);
      case ApiModel.openai:
        return prefs.getString(_openaiKeyKey);
      case ApiModel.claude:
        return prefs.getString(_claudeKeyKey);
      case ApiModel.mock:
        return null; // No API key needed
    }
  }

  // Check if API key is set for a model
  static Future<bool> hasApiKey(ApiModel model) async {
    if (model == ApiModel.mock) return true; // Mock doesn't need key
    final key = await getApiKey(model);
    return key != null && key.isNotEmpty;
  }

  // Initialize API factory (load saved settings)
  static Future<void> initialize() async {
    await _loadSelectedModel();
    await _loadApiKeys();
  }

  // Load saved model selection
  static Future<void> _loadSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModel = prefs.getString(_selectedModelKey);
    if (savedModel != null) {
      try {
        _currentModel = ApiModel.values.firstWhere(
          (model) => model.name == savedModel,
          orElse: () => ApiModel.cohere,
        );
      } catch (e) {
        _currentModel = ApiModel.cohere; // Fallback to Cohere
      }
    }
  }

  // Save current model selection
  static Future<void> _saveSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelKey, _currentModel.name);
  }

  // Load all saved API keys
  static Future<void> _loadApiKeys() async {
    for (final model in ApiModel.values) {
      final apiKey = await getApiKey(model);
      if (apiKey != null && apiKey.isNotEmpty) {
        final service = _getService(model);
        switch (model) {
          case ApiModel.cohere:
            (service as CohereApiService).setApiKey(apiKey);
            break;
          case ApiModel.gemini:
            (service as GeminiApiService).setApiKey(apiKey);
            break;
          case ApiModel.openai:
            (service as OpenAIApiService).setApiKey(apiKey);
            break;
          case ApiModel.claude:
            (service as ClaudeApiService).setApiKey(apiKey);
            break;
          case ApiModel.mock:
            // No API key needed
            break;
        }
      }
    }
  }

  // Get all available models
  static List<ApiModel> getAllModels() {
    return ApiModel.values;
  }

  // Get only free models
  static List<ApiModel> getFreeModels() {
    return ApiModel.values.where((model) => model.isFree).toList();
  }

  // Get models that require API keys
  static List<ApiModel> getPaidModels() {
    return ApiModel.values.where((model) => !model.isFree).toList();
  }
}
