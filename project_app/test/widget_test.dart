import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:project_app/main.dart';

void main() {
  testWidgets('показывает инструкцию, если Supabase не настроен', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlanningApp());

    expect(find.text('Supabase не настроен'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
