import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenClawLLMService {
  static final Dio _dio = Dio();

  static final String _apiKey =
      dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static Future<String> generate({
    required String prompt,
    required String model,
  }) async {
    try {
      final response = await _dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://cognitiveclaw.ai', // Required by some OpenRouter models
            'X-Title': 'Cognitive Claw',
          },
        ),
        data: {
          "model": model.isEmpty ? "openai/gpt-oss-20b:free" : model,
          "messages": [
            {
              "role": "user",
              "content": prompt,
            }
          ]
        },
      );

      return response
              .data['choices'][0]
          ['message']['content'];
    } catch (e) {
      return "AI Error: $e";
    }
  }
}
