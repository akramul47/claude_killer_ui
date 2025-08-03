import 'dart:io';
import 'package:http/http.dart' as http;

class HttpClientHelper {
  static const Duration _receiveTimeout = Duration(seconds: 60);
  
  static http.Client createClient() {
    final client = http.Client();
    return client;
  }
  
  static Future<http.Response> postWithTimeout({
    required Uri url,
    required Map<String, String> headers,
    required String body,
    Duration? timeout,
  }) async {
    final client = createClient();
    
    try {
      final response = await client.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        timeout ?? _receiveTimeout,
        onTimeout: () {
          throw TimeoutException('Request timeout after ${timeout ?? _receiveTimeout}', timeout ?? _receiveTimeout);
        },
      );
      
      return response;
    } catch (e) {
      if (e is SocketException) {
        if (e.message.contains('No address associated with hostname') ||
            e.message.contains('nodename nor servname provided') ||
            e.message.contains('Name or service not known')) {
          throw Exception('Network Error: Unable to resolve hostname. Please check your internet connection and try again.');
        } else if (e.message.contains('Connection refused') ||
                   e.message.contains('Connection timed out')) {
          throw Exception('Network Error: Connection failed. Please check your internet connection and try again.');
        } else {
          throw Exception('Network Error: ${e.message}');
        }
      } else if (e is TimeoutException) {
        throw Exception('Request Timeout: The server took too long to respond. Please try again.');
      } else {
        rethrow;
      }
    } finally {
      client.close();
    }
  }
  
  static Future<http.StreamedResponse> postStreamWithTimeout({
    required Uri url,
    required Map<String, String> headers,
    required String body,
    Duration? timeout,
  }) async {
    final client = createClient();
    
    try {
      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      request.body = body;
      
      final response = await client.send(request).timeout(
        timeout ?? _receiveTimeout,
        onTimeout: () {
          throw TimeoutException('Request timeout after ${timeout ?? _receiveTimeout}', timeout ?? _receiveTimeout);
        },
      );
      
      return response;
    } catch (e) {
      if (e is SocketException) {
        if (e.message.contains('No address associated with hostname') ||
            e.message.contains('nodename nor servname provided') ||
            e.message.contains('Name or service not known')) {
          throw Exception('Network Error: Unable to resolve hostname. Please check your internet connection and try again.');
        } else if (e.message.contains('Connection refused') ||
                   e.message.contains('Connection timed out')) {
          throw Exception('Network Error: Connection failed. Please check your internet connection and try again.');
        } else {
          throw Exception('Network Error: ${e.message}');
        }
      } else if (e is TimeoutException) {
        throw Exception('Request Timeout: The server took too long to respond. Please try again.');
      } else {
        rethrow;
      }
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration? duration;
  
  const TimeoutException(this.message, this.duration);
  
  @override
  String toString() => message;
}
