import '../../services/openclaw_llm_service.dart';

enum VisionMode {
  general,
  notes,
  timetable,
  research,
  chart,
}

class VisionAgentService {
  static Future<String> analyzeText(String text, {VisionMode mode = VisionMode.general, String model = 'auto'}) async {
    String systemInstruction = "";
    
    switch (mode) {
      case VisionMode.notes:
        systemInstruction = "You are a Master Note Taker. Convert the following handwritten notes into structured, professional 'Smart Notes'. Use headers (##), bold text, and bullet points. DO NOT use raw # or * as decorators.";
        break;
      case VisionMode.timetable:
        systemInstruction = "You are a Schedule Architect. Extract events/classes from this timetable. Use a professional Markdown TABLE with columns: | Time | Subject | Location | Description |. Ensure proper table syntax.";
        break;
      case VisionMode.research:
        systemInstruction = "You are a Research Specialist. Simplify this complex technical screenshot into a 'Plain English' explanation. Use bold text for key terms and headers for sections. Provide a 'Key Takeaways' list.";
        break;
      case VisionMode.chart:
        systemInstruction = "You are a Data Analyst. Extract data points and provide deep strategic AI insights. Use Markdown TABLES to represent numerical data and bullet points for insights.";
        break;
      default:
        systemInstruction = "You are Claw-Vision Synapse. Analyze the extracted image text for general meaning, providing a summary and key points in a professional Markdown format.";
    }

    final prompt = '''
$systemInstruction

### EXTRACTED TEXT:
$text

### FORMATTING RULES:
- Use standard Markdown only.
- Prefer tables for data and comparative info.
- Keep it elite, professional, and concise.
- Ensure the output is ready for a professional Markdown renderer.
''';

    final result = await OpenClawLLMService.generate(
      prompt: prompt,
      model: model,
    );

    final response = result['response'] ?? '';
    final usedModel = result['model'] ?? 'unknown';

    return "$response\n\n---\n*Synapse Orchestration: ${usedModel.split('/').last}*";
  }
}