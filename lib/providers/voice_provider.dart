import 'package:flutter/material.dart';

class VoiceProvider extends ChangeNotifier {
  bool _isSpeaking = false;
  String _userSpeech = "";
  String _aiSpeech = "";

  bool get isSpeaking => _isSpeaking;
  String get userSpeech => _userSpeech;
  String get aiSpeech => _aiSpeech;

  void startSpeaking(String userQuery) {
    _isSpeaking = true;
    _userSpeech = userQuery;
    _aiSpeech = "...";
    notifyListeners();
  }

  void updateAiSpeech(String response) {
    _aiSpeech = response;
    notifyListeners();
  }

  void stopSpeaking() {
    _isSpeaking = false;
    _userSpeech = "";
    _aiSpeech = "";
    notifyListeners();
  }
}
