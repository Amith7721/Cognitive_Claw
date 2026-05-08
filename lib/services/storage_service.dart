import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_theme.dart';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<int> getQuietStart() async {
    return 22;
  }

  static Future<int> getQuietEnd() async {
    return 7;
  }

  static Future<int> getDailyCap() async {
    return 5;
  }

  static Future<String?> getTodoistKey() async {
    return await _storage.read(key: 'todoist_key');
  }

  static Future<void> saveTodoistKey(String key) async {
    await _storage.write(key: 'todoist_key', value: key);
  }
}
