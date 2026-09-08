// One rendering of an `AsyncValue` for the whole app, so that loading, empty
// and — the case this exists for — failed all look the same wherever they
// happen, and so no screen has to remember to handle the third one.
//
// A screen that writes its own `.when(error: (e, _) => Text('$e'))` throws
// away everything `AppFailure` knows: it loses the refusal treatment, prints
// a Dart exception at a person behind a counter, and offers no way back.
// Prefer this widget; see `failure_view.dart` for the 2026-09-07 incident
// that made it non-negotiable.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';

const Key asyncLoadingKey = Key('async-loading');
const Key asyncEmptyKey = Key('async-empty');

/// The centred spinner every screen uses while a read is in flight.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    key: asyncLoadingKey,
    padding: EdgeInsets.all(Brand.spaceXl),
    child: Center(child: CircularProgressIndicator()),
  );
}

/// "There is nothing here" — a successful read that returned no rows.
///
/// Distinct from a failure on purpose: an empty visitor log and a refused
/// query look identical from the outside, and conflating them is exactly the
/// mistake `AppFailure` exists to prevent.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      key: asyncEmptyKey,
      padding: const EdgeInsets.all(Brand.spaceXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: Brand.spaceMd),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: Brand.spaceMd),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Renders [value]'s three states: [LoadingView], [FailureView], or [data].
///
/// [onRetry] is normally `() => ref.invalidate(theProvider)`.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.onRetry,
    this.isEmpty,
    this.emptyMessage = 'Nothing here yet.',
    this.emptyAction,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;

  /// Wired to the retry button on [FailureView]. Omit and no retry is
  /// offered.
  final VoidCallback? onRetry;

  /// Says whether a successfully loaded [T] should render as empty. Omit for
  /// a value that is never "empty" (a single row, a count).
  final bool Function(T value)? isEmpty;

  final String emptyMessage;
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: false,
      loading: () => const LoadingView(),
      // Every error goes through the mapper, whatever was thrown, so an
      // unmapped `PostgrestException` still arrives carrying the database's
      // own words instead of a Dart `toString()`.
      error: (Object error, StackTrace stackTrace) =>
          FailureView(failure: mapError(error, stackTrace), onRetry: onRetry),
      data: (T loaded) {
        if (isEmpty != null && isEmpty!(loaded)) {
          return EmptyView(message: emptyMessage, action: emptyAction);
        }
        return data(loaded);
      },
    );
  }
}
