import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/task.dart';
import '../services/task_repository.dart';
import '../utils/error_message.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_card.dart';

/// Главный экран со списком задач и кнопкой добавления.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Task> _tasks = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks({bool showSpinner = true}) async {
    // 1. Сначала мгновенно показываем задачи из локального кэша (0.00 сек)
    final cached = await widget.repository.getCachedTasks();
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _tasks = cached;
        _isLoading = false;
      });
    } else if (showSpinner && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    // 2. В фоне синхронизируем очередь и забираем свежие данные из Supabase
    try {
      final freshTasks = await widget.repository.syncAndFetchTasks();
      if (!mounted) return;
      setState(() {
        _tasks = freshTasks;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      // Показываем экран ошибки ТОЛЬКО если даже в локальном кэше пусто
      setState(() {
        _isLoading = false;
        if (_tasks.isEmpty) {
          _error = describeError(error);
        }
      });
    }
  }

  Future<void> _openAddTaskDialog() async {
    // Ожидаем объект Task вместо bool
    final newTask = await showDialog<Task>(
      context: context,
      builder: (dialogContext) => AddTaskDialog(
        repository: widget.repository,
      ),
    );

    if (newTask == null || !mounted) return;

    // Мгновенно добавляем задачу в начало списка на экране!
    setState(() {
      _tasks = [newTask, ..._tasks];
      _error = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Задача сохранена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои задачи'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadTasks,
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Добавить задачу'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        title: 'Не удалось загрузить задачи',
        message: _error!,
        actionLabel: 'Повторить',
        onAction: _loadTasks,
      );
    }

    if (_tasks.isEmpty) {
      return const _MessageState(
        icon: Icons.task_alt,
        title: 'Пока нет задач',
        message: 'Нажмите «Добавить задачу», чтобы создать первую.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = math.max(
          16.0,
          (constraints.maxWidth - 900) / 2,
        );

        return RefreshIndicator(
          onRefresh: () => _loadTasks(showSpinner: false),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              96,
            ),
            itemCount: _tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => TaskCard(task: _tasks[index]),
          ),
        );
      },
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel ?? 'Повторить'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
