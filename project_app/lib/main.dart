import 'package:material_ui/material_ui.dart';
import 'package:supabase/supabase.dart';

import 'config/supabase_config.dart';
import 'screens/setup_required_page.dart';
import 'screens/tasks_page.dart';
import 'services/ipv4_http_client.dart'; // <-- Импортируем наш клиент
import 'services/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.load();

  SupabaseClient? client;
  String? startupError;

  if (SupabaseConfig.isConfigured) {
    try {
      client = SupabaseClient(
        SupabaseConfig.url,
        SupabaseConfig.anonKey,
        httpClient: createFastHttpClient(), // <-- Подключаем принудительный IPv4
      );
    } catch (error) {
      startupError = error.toString();
    }
  }

  runApp(PlanningApp(client: client, startupError: startupError));
}

class PlanningApp extends StatelessWidget {
  const PlanningApp({super.key, this.client, this.startupError});

  final SupabaseClient? client;
  final String? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Планировщик задач',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      ),
      home: client == null
          ? SetupRequiredPage(errorMessage: startupError)
          : TasksPage(repository: TaskRepository(client!)),
    );
  }
}
