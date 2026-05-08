import 'package:hive/hive.dart';

class CognitiveMemoryService {
  static late Box _memoryBox;
  static late Box _eventLog;
  static late Box _briefsVault;
  static late Box _taskVault;

  static Future<void> init() async {
    _memoryBox = await Hive.openBox('cognitive_memory');
    _eventLog = await Hive.openBox('event_logs');
    _briefsVault = await Hive.openBox('meeting_briefs_vault');
    _taskVault = await Hive.openBox('task_insights_vault');
  }

  static Future<void> saveBriefToVault(Map<String, dynamic> brief) async {
    final list = _briefsVault.get('items', defaultValue: []);
    list.insert(0, {...brief, 'saved_at': DateTime.now().toIso8601String()});
    await _briefsVault.put('items', list);
  }

  static Future<void> saveTaskInsightToVault(Map<String, dynamic> insight) async {
    final list = _taskVault.get('items', defaultValue: []);
    list.insert(0, {...insight, 'saved_at': DateTime.now().toIso8601String()});
    await _taskVault.put('items', list);
  }

  static List<Map<dynamic, dynamic>> getSavedBriefs() => List<Map<dynamic, dynamic>>.from(_briefsVault.get('items', defaultValue: []));
  static List<Map<dynamic, dynamic>> getSavedTaskInsights() => List<Map<dynamic, dynamic>>.from(_taskVault.get('items', defaultValue: []));

  static Future<void> deleteBriefFromVault(int index) async {
    final list = _briefsVault.get('items', defaultValue: []);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await _briefsVault.put('items', list);
    }
  }

  static Future<void> deleteTaskInsightFromVault(int index) async {
    final list = _taskVault.get('items', defaultValue: []);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await _taskVault.put('items', list);
    }
  }

  static List<String> getHabits() => List<String>.from(_memoryBox.get('habits', defaultValue: []));
  static List<String> getPatterns() => List<String>.from(_memoryBox.get('patterns', defaultValue: []));

  static Future<void> logEvent(String type) async {
    final now = DateTime.now();
    final log = _eventLog.get('history', defaultValue: []);
    log.add({
      'type': type,
      'time': now.toIso8601String(),
      'hour': now.hour,
    });
    // Keep last 50 events
    if (log.length > 50) log.removeAt(0);
    await _eventLog.put('history', log);
  }

  static List<Map<dynamic, dynamic>> getRawLogs() {
    return List<Map<dynamic, dynamic>>.from(_eventLog.get('history', defaultValue: []));
  }

  static Future<void> saveAIInsight(String insight) async {
    await _memoryBox.put('patterns', [insight]);
  }

  static Future<void> analyzeBehavior(int tasksCompleted, int researchCount) async {}
}
