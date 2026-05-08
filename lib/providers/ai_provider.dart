import 'package:flutter/material.dart';

import '../services/claude_service.dart';
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

      _response = await ClaudeService.generate(
        prompt: prompt,
        userName: userName,
      );
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
