import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/research_paper.dart';
import '../models/saved_insight.dart';
import '../services/arxiv_service.dart';
import '../services/cognitive_memory_service.dart';
import '../services/cognitive_dna_service.dart';
import '../core/theme/app_theme.dart';

class ResearchProvider extends ChangeNotifier {
  List<ResearchPaper> _papers = [];
  final List<ResearchPaper> _history = [];
  final List<SavedInsight> _savedInsights = [];
  
  final _historyBox = Hive.box('research_history');
  final _insightsBox = Hive.box('research_insights');

  bool _loading = false;
  String? _error;

  List<ResearchPaper> get papers => _papers;
  List<ResearchPaper> get history => _history;
  List<SavedInsight> get savedInsights => _savedInsights;

  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadPersistentData() async {
    _history.clear();
    final historyData = _historyBox.values.map((e) => ResearchPaper.fromMap(Map<String, dynamic>.from(e))).toList();
    _history.addAll(historyData);

    _savedInsights.clear();
    final insightsData = _insightsBox.values.map((e) => SavedInsight.fromMap(Map<String, dynamic>.from(e))).toList();
    _savedInsights.addAll(insightsData);
    
    notifyListeners();
  }

  Future<void> addToHistory(ResearchPaper paper) async {
    // Remove if already exists (to move to front)
    _history.removeWhere((p) => p.link == paper.link);
    _history.insert(0, paper);
    if (_history.length > 25) _history.removeLast();
    
    // Persist history
    await _historyBox.clear();
    for (var i = 0; i < _history.length; i++) {
      await _historyBox.add(_history[i].toMap());
    }
    
    CognitiveMemoryService.logEvent('research_view');
    CognitiveDNAService.logActivity('research_activity', 'Viewed paper: ${paper.title}');
    notifyListeners();
  }

  Future<void> saveInsight(SavedInsight insight) async {
    _savedInsights.insert(0, insight);
    await _insightsBox.add(insight.toMap());
    notifyListeners();
  }

  Future<void> deleteHistoryItem(int index) async {
    _history.removeAt(index);
    // Refresh box
    await _historyBox.clear();
    for (var i = 0; i < _history.length; i++) {
      await _historyBox.add(_history[i].toMap());
    }
    notifyListeners();
  }

  Future<void> deleteSavedInsight(int index) async {
    final insight = _savedInsights[index];
    _savedInsights.removeAt(index);
    
    // Find and delete from Hive
    final Map<dynamic, dynamic> target = _insightsBox.toMap();
    dynamic keyToDelete;
    target.forEach((key, value) {
      if (value['timestamp'] == insight.timestamp.toIso8601String()) {
        keyToDelete = key;
      }
    });
    
    if (keyToDelete != null) {
      await _insightsBox.delete(keyToDelete);
    }
    notifyListeners();
  }

  void clearResults() {
    _papers = [];
    _error = null;
    notifyListeners();
  }

  Future<void> searchPapers(String keyword) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      _papers = await ArxivService.search(keyword);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
