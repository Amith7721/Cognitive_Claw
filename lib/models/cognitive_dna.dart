class CognitiveDNA {
  final List<String> identityTags;
  final List<String> productivityInsights;
  final double cognitiveEfficiency;
  final String auraPulse;
  final Map<String, int> topInterests;
  final DateTime lastUpdated;

  CognitiveDNA({
    required this.identityTags,
    required this.productivityInsights,
    required this.cognitiveEfficiency,
    required this.auraPulse,
    required this.topInterests,
    required this.lastUpdated,
  });

  factory CognitiveDNA.initial() {
    return CognitiveDNA(
      identityTags: ["Establishing Core...", "Neural Baseline"],
      productivityInsights: ["Analyzing your focus patterns..."],
      cognitiveEfficiency: 0.1,
      auraPulse: "Stable",
      topInterests: {},
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identityTags': identityTags,
      'productivityInsights': productivityInsights,
      'cognitiveEfficiency': cognitiveEfficiency,
      'auraPulse': auraPulse,
      'topInterests': topInterests.map((k, v) => MapEntry(k, v)),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CognitiveDNA.fromMap(Map<String, dynamic> map) {
    return CognitiveDNA(
      identityTags: List<String>.from(map['identityTags'] ?? []),
      productivityInsights: List<String>.from(map['productivityInsights'] ?? []),
      cognitiveEfficiency: (map['cognitiveEfficiency'] ?? 0.85).toDouble(),
      auraPulse: map['auraPulse'] ?? "Stable",
      topInterests: Map<String, int>.from(map['topInterests'] ?? {}),
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }
}
