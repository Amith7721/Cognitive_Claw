import 'package:flutter/services.dart' show rootBundle;
import 'openclaw_llm_service.dart';
import 'calendar_service.dart';
import 'cognitive_dna_service.dart';

class OpenClawAgentService {
  static Future<String> generateDailyBrief({
    required String model,
    String? userName,
    String? userRole,
    String? userGoals,
    String? userSkills,
    String? preferredTone,
  }) async {
    try {
      // 1. Load Architecture
      final soul = await rootBundle.loadString('assets/openclaw/soul.md');
      final memory = await rootBundle.loadString('assets/openclaw/memory.md');
      final heartbeat = await rootBundle.loadString('assets/openclaw/heartbeat.md');

      // 2. Load Modular Skills
      final meetingSkill = await rootBundle.loadString('assets/openclaw/skills/meeting_skill.md');
      final researchSkill = await rootBundle.loadString('assets/openclaw/skills/research_skill.md');
      final productivitySkill = await rootBundle.loadString('assets/openclaw/skills/productivity_skill.md');
      final skills = '$meetingSkill\n\n$researchSkill\n\n$productivitySkill';

      // 3. Fetch Cognitive Context
      final dna = CognitiveDNAService.getDNA();

      // 4. Fetch Data
      final events = await CalendarService.getUpcomingEvents();
      String meetingText = events.isEmpty ? "No meetings today." : 
          events.map((e) => "- ${e.title} at ${e.startTime}").join("\n");

      // 5. Construct Prompt
      final prompt = '''
$soul

$memory

$skills

$heartbeat

[USER IDENTITY & COGNITIVE CONTEXT]
Name: ${userName ?? "User"}
Role: ${userRole ?? "Researcher"}
Focus: ${userGoals ?? "Productivity"}
Skills: ${userSkills ?? "General"}
Preferred Tone: ${preferredTone ?? "Professional"}

[COGNITIVE DNA (LEARNED PATTERNS)]
Identity Tags: ${dna.identityTags.join(", ")}
Learned Insights: ${dna.productivityInsights.join(", ")}
Efficiency Level: ${(dna.cognitiveEfficiency * 100).toInt()}%

[CURRENT TASK: generateDailyBrief]
Generate a personalized daily brief. 
Reference their "Learned Patterns" (e.g. if they are a 'Night Owl', suggest later focus blocks).
Address the user by their EXACT name: ${userName ?? "User"}. DO NOT use nicknames or similar names (e.g. if name is Pavan S, use Pavan S, not Pavel).

### FORMATTING:
- Use professional Markdown.
- Tone: ${preferredTone ?? "Elite and Professional"}.

### GENERATE:
1. **Daily Productivity Insight**: A deep, actionable thought tailored to their DNA.
2. **Meeting Preparation Overview**: Summary of upcoming meetings.
3. **Optimized Focus suggestions**: Strategic advice based on current patterns.

Today's meetings:
$meetingText
''';

      final result = await OpenClawLLMService.generate(
        model: model,
        prompt: prompt,
      );

      final response = result['response'] ?? '';
      final usedModel = result['model'] ?? 'unknown';

      return "$response\n\n---\n*Active Neural Engine: ${usedModel.split('/').last}*";
    } catch (e) {
      return "AI agent failed: $e";
    }
  }

  static Future<String> analyzeBehavior({
    required List<Map<dynamic, dynamic>> logs,
    required String model,
    String? userName,
    String? preferredTone,
    String? userRole,
    String? userGoals,
  }) async {
    if (logs.isEmpty) return "Establishing baseline focus patterns...";

    try {
      final dna = CognitiveDNAService.getDNA();
      
      final prompt = '''
[USER COGNITIVE CONTEXT]
Name: ${userName ?? "User"}
Role: ${userRole ?? "Researcher"}
DNA Patterns: ${dna.identityTags.join(", ")}
Tone: ${preferredTone ?? "Professional"}

Analyze these user event logs and provide ONE short, insightful response. 
Speak directly to ${userName ?? "the user"} using their EXACT name: ${userName ?? "User"}. 
Reference their behavioral DNA if relevant (e.g. "Typical visual learner approach!").

Logs:
$logs
''';

      final result = await OpenClawLLMService.generate(
        model: model,
        prompt: prompt,
      );

      final response = result['response'] ?? '';
      final usedModel = result['model'] ?? 'unknown';

      return "$response\n\n---\n*Active Neural Engine: ${usedModel.split('/').last}*";
    } catch (e) {
      return "Analyzing productivity trends...";
    }
  }
}