import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Настройки подключения к Supabase.
///
/// По умолчанию приложение автоматически читает файл `env/.env`
/// (он включён в assets и работает одинаково на web, desktop и мобильных
/// платформах).
///
/// Значения, переданные через `--dart-define`, имеют приоритет:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://<project>.supabase.co \
///   --dart-define=SUPABASE_KEY=<publishable key>
/// ```
class SupabaseConfig {
  const SupabaseConfig._();

  /// Путь к env-файлу внутри assets.
  static const String envFileName = 'env/.env';

  static const String _definedUrl = String.fromEnvironment('SUPABASE_URL');

  /// Поддерживаются оба имени переменной:
  /// * `SUPABASE_KEY` — как в `.env.example`;
  /// * `SUPABASE_PUBLISHABLE_KEY` — как в `research/add_new_table.ipynb`.
  static const String _definedKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  static String _url = '';
  static String _anonKey = '';

  static String get url => _url;
  static String get anonKey => _anonKey;

  static bool get isConfigured =>
      _url.trim().isNotEmpty && _anonKey.trim().isNotEmpty;

  /// Загружает значения из `env/.env` и применяет переопределения
  /// из `--dart-define`.
  static Future<void> load() async {
    var envUrl = '';
    var envKey = '';

    try {
      await dotenv.load(fileName: envFileName);
      envUrl = dotenv.maybeGet('SUPABASE_URL') ?? '';
      envKey =
          dotenv.maybeGet('SUPABASE_KEY') ??
          dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY') ??
          '';
    } catch (_) {
      // Файла env/.env может не быть — тогда работают только --dart-define.
    }

    _url = _definedUrl.trim().isNotEmpty ? _definedUrl.trim() : envUrl.trim();
    _anonKey = _definedKey.trim().isNotEmpty
        ? _definedKey.trim()
        : envKey.trim();
  }
}
