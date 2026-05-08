import 'package:hive/hive.dart';
import '../models/cognitive_dna.dart';
import 'openclaw_llm_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class CognitiveDNAService {
  static final _box = Hive.box('settings'); // Store DNA in settings box for simplicity
  static final _logBox = Hive.box('activity_logs'); // Temporary logs for analysis

  static Future<void> init() async {
    if (!Hive.isBoxOpen('activity_logs')) {
      await Hive.openBox('activity_logs');
    }
  }

  static CognitiveDNA getDNA() {
    final data = _box.get('cognitive_dna');
    if (data == null) return CognitiveDNA.initial();
    try {
      return CognitiveDNA.fromMap(Map<String, dynamic>.from(data));
    } catch (e) {
      return CognitiveDNA.initial();
    }
  }

  static Future<void> logActivity(String type, String detail) async {
    final log = {
      'type': type,
      'detail': detail,
      'time': DateTime.now().toIso8601String(),
    };
    await _logBox.add(log);
    debugPrint("Cognitive Log: $type - $detail");
  }

  static Future<void> refreshDNA(String model) async {
    final logs = _logBox.values.toList();
    if (logs.isEmpty) return;

    try {
      final currentDNA = getDNA();
      
      final analysisPrompt = '''
[SYSTEM: COGNITIVE DNA ANALYZER]
You are the core intelligence of Cognitive Claw. Your task is to analyze user activity logs and evolve their "Cognitive DNA".

CURRENT DNA DATA:
Tags: ${currentDNA.identityTags.join(", ")}
Insights: ${currentDNA.productivityInsights.join(", ")}
Efficiency: ${currentDNA.cognitiveEfficiency}

USER ACTIVITY LOGS:
$logs

YOUR MISSION:
1. Detect behavioral patterns (Timing, Interests, Work style).
2. Generate 3-5 high-fidelity "Identity Tags" (e.g. "Night Owl", "Deep Focus Enthusiast", "Vision Digitizer").
3. Generate 3 "Productivity Insights" (e.g. "Productivity peaks at 10 PM", "Frequent Vision-to-Task conversion detected").
4. Update Cognitive Efficiency score (0.0 to 1.0).
5. Set Aura Pulse status (Radiant, Stable, High, or Critical).

RETURN FORMAT (MANDATORY):
Provide your response in this EXACT structure:
TAGS: Tag1 | Tag2 | Tag3
INSIGHTS: Insight1 | Insight2 | Insight3
EFFICIENCY: 0.XX
PULSE: Status
''';

      final response = await OpenClawLLMService.generate(
        model: model,
        prompt: analysisPrompt,
      );

      // Parse the response
      final lines = response.split('\n');
      List<String> tags = currentDNA.identityTags;
      List<String> insights = currentDNA.productivityInsights;
      double efficiency = currentDNA.cognitiveEfficiency;
      String pulse = currentDNA.auraPulse;

      for (var line in lines) {
        if (line.startsWith('TAGS:')) {
          tags = line.replaceFirst('TAGS:', '').split('|').map((e) => e.trim()).toList();
        } else if (line.startsWith('INSIGHTS:')) {
          insights = line.replaceFirst('INSIGHTS:', '').split('|').map((e) => e.trim()).toList();
        } else if (line.startsWith('EFFICIENCY:')) {
          efficiency = double.tryParse(line.replaceFirst('EFFICIENCY:', '').trim()) ?? efficiency;
        } else if (line.startsWith('PULSE:')) {
          pulse = line.replaceFirst('PULSE:', '').trim();
        }
      }

      final newDNA = CognitiveDNA(
        identityTags: tags,
        productivityInsights: insights,
        cognitiveEfficiency: efficiency,
        auraPulse: pulse,
        topInterests: currentDNA.topInterests, // Keep for now
        lastUpdated: DateTime.now(),
      );

      await saveDNA(newDNA);
      // Clear logs after successful analysis to start fresh
      await _logBox.clear();
      
    } catch (e) {
      debugPrint("DNA Refresh Error: $e");
    }
  }

  static Future<void> saveDNA(CognitiveDNA dna) async {
    await _box.put('cognitive_dna', dna.toMap());
  }
}
