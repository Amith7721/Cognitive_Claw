import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/calendar_service.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _box;

  static const String _defaultModel = 'openrouter/free';

  static const List<String> _validModels = [
    'openrouter/free',
    'openai/gpt-oss-20b:free',
    'z-ai/glm-4.5-air:free',
    'openai/gpt-oss-120b:free',
  ];

  bool _calendarConnected = false;
  bool get calendarConnected => _calendarConnected;

  SettingsProvider() {
    _box = Hive.box('settings');
    // Reset if old/invalid model is cached
    final stored = _box.get('selectedModel', defaultValue: _defaultModel) as String;
    if (!_validModels.contains(stored)) {
      _box.put('selectedModel', _defaultModel);
    }
    syncCalendarStatus();
  }

  Future<void> syncCalendarStatus() async {
    _calendarConnected = await CalendarService.isSignedIn();
    notifyListeners();
  }

  bool get isDarkMode => _box.get('darkMode', defaultValue: true);
  
  bool get notificationsEnabled => _box.get('notifications', defaultValue: true);
  
  String get selectedModel => _box.get('selectedModel', defaultValue: 'openai/gpt-oss-20b:free');

  String get userName => _box.get('userName', defaultValue: '');
  String get userRole => _box.get('userRole', defaultValue: '');
  String get userGoals => _box.get('userGoals', defaultValue: '');
  String get userSkills => _box.get('userSkills', defaultValue: '');
  String get preferredTone => _box.get('preferredTone', defaultValue: 'Professional');

  double get profileCompletion {
    double score = 0;
    // Check for non-empty and non-default values
    if (userName.isNotEmpty && userName != 'User') score += 0.2;
    if (userRole.isNotEmpty && userRole != 'Researcher') score += 0.2;
    if (userGoals.isNotEmpty) score += 0.2;
    if (userSkills.isNotEmpty) score += 0.2;
    if (preferredTone.isNotEmpty) score += 0.2;
    return score;
  }

  bool get isProfileComplete => profileCompletion >= 0.99; // Using float margin

  String get modelName {
    final id = selectedModel;
    if (id == 'auto') return 'Auto Mode (Orchestrated)';
    if (id.contains('120b')) return 'GPT-OSS 120B (Deep Thinking)';
    if (id.contains('20b')) return 'GPT-OSS 20B (Balanced)';
    if (id.contains('mistral')) return 'Mistral 7B (Ultra Fast)';
    if (id.contains('llama')) return 'Llama 3.3 (Premium)';
    return 'Neural Engine';
  }

  String get modelTag {
    final id = selectedModel;
    if (id == 'auto') return 'Smart';
    if (id.contains('120b')) return 'Deep Thinker';
    if (id.contains('20b')) return 'Fast & Balanced';
    if (id.contains('mistral')) return 'Ultra Fast';
    if (id.contains('llama')) return 'Premium Intelligence';
    return 'Active';
  }

  void updateProfile({
    required String name, 
    required String role, 
    required String goals, 
    required String skills, 
    required String tone
  }) {
    _box.put('userName', name);
    _box.put('userRole', role);
    _box.put('userGoals', goals);
    _box.put('userSkills', skills);
    _box.put('preferredTone', tone);
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _box.put('darkMode', value);
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _box.put('notifications', value);
    notifyListeners();
  }

  void setModel(String model) {
    _box.put('selectedModel', model);
    notifyListeners();
  }
}
