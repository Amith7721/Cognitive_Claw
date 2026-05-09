import 'package:flutter/material.dart';

import '../services/openclaw_llm_service.dart';
import '../core/theme/app_theme.dart';

class AIProvider extends ChangeNotifier {
  bool _loading = false;
  void setResponse(String text) {
  _response = text;

  notifyListeners();
}
  String? _response;

  String? _error;

  bool get loading => _loading;

  String? get response => _response;

  String? get error => _error;

  Future<void> generate({required String prompt, String? model, String? userName}) async {
    try {
      _loading = true;
      _error = null;
      _response = null;
      notifyListeners();

      final result = await OpenClawLLMService.generate(
        prompt: prompt,
        model: model ?? 'auto',
      );

      _response = result['response'] ?? '';
      final usedModel = result['model'] ?? 'unknown';

      // Always append the model signature for Research results
      _response = "$_response\n\n---\n*Active Research Engine: $usedModel*";

    } catch (e) {
      _error = e.toString();
      _response = "AI Error: $e";
    }

    _loading = false;
    notifyListeners();
  }

  void clear() {
    _response = null;

    _error = null;

    notifyListeners();
  }
}
