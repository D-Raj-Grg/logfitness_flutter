import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:logfitness_flutter/app/startup_failure_app.dart';

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
  });
}
