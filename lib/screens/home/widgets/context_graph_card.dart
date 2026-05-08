import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/research_provider.dart';

class ContextGraphCard extends StatelessWidget {
  const ContextGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final researchProvider = Provider.of<ResearchProvider>(context);

    // Calculate dynamic scores
    final tasks = taskProvider.tasks;
    final completedTasks = tasks.where((t) => t.completed).length;
    final taskScore = tasks.isEmpty ? 0.0 : (completedTasks / tasks.length);
    
    final researchScore = (researchProvider.history.length / 5.0).clamp(0.0, 1.0);
    
    // Total alignment score (weighted: 70% Tasks, 30% Research)
    final totalAlignment = ((taskScore * 0.7) + (researchScore * 0.3)).clamp(0.1, 1.0);
    final percentage = (totalAlignment * 100).toInt();

    String insightText = "Analyzing your workflow...";
    if (percentage > 80) {
      insightText = "Peak productivity reached!";
    } else if (percentage > 50) {
      insightText = "Steady progress detected.";
    } else if (tasks.isEmpty && researchProvider.history.isEmpty) {
      insightText = "Awaiting more context to optimize.";
    } else {
      insightText = "Focus on completing pending tasks.";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4EE6).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFF6B4EE6)),
              const SizedBox(width: 10),
              Text(
                'Context Awareness',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: const TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalAlignment, 
              minHeight: 8,
              backgroundColor: Colors.black12,
              color: const Color(0xFF00F2FE),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            insightText,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
