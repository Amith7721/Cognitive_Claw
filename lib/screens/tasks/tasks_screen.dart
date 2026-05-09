import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/openclaw_llm_service.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import '../../widgets/ai_loading_widget.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'widgets/ai_nudge_bubble.dart';
import 'widgets/task_decay_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool loading = false;
  String? latestAdvice;
  DateTime selectedDate = DateTime.now();

  Color getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return const Color(0xFFFE0979);
      case "Medium":
        return const Color(0xFF6B4EE6);
      default:
        return const Color(0xFF00F2FE);
    }
  }

  Future<void> askAI(TaskItem task) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    showAILoadingDialog(context, settings.modelName);

    try {
      final result = await OpenClawLLMService.generate(
        prompt: """
You are an AI productivity assistant.

Task: ${task.title}
Priority: ${task.priority}

Give:
1. Short productivity advice
2. Task breakdown
3. Estimated completion time
4. Motivation tip
""",
        model: settings.selectedModel,
      );

      if (!mounted) return;
      
      final response = result['response'] ?? "";
      final usedModel = result['model'] ?? "unknown";

      setState(() {
        latestAdvice = response.isEmpty ? null : "$response\n\n---\n*Orchestrated by: $usedModel*";
      });
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: const Color(0xFF00F2FE).withValues(alpha: 0.3)),
          ),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF00F2FE)),
              SizedBox(width: 10),
              Text(
                "AI Assistant",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: MarkdownBody(
              data: response.isEmpty ? "No AI response" : "$response\n\n---\n*Orchestrated by: $usedModel*",
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6, fontSize: 16),
                h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                tableBorder: TableBorder.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.3), width: 1),
                tableBody: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                tableHead: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00F2FE)),
                tableCellsPadding: const EdgeInsets.all(10),
                listBullet: const TextStyle(color: Color(0xFF00F2FE), fontSize: 18),
                blockquoteDecoration: BoxDecoration(
                  color: const Color(0xFF6B4EE6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(left: BorderSide(color: Color(0xFF00F2FE), width: 4)),
                ),
                blockquote: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Got it",
                style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      debugPrint(e.toString());
    }
  }

  void addTask() {
    final titleController = TextEditingController();
    String selectedPriority = "Medium";
    final List<String> priorities = ["High", "Medium", "Low"];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: const Color(0xFF6B4EE6).withValues(alpha: 0.5)),
          ),
          title: Text("Add Task", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: "Enter task name",
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.black12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: "Priority",
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.black12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setStateDialog(() => selectedPriority = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final newTask = TaskItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: "",
                  priority: selectedPriority,
                  completed: false,
                  createdAt: selectedDate, 
                );
                Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4EE6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    final now = DateTime.now();
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 45, // Show 15 past, today, and 29 future days
        controller: ScrollController(initialScrollOffset: 15 * 78.0), // Approximate center
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index - 15));
          final isSelected = isSameDay(date, selectedDate);
          final isToday = isSameDay(date, now);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 70,
                  height: 85,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6B4EE6) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : (isToday ? const Color(0xFF00F2FE) : Colors.grey.withValues(alpha: 0.1)),
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: const Color(0xFF6B4EE6).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F2FE).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "TODAY",
                      style: TextStyle(color: Color(0xFF00F2FE), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget buildTaskCard(TaskItem task, int index, TaskProvider provider) {
    return GestureDetector(
      onTap: () => askAI(task),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardColor,
          border: Border.all(color: getPriorityColor(task.priority).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: getPriorityColor(task.priority).withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.completed,
              activeColor: Colors.greenAccent,
              checkColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: BorderSide(color: getPriorityColor(task.priority), width: 2),
              onChanged: (value) => provider.toggleTask(task.id),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: task.completed ? (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54) : Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: getPriorityColor(task.priority).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: getPriorityColor(task.priority).withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          task.priority,
                          style: TextStyle(color: getPriorityColor(task.priority), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withValues(alpha: 0.7)),
              onPressed: () => provider.deleteTask(task.id),
            ),
          ],
        ),
      ).animate().slideX(begin: 0.1, delay: Duration(milliseconds: 100 * index)).fadeIn(),
    );
  }

  Widget buildStats(List<TaskItem> tasks) {
    final completed = tasks.where((e) => e.completed).length;
    final pending = tasks.length - completed;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4EE6), Color(0xFFFE0979)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE0979).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text("$completed", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Completed", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
          Container(width: 2, height: 40, color: Colors.white.withValues(alpha: 0.3)),
          Column(
            children: [
              Text("$pending", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Pending", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
        ],
      ),
    ).animate().slideY(begin: -0.1, duration: 500.ms).fadeIn();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final filteredTasks = provider.tasks.where((task) => isSameDay(task.createdAt, selectedDate)).toList();
    final sortedTasks = [...filteredTasks]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: const Text("Neural Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00F2FE),
        onPressed: addTask,
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
      body: Column(
        children: [
          _buildHorizontalCalendar(),
          Expanded(
            child: sortedTasks.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: sortedTasks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          buildStats(sortedTasks),
                          if (latestAdvice != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: AINudgeBubble(text: latestAdvice!).animate().fadeIn().slideY(begin: -0.1),
                            ),
                        ],
                      );
                    }
                    final task = sortedTasks[index - 1];
                    if (task.priority == 'High' && !task.completed) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () => askAI(task),
                              child: TaskDecayCard(title: task.title).animate().slideX(begin: 0.1, delay: Duration(milliseconds: 100 * (index - 1))).fadeIn(),
                            ),
                          ),
                          buildTaskCard(task, index - 1, provider),
                        ],
                      );
                    }
                    return buildTaskCard(task, index - 1, provider);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          const Text(
            "No tasks for this day",
            style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            "Tap + to add a new cognitive task",
            style: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
