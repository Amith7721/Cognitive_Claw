import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClaudeService {
  static final Dio dio = Dio();

  static Future<String> generate({
    required String prompt,
    String? userName,
  }) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    
    final response = await dio.post(
      'https://openrouter.ai/api/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://cognitiveclaw.ai',
          'X-Title': 'Cognitive Claw',
        },
      ),
      data: {
        "model": "openai/gpt-oss-20b:free",
        "messages": [
          {
            "role": "system",
            "content": "You are Cognitive Claw, a powerful AI agent. The user's name is ${userName ?? 'User'}. Always be helpful, concise, and address them by name occasionally.",
          },
          {
            "role": "user",
            "content": prompt,
          }
        ]
      },
    );

    return response.data['choices'][0]['message']['content'];
  }
}
