import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:logfitness_flutter/app/startup_failure_app.dart';
import 'package:logfitness_flutter/app/theme.dart';

void main() {
  group('StartupFailureApp', () {
    testWidgets('names the failure instead of showing a blank screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        const StartupFailureApp(error: 'Supabase is not configured.'),
      );

      expect(find.text("Gym Tross couldn't start"), findsOneWidget);
      expect(find.text('Supabase is not configured.'), findsOneWidget);
    });

    testWidgets('renders the message selectably so it can be copied out', (
      tester,
    ) async {
      await tester.pumpWidget(const StartupFailureApp(error: 'boom'));

      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('reads the app theme, not Flutter\'s fallback, in the dark', (
      tester,
    ) async {
      // The regression this guards: the body was built with this widget's own
      // context, which sits *above* the `MaterialApp`, so `Theme.of` returned
      // Flutter's fallback light defaults while the `Scaffold` painted the
      // app's dark background. Dark grey on near-black, on the one screen
      // whose entire job is to be legible to somebody who cannot open the app.
      //
      // The styles are read off the widgets rather than off a context found by
      // the finder: any element under the `MaterialApp` resolves the right
      // theme, so a `Theme.of` assertion passes either way. What went wrong is
      // the colour baked into the widget at build time.
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(const StartupFailureApp(error: 'boom'));

      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, appDarkTheme.colorScheme.error);
      expect(icon.color, isNot(ThemeData().colorScheme.error));

      final Text heading = tester.widget<Text>(
        find.text("Gym Tross couldn't start"),
      );
      expect(heading.style?.color, appDarkTheme.textTheme.titleLarge?.color);
    });
  });
}
