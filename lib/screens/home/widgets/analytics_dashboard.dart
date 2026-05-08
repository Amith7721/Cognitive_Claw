import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/research_provider.dart';
import '../../../services/cognitive_memory_service.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context);
    final research = Provider.of<ResearchProvider>(context);
    final habits = CognitiveMemoryService.getHabits();
    final patterns = CognitiveMemoryService.getPatterns();

    final completedCount = tasks.tasks.where((t) => t.completed).length;
    final timeSaved = completedCount * 15; // Assumption: 15 mins saved per AI task

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Icon(Icons.analytics_rounded, color: Color(0xFF6B4EE6), size: 32),
                const SizedBox(width: 12),
                Text(
                  "Productivity Analytics",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    "Time Saved",
                    "${timeSaved}m",
                    Icons.timer_rounded,
                    const Color(0xFFFE0979),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    "Efficiency",
                    "${(completedCount * 10).clamp(0, 100)}%",
                    Icons.bolt_rounded,
                    const Color(0xFF00F2FE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionHeader(context, "Performance Insights"),
            const SizedBox(height: 15),
            if (patterns.isEmpty && habits.isEmpty)
              _buildEmptyInsight(context)
            else ...[
              ...patterns.map((p) => _buildInsightItem(context, p, Icons.psychology_alt_outlined, Colors.blueAccent)),
              ...habits.map((h) => _buildInsightItem(context, h, Icons.check_circle_outline, Colors.greenAccent)),
            ],
            const SizedBox(height: 30),
            _buildSectionHeader(context, "Activity Trends"),
            const SizedBox(height: 15),
            _buildTrendChart(context, completedCount, research.history.length),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ).animate().slideX();
  }

  Widget _buildEmptyInsight(BuildContext context) {
    return Center(
      child: Text(
        "AI is still learning your patterns...",
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context, int tasks, int research) {
    return Container(
      height: 160, // Slightly more height
      padding: const EdgeInsets.all(16), // Less padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar(context, "Tasks", tasks, const Color(0xFFFE0979)),
          const SizedBox(width: 15),
          _buildBar(context, "Research", research, const Color(0xFF6B4EE6)),
          const SizedBox(width: 15),
          _buildBar(context, "Focus", 8, const Color(0xFF00F2FE)), 
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, int value, Color color) {
    final height = (value * 8).toDouble().clamp(10.0, 80.0);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10),
              ],
            ),
          ).animate().scaleY(begin: 0, duration: 1.seconds, curve: Curves.easeOutBack),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
