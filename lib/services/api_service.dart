import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ApiService {
  Future<String> sendMessage(String message);
  Future<Stream<String>> sendStreamMessage(String message);
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
  Future<String> sendMessage(String message) async {
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
  Future<Stream<String>> sendStreamMessage(String message) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not set');
    }

    // This is a placeholder for streaming implementation
    // You would implement Server-Sent Events (SSE) here
    throw UnimplementedError('Streaming not yet implemented');
  }
}

class MockApiService implements ApiService {
  @override
  Future<String> sendMessage(String message) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Mock responses for testing
    final responses = [
      "I understand your question about '$message'. Let me provide you with a comprehensive answer.",
      "That's an interesting point. Based on what you've shared, I would suggest the following approach...",
      "I appreciate you bringing this up. Here's my analysis and recommendations:",
      "Great question! Let me break this down for you step by step.",
      "I see what you're getting at. From my perspective, the key considerations are:",
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch;
    return responses[random % responses.length];
  }

  @override
  Future<Stream<String>> sendStreamMessage(String message) async {
    // Mock streaming response
    return Stream.fromIterable([
      "Let me think about this...",
      " Here's what I can tell you:",
      " Based on your question about '$message',",
      " I would recommend considering several factors.",
      " This should help you move forward effectively."
    ]).asyncMap((chunk) async {
      await Future.delayed(const Duration(milliseconds: 300));
      return chunk;
    });
  }
}
