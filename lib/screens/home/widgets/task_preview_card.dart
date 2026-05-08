import 'package:flutter/material.dart';
import '../../../models/task_item.dart';

class TaskPreviewCard extends StatelessWidget {
  final TaskItem task;

  const TaskPreviewCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            task.completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.completed ? Colors.greenAccent : const Color(0xFF00F2FE),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.priority,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
