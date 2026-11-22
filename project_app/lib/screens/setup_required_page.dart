import 'package:material_ui/material_ui.dart';

/// Экран, который показывается, если не удалось прочитать параметры Supabase.
class SetupRequiredPage extends StatelessWidget {
  const SetupRequiredPage({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Планировщик задач')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Supabase не настроен',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Приложение автоматически читает файл env/.env. '
                      'Скопируйте env/.env.example в env/.env и заполните '
                      'SUPABASE_URL и SUPABASE_KEY (или '
                      'SUPABASE_PUBLISHABLE_KEY).',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SelectableText(
                        'cd project_app\ncopy env\\.env.example env\\.env',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Можно и без файла — передать значения через '
                      '--dart-define. Они имеют приоритет над env/.env.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка инициализации:',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
