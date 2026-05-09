import 'dart:async';
import 'package:flutter/foundation.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import '../services/heartbeat_service.dart';
import '../services/cognitive_memory_service.dart';
import '../services/openclaw_agent_service.dart';
import '../providers/research_provider.dart';
import '../core/constants/app_constants.dart';

class HeartbeatAutonomousEngine {
  static Timer? _timer;
  static bool _isRunning = false;

  static void start(TaskProvider tasks, ResearchProvider research) {
    if (_isRunning) return;
    _isRunning = true;

    // Run every 60 seconds (simulating a background daemon)
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      debugPrint('💓 Heartbeat Autonomous Engine: Orchestrating state...');
      
      // 1. Update Heartbeat.md (Context Aggregator)
      await HeartbeatService.updateHeartbeat(tasks, research);

      // 2. Check for "Stale Tasks" and send nudges
      final pendingTasks = tasks.tasks.where((t) => !t.completed).toList();
      if (pendingTasks.isNotEmpty) {
        final staleTask = pendingTasks.first;
        // Simple heuristic: nudge if task exists
        NotificationService.sendTaskNudge(
          title: staleTask.title,
          nudge: "AI suggests focusing on this task now to maintain momentum.",
          id: staleTask.hashCode,
        );
      }

      // 3. Update Cognitive Memory (Layer 4: Persistent Memory)
      final completedTasks = tasks.tasks.where((t) => t.completed).length;
      await CognitiveMemoryService.analyzeBehavior(completedTasks, research.history.length);
      
      // 4. Perform AI Deep Analysis of logs
      final logs = CognitiveMemoryService.getRawLogs();
      if (logs.length > 5) { // Only analyze if we have enough data
         final aiInsight = await OpenClawAgentService.analyzeBehavior(
           logs: logs,
           model: AppConstants.defaultModel, 
         );
         await CognitiveMemoryService.saveAIInsight(aiInsight);
      }

      // 5. Productivity Analysis (Internal log)
      debugPrint('📊 AI Insight: Productivity alignment is at ${(pendingTasks.length < 3 ? "Peak" : "Nominal")}');
    });
  }

  static void stop() {
    _timer?.cancel();
    _isRunning = false;
  }
}
