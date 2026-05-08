import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/vision_insight.dart';

class VisionProvider extends ChangeNotifier {
  final List<VisionInsight> _savedInsights = [];
  final _box = Hive.box('vision_insights');

  List<VisionInsight> get savedInsights => _savedInsights;

  Future<void> loadPersistentData() async {
    _savedInsights.clear();
    final data = _box.values.map((e) => VisionInsight.fromMap(Map<String, dynamic>.from(e))).toList();
    // Sort by timestamp descending
    data.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _savedInsights.addAll(data);
    notifyListeners();
  }

  Future<void> saveInsight(VisionInsight insight) async {
    _savedInsights.insert(0, insight);
    await _box.add(insight.toMap());
    notifyListeners();
  }

  Future<void> deleteInsight(int index) async {
    final insight = _savedInsights[index];
    _savedInsights.removeAt(index);
    
    // Find and delete from Hive (this is a bit inefficient but safe for demo)
    final Map<dynamic, dynamic> target = _box.toMap();
    dynamic keyToDelete;
    target.forEach((key, value) {
      if (value['timestamp'] == insight.timestamp.toIso8601String()) {
        keyToDelete = key;
      }
    });
    
    if (keyToDelete != null) {
      await _box.delete(keyToDelete);
    }
    
    notifyListeners();
  }
}
