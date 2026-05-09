import '../core/constants/app_constants.dart';

class ModelRoutingService {
  static String route(String prompt) {
    final lowerPrompt = prompt.toLowerCase();

    // 🔬 Research Mode: GPT-OSS 120B
    if (lowerPrompt.contains('research') || 
        lowerPrompt.contains('paper') || 
        lowerPrompt.contains('arxiv') || 
        lowerPrompt.contains('scientific')) {
      return 'openai/gpt-oss-120b:free';
    }

    // 🧠 Intelligence Mode: GLM 4.5 Air
    if (lowerPrompt.contains('analyze deeply') || 
        lowerPrompt.contains('complex') || 
        lowerPrompt.length > 800) {
      return 'z-ai/glm-4.5-air:free';
    }

    // ⚡ Fast Mode: GPT-OSS 20B
    if (lowerPrompt.length < 150 || lowerPrompt.contains('quick') || lowerPrompt.contains('fast')) {
      return 'openai/gpt-oss-20b:free';
    }

    // 🚀 Default: OpenRouter Free
    return 'openrouter/free';
  }
}
