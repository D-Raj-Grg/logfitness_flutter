import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme_mode_controller.dart';
import 'package:logfitness_flutter/features/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester tester, ThemeMode start) async {
  final container = ProviderContainer(
    overrides: [themeModeStartupProvider.overrideWithValue(start)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('offers all three modes', (WidgetTester tester) async {
    await _pump(tester, ThemeMode.light);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('choosing dark applies it', (WidgetTester tester) async {
    final container = await _pump(tester, ThemeMode.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('says what the choice actually means', (
    WidgetTester tester,
  ) async {
    await _pump(tester, ThemeMode.system);
    // "System" is the one that needs explaining, because it is the only mode
    // whose result depends on something outside the app.
    expect(find.textContaining("Follows this phone's setting"), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(find.textContaining('whatever the phone is set to'), findsOneWidget);
  });

  test('every mode has a label and an icon', () {
    for (final ThemeMode m in ThemeMode.values) {
      expect(themeModeLabel(m), isNotEmpty);
      expect(themeModeIcon(m), isNotNull);
    }
  });
}
