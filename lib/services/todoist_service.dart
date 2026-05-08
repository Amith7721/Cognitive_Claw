// Todoist REST API integration
import 'package:dio/dio.dart';
import '../models/task_item.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/decay_calculator.dart';
import 'storage_service.dart';
import '../core/theme/app_theme.dart';

class TodoistService {
  static final _dio = Dio(BaseOptions(baseUrl: AppConstants.todoistBaseUrl));

  static Future<List<TaskItem>> getStaleTasks() async {
    final key = await StorageService.getTodoistKey();
    if (key == null || key.isEmpty) return [];

    try {
      final response = await _dio.get(
        '/tasks',
        options: Options(headers: {'Authorization': 'Bearer $key'}),
      );

      final tasks = response.data as List;
      final now = DateTime.now();
      final results = <TaskItem>[];

      for (final t in tasks) {
        final updatedStr = t['updated_at'] as String? ?? '';
        final updated = updatedStr.isNotEmpty
            ? DateTime.parse(updatedStr)
            : now;

        // Only return stale tasks
        if (now.difference(updated).inDays < AppConstants.staleTaskDays) {
          continue;
        }

        results.add(
          TaskItem(
            id: t['id'].toString(),
            title: t['content'] ?? 'Untitled Task',
            description: 'Imported from Todoist',
            priority: 'Medium',
            completed: false,
            createdAt: updated,
          ),
        );
      }

      // Sort by decay score highest first

      return results.take(10).toList();
    } catch (e) {
      print('Todoist error: $e');
      return [];
    }
  }
}
