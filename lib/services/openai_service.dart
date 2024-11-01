import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class OpenAIService {
  final List<Map<String, String>> messages = [];
  String botPersona = "You are a banking bot called bankbot and you are supposed to only talk about banking.";
  DateTime? _lastRequestTime;
  static const _minTimeBetweenRequests = Duration(seconds: 1);

  void setBotPersona(String persona) {
    botPersona = persona;
  }

  Future<String> chatGPTAPI(String prompt) async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minTimeBetweenRequests) {
        await Future.delayed(_minTimeBetweenRequests - timeSinceLastRequest);
      }
    }
    _lastRequestTime = DateTime.now();
    messages.add({
      "role": "user",
      "content": "$botPersona $prompt",
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY_HERE',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
        }),
      );
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'];
      
      messages.add({
        'role': 'assistant',
        'content': content,
      });
      if (content.trim().isEmpty) {
        return "I'm sorry, I didn't understand that. Could you please rephrase your question?";
      }
      return content;
    } catch (e) {
      if (e is SocketException) {
        return 'Network error. Please check your internet connection.';
      } else if (e is http.ClientException) {
        return 'Error connecting to the server. Please try again later.';
      } else {
        return 'An unexpected error occurred: ${e.toString()}';
      }
    }
  }

  void clearContext() {
    messages.clear();
  }
}
