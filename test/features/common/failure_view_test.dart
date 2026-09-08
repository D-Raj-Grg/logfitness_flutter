// The regression test for the 2026-09-07 incident, ported to the app that
// inherited the risk: a `42501` refusal must be visible, must be visibly
// *different* from any other failure, and must carry the database's own
// sentence unedited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: appLightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

/// The fill the view actually painted, so "visually distinct" is asserted
/// against pixels rather than against the presence of a string.
Color? _fillOf(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byKey(failureViewKey),
      matching: find.byType(Container),
      matchRoot: true,
    ),
  );
  return (container.decoration as BoxDecoration?)?.color;
}

void main() {
  testWidgets('renders the failure message verbatim', (tester) async {
    // A sentence the database wrote. Not paraphrased, not truncated, not
    // wrapped in "Error:".
    const message = 'That visitor has already been registered as a member.';

    await _pump(
      tester,
      const FailureView(
        failure: AppFailure(FailureKind.invalid, message, code: '23514'),
      ),
    );

    expect(find.text(message), findsOneWidget);
  });

  testWidgets('a refusal is never rendered as a generic error', (tester) async {
    const refusal = AppFailure(
      FailureKind.refused,
      'The database refused that. It is outside the branches or the role you '
      'are assigned to.',
      code: '42501',
    );

    await _pump(tester, const FailureView(failure: refusal));

    // The distinct treatment: its own keyed headline, and the error
    // container rather than the neutral surface.
    expect(find.byKey(refusedFailureKey), findsOneWidget);
    expect(find.text('Refused'), findsOneWidget);
    expect(find.text(refusal.message), findsOneWidget);

    final refusedFill = _fillOf(tester);
    expect(refusedFill, appLightTheme.colorScheme.errorContainer);

    // And it is not what an ordinary failure gets.
    await _pump(
      tester,
      const FailureView(
        failure: AppFailure(FailureKind.unknown, 'Something went wrong.'),
      ),
    );
    expect(find.byKey(refusedFailureKey), findsNothing);
    expect(_fillOf(tester), isNot(refusedFill));
  });

  testWidgets('offline says plainly that nothing was saved', (tester) async {
    // PLANNING.md scope: there is no local write queue, so a write attempted
    // offline is simply gone. Saying "try again later" without saying that
    // would imply it was held.
    await _pump(
      tester,
      const FailureView(
        failure: AppFailure(
          FailureKind.offline,
          'No connection, so nothing was saved. Check the network and try '
          'again.',
        ),
      ),
    );

    expect(find.textContaining('nothing was saved'), findsNWidgets(2));
  });

  testWidgets('the retry affordance appears only when there is one', (
    tester,
  ) async {
    var retries = 0;

    await _pump(
      tester,
      const FailureView(failure: AppFailure(FailureKind.unknown, 'No.')),
    );
    expect(find.byKey(failureRetryKey), findsNothing);

    await _pump(
      tester,
      FailureView(
        failure: const AppFailure(FailureKind.unknown, 'No.'),
        onRetry: () => retries++,
      ),
    );
    await tester.tap(find.byKey(failureRetryKey));
    expect(retries, 1);
  });

  group('AsyncValueView', () {
    testWidgets('maps a raw thrown error through the failure mapper', (
      tester,
    ) async {
      // A screen that reached this with an unmapped object still gets a
      // sentence, not a Dart toString().
      await _pump(
        tester,
        AsyncValueView<int>(
          value: AsyncValue<int>.error(
            const AppFailure(FailureKind.refused, 'Refused by policy.'),
            StackTrace.empty,
          ),
          data: (int value) => Text('$value'),
        ),
      );

      expect(find.byKey(refusedFailureKey), findsOneWidget);
      expect(find.text('Refused by policy.'), findsOneWidget);
    });

    testWidgets('empty is a state of its own, not a failure', (tester) async {
      await _pump(
        tester,
        AsyncValueView<List<String>>(
          value: const AsyncValue<List<String>>.data(<String>[]),
          isEmpty: (List<String> rows) => rows.isEmpty,
          emptyMessage: 'No visitors logged today.',
          data: (List<String> rows) => Text('${rows.length}'),
        ),
      );

      expect(find.byKey(asyncEmptyKey), findsOneWidget);
      expect(find.byKey(failureViewKey), findsNothing);
      expect(find.text('No visitors logged today.'), findsOneWidget);
    });

    testWidgets('loading is a spinner, never a blank screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: appLightTheme,
          home: Scaffold(
            body: AsyncValueView<int>(
              value: const AsyncValue<int>.loading(),
              data: (int value) => Text('$value'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(asyncLoadingKey), findsOneWidget);
    });
  });

  group('showFailureSnackBar', () {
    testWidgets('shows the message verbatim for an action failure', (
      tester,
    ) async {
      const failure = AppFailure(
        FailureKind.refused,
        'Only a manager can refund a payment.',
        code: '42501',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: appLightTheme,
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => FilledButton(
                onPressed: () => showFailureSnackBar(context, failure),
                child: const Text('Refund'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Refund'));
      await tester.pumpAndSettle();

      expect(find.text(failure.message), findsOneWidget);
    });
  });
}
