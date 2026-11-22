import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';

import '../models/task.dart';

class TaskRepository {
  TaskRepository(this._client);

  final SupabaseClient _client;

  static const String tableName = 'tasks';
  static const String _cacheKey = 'cached_tasks_v1';
  static const String _pendingKey = 'pending_tasks_queue_v1';

  /// 1. Мгновенно читает задачи из локальной памяти устройства (0.00 сек)
  Future<List<Task>> getCachedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheKey);
    final pendingJson = prefs.getString(_pendingKey);

    final List<Task> tasks = [];

    // Сначала добавляем задачи, которые еще ждут отправки в базу
    if (pendingJson != null) {
      final List<dynamic> pendingList = jsonDecode(pendingJson);
      tasks.addAll(pendingList.map((e) => Task.fromMap(e as Map<String, dynamic>)));
    }

    // Затем добавляем кэшированные задачи из базы
    if (cachedJson != null) {
      final List<dynamic> cachedList = jsonDecode(cachedJson);
      tasks.addAll(cachedList.map((e) => Task.fromMap(e as Map<String, dynamic>)));
    }

    return tasks;
  }

  /// 2. Синхронизирует очередь и скачивает свежие данные из Supabase
  Future<List<Task>> syncAndFetchTasks() async {
    // Сначала пытаемся отправить все задачи, которые застряли в очереди без интернета
    await _flushPendingQueue();

    // Затем забираем актуальный список из Supabase
    final rows = await _client
        .from(tableName)
        .select()
        .order('created_at', ascending: false);

    final tasks = rows.map(Task.fromMap).toList(growable: false);

    // Сохраняем свежий список в локальный кэш
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(rows));

    return tasks;
  }

  /// 3. Мгновенно сохраняет задачу локально и возвращает её на экран,
  /// а отправку в Supabase запускает в фоне без блокировки интерфейса.
  Future<Task> createTask({
    required String title,
    required String description,
    required String project,
  }) async {
    final payload = {
      'title': title.trim(),
      'description': description.trim(),
      'status': Task.defaultStatus,
      'project': project.trim(),
    };

    // Шаг А: Мгновенно пишем в локальную очередь (занимает < 5 миллисекунд)
    final prefs = await SharedPreferences.getInstance();
    final pendingRaw = prefs.getString(_pendingKey);
    final List<dynamic> pendingList =
        pendingRaw != null ? jsonDecode(pendingRaw) : [];

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final tempTaskMap = {
      ...payload,
      'id': tempId,
      'created_at': DateTime.now().toIso8601String(),
    };

    pendingList.insert(0, tempTaskMap);
    await prefs.setString(_pendingKey, jsonEncode(pendingList));

    // Шаг Б: Запускаем отправку в Supabase В ФОНЕ (обратите внимание — без await!)
    _sendTaskToCloud(payload, tempId);

    // Шаг В: Сразу отдаем задачу в UI, диалог закрывается мгновенно
    return Task.fromMap(tempTaskMap);
  }

  /// Фоновая отправка задачи в Supabase с обновлением кэша
  Future<void> _sendTaskToCloud(
    Map<String, dynamic> payload,
    int tempId,
  ) async {
    try {
      final savedRow = await _client
          .from(tableName)
          .insert(payload)
          .select()
          .single();

      final prefs = await SharedPreferences.getInstance();

      // Удаляем временную задачу из очереди ожидания
      final pendingRaw = prefs.getString(_pendingKey);
      if (pendingRaw != null) {
        final List<dynamic> pendingList = jsonDecode(pendingRaw);
        pendingList.removeWhere((item) => item['id'] == tempId);
        await prefs.setString(_pendingKey, jsonEncode(pendingList));
      }

      // Добавляем подтвержденную задачу из базы в основной кэш
      final cachedRaw = prefs.getString(_cacheKey);
      final List<dynamic> cachedList =
          cachedRaw != null ? jsonDecode(cachedRaw) : [];
      cachedList.insert(0, savedRow);
      await prefs.setString(_cacheKey, jsonEncode(cachedList));
    } catch (_) {
      // Если сеть сейчас недоступна или тормозит — ничего страшного.
      // Задача осталась в _pendingKey и гарантированно улетит при следующем _flushPendingQueue().
    }
  }

  /// Внутренний метод доотправки несинхронизированных задач
  Future<void> _flushPendingQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRaw = prefs.getString(_pendingKey);
    if (pendingRaw == null) return;

    final List<dynamic> pendingList = jsonDecode(pendingRaw);
    if (pendingList.isEmpty) return;

    final List<dynamic> remaining = [];
    for (final item in pendingList) {
      try {
        await _client.from(tableName).insert({
          'title': item['title'],
          'description': item['description'],
          'status': item['status'],
          'project': item['project'],
        });
      } catch (_) {
        // Если сети все еще нет — оставляем в очереди на следующий раз
        remaining.add(item);
      }
    }

    await prefs.setString(_pendingKey, jsonEncode(remaining));
  }
}
