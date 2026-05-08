import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../providers/task_provider.dart';
import '../providers/research_provider.dart';

class HeartbeatService {
  static Future<void> updateHeartbeat(TaskProvider tasks, ResearchProvider research) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/HEARTBEAT.md');

      final activeTasks = tasks.tasks.where((t) => !t.completed).length;
      final completedTasks = tasks.tasks.where((t) => t.completed).length;
      final researchCount = research.history.length;

      final content = '''
# Cognitive Claw Heartbeat
Generated: ${DateTime.now().toIso8601String()}

## Current Context Graph
- **Active Tasks:** $activeTasks
- **Completed Tasks:** $completedTasks
- **Research Papers Engaged:** $researchCount
- **Sync Status:** Local-first (0ms cloud latency)

## Memory Footprint
- **Adaptive State:** ${activeTasks > 5 ? 'High Load' : 'Optimized'}
- **Next Probable State:** ${activeTasks > 0 ? 'Task Execution' : 'Knowledge Discovery'}

## Agentic Controller Status
- **Active SKILLS:** OCR, ArXiv-Search, Calendar-Sync, LLM-Reasoning
''';

      await file.writeAsString(content);
    } catch (e) {
      print('Heartbeat error: $e');
    }
  }
}
