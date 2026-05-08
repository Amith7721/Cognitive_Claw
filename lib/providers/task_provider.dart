import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../core/theme/app_theme.dart';
import '../services/cognitive_memory_service.dart';
import '../services/cognitive_dna_service.dart';
import 'package:hive/hive.dart';

class TaskProvider extends ChangeNotifier {
  final List<TaskItem> _tasks = [];
  final _box = Hive.box('tasks');

  List<TaskItem> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks.clear();
    final data = _box.values.map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e))).toList();
    _tasks.addAll(data);
    notifyListeners();
  }

  Future<void> addTask(TaskItem task) async {
    _tasks.add(task);
    await _box.put(task.id, task.toJson());
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final updated = _tasks[index].copyWith(completed: !_tasks[index].completed);
    _tasks[index] = updated;
    await _box.put(id, updated.toJson());
    
    if (updated.completed) {
      CognitiveMemoryService.logEvent('task_completed');
      CognitiveDNAService.logActivity('task_completion', 'Completed: ${updated.title}');
    }
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _box.delete(id);
    notifyListeners();
  }
}
