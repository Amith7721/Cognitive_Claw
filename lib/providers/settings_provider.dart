import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/calendar_service.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _box;

  static const String _defaultModel = 'openai/gpt-oss-20b:free';

  static const List<String> _validModels = [
    'openai/gpt-oss-20b:free',
    'openai/gpt-oss-120b:free',
    'mistralai/mistral-7b-instruct:free',
    'meta-llama/llama-3.1-8b-instruct:free',
    'meta-llama/llama-3.3-70b-instruct:free',
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
    if (id.contains('gpt-oss')) return 'OpenAI Free';
    if (id.contains('mistral')) return 'Mistral 7B (Free)';
    return 'AI Engine';
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
