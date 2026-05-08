class VisionInsight {
  final String mode; // general, notes, timetable, research, chart
  final String originalText;
  final String aiResult;
  final DateTime timestamp;
  final String? imagePath;

  VisionInsight({
    required this.mode,
    required this.originalText,
    required this.aiResult,
    required this.timestamp,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'mode': mode,
      'originalText': originalText,
      'aiResult': aiResult,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory VisionInsight.fromMap(Map<String, dynamic> map) {
    return VisionInsight(
      mode: map['mode'] ?? '',
      originalText: map['originalText'] ?? '',
      aiResult: map['aiResult'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      imagePath: map['imagePath'],
    );
  }
}
