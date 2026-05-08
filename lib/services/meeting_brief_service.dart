import '../models/meeting_brief.dart';
import '../models/calendar_event.dart';
import 'openclaw_llm_service.dart';

class MeetingBriefService {
  static Future<List<MeetingBrief>> getInitialBriefs(
    List<CalendarEvent> events,
  ) async {
    // Return empty skeletons first to make it fast
    return events.map((e) => MeetingBrief(
      title: e.title, 
      summary: "", // Empty for now
      time: "${e.startTime.hour}:${e.startTime.minute.toString().padLeft(2, '0')}",
    )).toList();
  }

  static Future<String> generateSingleBrief(
    String title,
    String model,
  ) async {
    final prompt = """
You are the Cognitive Claw AI Assistant. Generate a professional, highly structured meeting preparation brief for: $title.

### FORMATTING REQUIREMENTS:
1. Use ONLY standard Markdown.
2. If there are multiple agenda items, use a Markdown TABLE with columns: | Time | Item | Presenter |.
3. Use **bold** for emphasis, never use raw symbols like # or * as decorators.
4. Use properly nested headers (## for sections).
5. Ensure the response is clean and ready for a Markdown renderer.

### CONTENT:
- **Brief Overview**: A 2-sentence summary of the meeting's purpose.
- **Agenda**: A structured table or list.
- **Key Preparation Tips**: Actionable items for the user.
- **Strategic Discussion Points**: Potential questions to ask.

Keep it professional, elite, and actionable.
""";

    return await OpenClawLLMService.generate(
      prompt: prompt,
      model: model,
    );
  }
}
