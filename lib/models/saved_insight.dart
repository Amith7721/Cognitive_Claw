import 'research_paper.dart';

class SavedInsight {
  final ResearchPaper paper;
  final String insight;
  final String type; // summarize, simplify, applications
  final DateTime timestamp;

  SavedInsight({
    required this.paper,
    required this.insight,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'paper': paper.toMap(),
      'insight': insight,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SavedInsight.fromMap(Map<String, dynamic> map) {
    return SavedInsight(
      paper: ResearchPaper.fromMap(Map<String, dynamic>.from(map['paper'])),
      insight: map['insight'] ?? '',
      type: map['type'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
