# new_planning_system

The goals of the planning system are:
* To help achieve set goals faster without forcing oneself;
* To help incorporate beneficial habits into one’s life and combat harmful ones;
* To bring order to the chaos of endless tasks.

## Flutter-приложение

Код приложения находится в [`project_app`](project_app). Оно работает с таблицей
`tasks` в Supabase и умеет:

* показывать список задач из базы;
* добавлять новую задачу с названием, описанием и проектом;
* автоматически проставлять новой задаче статус `Не начато`.

Один и тот же код используется на web, desktop и мобильных платформах.
Для работы с базой используется чистый Dart-пакет `supabase`, без
платформенных плагинов.

### Настройка Supabase

Приложение автоматически читает параметры подключения из файла
`project_app/env/.env` при запуске — на web, desktop и мобильных платформах.
Достаточно один раз создать этот файл:

```bash
cd project_app

# Windows
copy env\.env.example env\.env

# macOS / Linux
cp env/.env.example env/.env
```

Затем заполните в `env/.env`:

```dotenv
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_KEY=<publishable key>
```

Поддерживается и имя `SUPABASE_PUBLISHABLE_KEY` — как в
`research/add_new_table.ipynb`.

Если у вас уже есть `.env` в корне проекта, его можно просто скопировать:

```bash
# из корня проекта
copy .env project_app\env\.env
```

Файл `env/.env` не попадает в git и содержит только публикуемый ключ.
Если файла нет, приложение покажет экран с инструкцией по настройке.

Значения можно передать и через `--dart-define` — они имеют приоритет
над `env/.env`:

```bash
flutter run --dart-define=SUPABASE_URL=https://<project>.supabase.co --dart-define=SUPABASE_KEY=<publishable key>
```

Для сборки web-версии:

```bash
flutter build web
```

Для Android, iOS, Windows, macOS и Linux:

```bash
flutter build <platform>
```

### Структура

* [`project_app/env/.env.example`](project_app/env/.env.example) — шаблон env-файла;
* [`project_app/lib/config/supabase_config.dart`](project_app/lib/config/supabase_config.dart) — загрузка `env/.env` и переопределения из `--dart-define`;
* [`project_app/lib/models/task.dart`](project_app/lib/models/task.dart) — модель задачи и статус по умолчанию;
* [`project_app/lib/services/task_repository.dart`](project_app/lib/services/task_repository.dart) — чтение и вставка задач в таблицу `tasks`;
* [`project_app/lib/screens/tasks_page.dart`](project_app/lib/screens/tasks_page.dart) — список задач;
* [`project_app/lib/widgets/add_task_dialog.dart`](project_app/lib/widgets/add_task_dialog.dart) — форма добавления задачи.

### Проверка

```bash
cd project_app
flutter analyze
flutter test
```
