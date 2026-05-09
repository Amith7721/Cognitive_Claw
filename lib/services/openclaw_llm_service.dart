import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'model_routing_service.dart';

class OpenClawLLMService {
  static final Dio _dio = Dio();

  static Future<Map<String, String>> generate({
    required String prompt,
    required String model,
  }) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    
    // Agentic Routing Logic
    String targetModel = model;
    if (model == 'openrouter/free' || model.isEmpty) {
      targetModel = ModelRoutingService.route(prompt);
      print("🚀 Model Routing: Orchestrated to Auto ($targetModel)");
    }
    
    try {
      return await _makeRequest(targetModel, prompt, apiKey, originalModel: model);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429 && targetModel != 'openai/gpt-oss-20b:free') {
        print("⚠️ Rate limit hit on $targetModel. Falling back to stable engine...");
        return await _makeRequest('openai/gpt-oss-20b:free', prompt, apiKey, originalModel: model);
      }
      return {
        'response': "AI Error: $e",
        'model': 'error',
      };
    }
  }

  static Future<Map<String, String>> _makeRequest(String model, String prompt, String apiKey, {String? originalModel}) async {
    final response = await _dio.post(
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
        "model": model,
        "messages": [
          {
            "role": "system",
            "content": "You are the core intelligence of Cognitive Claw Agentic OS. Provide high-fidelity, professional insights.",
          },
          {
            "role": "user",
            "content": prompt,
          }
        ]
      },
    );

    // Extract the ACTUAL model used (OpenRouter returns this in the 'model' field)
    final actualModelId = response.data['model']?.toString() ?? model;
    final actualModelName = actualModelId.split('/').last;
    
    // Format the display name: if Auto was requested, show "Auto (Model)"
    final isAuto = originalModel == 'openrouter/free' || originalModel == 'auto' || originalModel == null || originalModel.isEmpty;
    final displayModel = isAuto ? "Auto ($actualModelName)" : actualModelName;

    return {
      'response': response.data['choices'][0]['message']['content'].toString().trim(),
      'model': displayModel,
    };
  }
}
