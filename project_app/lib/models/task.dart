/// Задача из таблицы `tasks` в Supabase.
class Task {
  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.project,
  });

  /// Статус, который получает каждая новая задача.
  static const String defaultStatus = 'Не начато';

  final Object? id;
  final String title;
  final String description;
  final String status;
  final String project;

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: (map['title'] as String?)?.trim() ?? '',
      description: (map['description'] as String?)?.trim() ?? '',
      status: (map['status'] as String?)?.trim().isNotEmpty == true
          ? (map['status'] as String).trim()
          : defaultStatus,
      project: (map['project'] as String?)?.trim() ?? '',
    );
  }
}
