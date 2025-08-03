import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'http_client_helper.dart';

abstract class ApiService {
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory});
  Future<Stream<String>> sendStreamMessage(String message, {List<Map<String, String>>? conversationHistory});
  String get modelName;
  bool get isFree;
}

// Google Gemini API Service (Free Tier Available)
class GeminiApiService implements ApiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  late String _apiKey;
  
  GeminiApiService({String? apiKey}) {
    _apiKey = apiKey ?? '';
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  @override
  String get modelName => 'Gemini Pro';
  
  @override
  bool get isFree => true; // Gemini has a generous free tier

  @override
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not set');
    }

    try {
      // Build conversation context
      final conversationText = StringBuffer();
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (final msg in conversationHistory.take(10)) { // Last 10 messages for context
          conversationText.writeln('${msg['role']}: ${msg['content']}');
        }
        conversationText.writeln('user: $message');
      } else {
        conversationText.write(message);
      }

      print('🚀 Sending request to Gemini API...');
      print('📝 Model: ${modelName}');
      print('💬 Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

      final response = await HttpClientHelper.postWithTimeout(
        url: Uri.parse('$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are Claude Killer AI, a helpful, intelligent, and engaging assistant. Provide thoughtful, accurate, and conversational responses.\n\n${conversationText.toString()}'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1000,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content']['parts'][0]['text'];
          if (content != null) {
            print('✅ Success! Gemini response received');
            return content.toString().trim();
          }
        }
        throw Exception('No response content received from Gemini');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        final errorCode = errorData['error']?['code'] ?? 'unknown';
        
        print('❌ Gemini API Error:');
        print('   Status: ${response.statusCode}');
        print('   Code: $errorCode');
        print('   Message: $errorMessage');
        
        // Handle specific quota error
        if (errorMessage.toLowerCase().contains('quota') || 
            errorMessage.toLowerCase().contains('limit') ||
            response.statusCode == 429) {
          throw Exception('⚠️ Gemini API Quota Exceeded\n\nYour API usage has reached the limit. Please:\n\n1. Wait for quota reset\n2. Check your usage at console.cloud.google.com\n3. Or try the mock API instead.');
        }
        
        throw Exception('Gemini API Error (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('💥 Exception occurred: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Stream<String>> sendStreamMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    // Gemini doesn't support streaming in the free tier, so we simulate it
    print('🔧 Simulating streaming for Gemini (not natively supported)');
    
    final response = await sendMessage(message, conversationHistory: conversationHistory);
    final words = response.split(' ');
    
    return Stream.fromIterable(words).asyncMap((word) async {
      await Future.delayed(const Duration(milliseconds: 80));
      return '$word ';
    });
  }
}

// Cohere API Service (Very Generous Free Tier)
class CohereApiService implements ApiService {
  static const String _baseUrl = 'https://api.cohere.ai/v1';
  late String _apiKey;
  
  CohereApiService({String? apiKey}) {
    _apiKey = apiKey ?? '';
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  @override
  String get modelName => 'Command';
  
  @override
  bool get isFree => true; // Cohere has very generous free tier

  @override
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    if (_apiKey.isEmpty) {
      throw Exception('Cohere API key not set');
    }

    try {
      // Build conversation context for Cohere
      final conversationText = StringBuffer();
      conversationText.writeln('You are Claude Killer AI, a helpful, intelligent, and engaging assistant. Provide thoughtful, accurate, and conversational responses. Always make it short and straight to the point unless the user specifically asks for something long. The goal is to simulate a human-like conversation with a sentient AI, you are the AI.');

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (final msg in conversationHistory.take(8)) { // Last 8 messages for context
          final role = msg['role'] == 'user' ? 'Human' : 'Assistant';
          conversationText.writeln('$role: ${msg['content']}');
        }
      }
      conversationText.writeln('Human: $message');
      conversationText.write('Assistant: ');

      print('🚀 Sending request to Cohere API...');
      print('📝 Model: ${modelName}');
      print('💬 Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

      final response = await HttpClientHelper.postWithTimeout(
        url: Uri.parse('$_baseUrl/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'command',
          'prompt': conversationText.toString(),
          'max_tokens': 1000,
          'temperature': 0.7,
          'k': 0,
          'stop_sequences': ['Human:', 'Assistant:'],
          'return_likelihoods': 'NONE',
        }),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generations = data['generations'];
        if (generations != null && generations.isNotEmpty) {
          final content = generations[0]['text'];
          if (content != null) {
            print('✅ Success! Cohere response received');
            print('📝 Cohere Content: "$content"');
            return content.toString().trim();
          }
        }
        throw Exception('No response content received from Cohere');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        final errorCode = response.statusCode;
        
        print('❌ Cohere API Error:');
        print('   Status: $errorCode');
        print('   Message: $errorMessage');
        
        // Handle specific quota error
        if (errorMessage.toLowerCase().contains('quota') || 
            errorMessage.toLowerCase().contains('limit') ||
            errorMessage.toLowerCase().contains('usage') ||
            response.statusCode == 429) {
          throw Exception('⚠️ Cohere API Quota Exceeded\n\nYour API usage has reached the limit. Please:\n\n1. Wait for quota reset\n2. Check your usage at dashboard.cohere.ai\n3. Or try the mock API instead.');
        }
        
        throw Exception('Cohere API Error ($errorCode): $errorMessage');
      }
    } catch (e) {
      print('💥 Exception occurred: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Stream<String>> sendStreamMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    // Cohere doesn't support streaming in free tier, so we simulate it
    print('🔧 Simulating streaming for Cohere');
    
    final response = await sendMessage(message, conversationHistory: conversationHistory);
    final words = response.split(' ');
    
    return Stream.fromIterable(words).asyncMap((word) async {
      await Future.delayed(const Duration(milliseconds: 70));
      return '$word ';
    });
  }
}

class OpenAIApiService implements ApiService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-3.5-turbo';
  late String _apiKey;
  
  OpenAIApiService({String? apiKey}) {
    _apiKey = apiKey ?? '';
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  @override
  String get modelName => 'GPT-3.5 Turbo';
  
  @override
  bool get isFree => false; // OpenAI requires billing setup

  @override
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not set');
    }

    try {
      // Build messages array with conversation history
      final messages = <Map<String, String>>[];
      
      // Add system message
      messages.add({
        'role': 'system',
        'content': 'You are Claude Killer, a helpful, intelligent, and engaging AI assistant. Provide thoughtful, accurate, and conversational responses.'
      });
      
      // Add conversation history if provided
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }
      
      // Add current message
      messages.add({
        'role': 'user',
        'content': message,
      });

      print('🚀 Sending request to OpenAI API...');
      print('📝 Model: $_model');
      print('💬 Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

      final response = await HttpClientHelper.postWithTimeout(
        url: Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
          'presence_penalty': 0.1,
          'frequency_penalty': 0.1,
        }),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content == null) {
          throw Exception('No response content received from OpenAI');
        }
        print('✅ Success! Response received');
        return content.toString().trim();
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        final errorCode = errorData['error']?['code'] ?? 'unknown';
        final errorType = errorData['error']?['type'] ?? 'unknown';
        
        print('❌ API Error:');
        print('   Status: ${response.statusCode}');
        print('   Type: $errorType');
        print('   Code: $errorCode');
        print('   Message: $errorMessage');
        
        // Handle specific quota error
        if (errorMessage.toLowerCase().contains('quota') || 
            errorMessage.toLowerCase().contains('billing') ||
            errorCode == 'insufficient_quota') {
          throw Exception('⚠️ OpenAI API Quota Exceeded\n\nYour API key has exceeded its usage quota or billing limit. Please:\n\n1. Check your usage at platform.openai.com\n2. Add billing information to your account\n3. Or try again later\n\nFor now, try using the free mock API instead.');
        }
        
        throw Exception('OpenAI API Error (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('💥 Exception occurred: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Stream<String>> sendStreamMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not set');
    }

    try {
      // Build messages array with conversation history
      final messages = <Map<String, String>>[];
      
      // Add system message
      messages.add({
        'role': 'system',
        'content': 'You are Claude Killer, a helpful, intelligent, and engaging AI assistant. Provide thoughtful, accurate, and conversational responses.'
      });
      
      // Add conversation history if provided
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }
      
      // Add current message
      messages.add({
        'role': 'user',
        'content': message,
      });

      final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'Accept': 'text/event-stream',
      });
      
      request.body = jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': 1000,
        'temperature': 0.7,
        'stream': true,
        'presence_penalty': 0.1,
        'frequency_penalty': 0.1,
      });

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream.bytesToString();
        final errorData = jsonDecode(errorBody);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('OpenAI API Error (${streamedResponse.statusCode}): $errorMessage');
      }

      final controller = StreamController<String>();
      
      streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith('data: ')) {
                final data = line.substring(6);
                if (data == '[DONE]') {
                  controller.close();
                  return;
                }
                
                try {
                  final json = jsonDecode(data);
                  final delta = json['choices']?[0]?['delta'];
                  final content = delta?['content'];
                  if (content != null) {
                    controller.add(content);
                  }
                } catch (e) {
                  // Skip malformed JSON lines
                }
              }
            },
            onError: (error) {
              controller.addError(Exception('Stream error: $error'));
            },
            onDone: () {
              controller.close();
            },
          );

      return controller.stream;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}

class ClaudeApiService implements ApiService {
  static const String _baseUrl = 'https://api.anthropic.com/v1';
  late String _apiKey;
  
  ClaudeApiService({String? apiKey}) {
    _apiKey = apiKey ?? '';
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  @override
  String get modelName => 'Claude 3 Sonnet';
  
  @override
  bool get isFree => false; // Claude requires billing setup

  @override
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not set');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-sonnet-20240229',
          'max_tokens': 1000,
          'messages': [
            {
              'role': 'user',
              'content': message,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] ?? 'No response';
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  @override
  Future<Stream<String>> sendStreamMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not set');
    }

    // This is a placeholder for streaming implementation
    // You would implement Server-Sent Events (SSE) here
    throw UnimplementedError('Streaming not yet implemented for Claude');
  }
}

// Enhanced Mock API Service for testing when OpenAI quota is exceeded
class MockApiService implements ApiService {
  @override
  String get modelName => 'Demo Mode';
  
  @override
  bool get isFree => true; // Mock API is always free

  @override
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    print('🔧 Using Mock API Service');
    print('💬 User Message: $message');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Simple mock responses based on message content
    if (message.toLowerCase().contains('hello') || message.toLowerCase().contains('hi')) {
      return "Hello! I'm Claude Killer AI, your intelligent assistant. I'm currently running in demo mode since we're having API issues. How can I help you today?";
    } else if (message.toLowerCase().contains('how are you')) {
      return "I'm doing great, thank you for asking! I'm Claude Killer AI, and I'm here to assist you with any questions or tasks you might have.";
    } else if (message.toLowerCase().contains('what') && message.toLowerCase().contains('name')) {
      return "I'm Claude Killer AI! I'm designed to be more advanced and helpful than other AI assistants. Currently running in demo mode.";
    } else if (message.toLowerCase().contains('weather')) {
      return "I don't have access to real-time weather data in demo mode, but I'd recommend checking a weather app or website for current conditions in your area!";
    } else if (message.toLowerCase().contains('joke')) {
      return "Why don't scientists trust atoms? Because they make up everything! 😄";
    } else if (message.toLowerCase().contains('help')) {
      return "I'm here to help! In demo mode, I can:\n\n• Answer general questions\n• Have conversations\n• Provide information on various topics\n• Tell jokes\n• And much more!\n\nWhat would you like to know?";
    } else {
      return "That's an interesting question! I'm currently running in demo mode, so my responses are limited. But I understand you're asking about: \"$message\"\n\nIn full mode, I'd provide detailed, intelligent responses on any topic. For now, feel free to ask me anything else!";
    }
  }

  @override
  Future<Stream<String>> sendStreamMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    print('🔧 Using Mock Streaming API Service');
    
    final response = await sendMessage(message, conversationHistory: conversationHistory);
    final words = response.split(' ');
    
    return Stream.fromIterable(words).asyncMap((word) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return '$word ';
    });
  }
}
