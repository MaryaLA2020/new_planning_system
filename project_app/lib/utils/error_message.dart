import 'package:supabase/supabase.dart';

/// Превращает техническую ошибку в понятное пользователю сообщение.
String describeError(Object error) {
  if (error is PostgrestException) {
    return 'Ошибка базы данных: ${error.message}';
  }

  final message = error.toString().trim();
  return message.isEmpty ? 'Неизвестная ошибка' : message;
}
