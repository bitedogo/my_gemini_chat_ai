import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiRepository {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _modelName = 'gemini-2.5-flash';

  late final Uri _baseUrl = Uri.https(
    'generativelanguage.googleapis.com',
    '/v1beta/models/$_modelName:generateContent',
    {'key': _apiKey},
  );

  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _minDelay = Duration(milliseconds: 1000);

  Future<String> sendMessage(List<ChatMessage> conversationHistory) async {
    final now = DateTime.now();
    final timeSinceLastRequest = now.difference(_lastRequestTime);
    if (timeSinceLastRequest < _minDelay) {
      await Future.delayed(_minDelay - timeSinceLastRequest);
    }
    _lastRequestTime = DateTime.now();

    try {
      final apiMessages = conversationHistory
          .where((msg) => !msg.isTyping)
          .map((msg) => {
        'role': msg.role,
        'parts': [
          {'text': msg.content}
        ]
      })
          .toList();

      final response = await http.post(
        _baseUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': apiMessages,
          'generationConfig': {
            'temperature': 0.9,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
          'safetySettings': [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_NONE"
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_NONE"
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_NONE"
            },
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_NONE"
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final candidates = json['candidates'] as List<dynamic>?;

        if (candidates != null &&
            candidates.isNotEmpty &&
            candidates[0]['content'] != null &&
            candidates[0]['content']['parts'] != null &&
            (candidates[0]['content']['parts'] as List).isNotEmpty) {
          return candidates[0]['content']['parts'][0]['text'] as String? ?? '응답 없음';
        }
        return '응답을 생성할 수 없습니다.';
      } else {
        String errorMessage = 'Unknown error';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['error']?['message'] ?? errorMessage;
        } catch (_) {}

        throw Exception('API 오류 (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  Future<bool> validateApiKey() async {
    try {
      final testMessages = [
        ChatMessage(
          id: '0',
          role: 'user',
          content: 'Hi',
          timestamp: DateTime.now(),
        )
      ];
      await sendMessage(testMessages);
      return true;
    } catch (e) {
      return false;
    }
  }
}