// A failure that happened *because of an action* — a payment that would not
// record, a freeze the database refused — belongs next to the button that
// was pressed, not in place of the screen. [FailureView] is for a screen that
// has no content to show; this is for a screen that still does.
//
// Same rule as everywhere else: the message is shown as written, and a
// refusal is visually distinct. See `failure_view.dart` for why.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/domain/errors/app_failure.dart';

/// Shows [failure] as a snackbar over [context]'s [ScaffoldMessenger].
///
/// Pass [onRetry] for an action worth repeating. Do not pass it for a
/// [FailureKind.refused] — repeating it produces the same refusal, and
/// offering the retry implies the desk did something wrong rather than that
/// the role or branch assignment is the problem.
void showFailureSnackBar(
  BuildContext context,
  AppFailure failure, {
  VoidCallback? onRetry,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final refused = failure.isRefusal;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        // A refusal and an offline write both mean nothing was saved, so both
        // stay on screen long enough to be read rather than glimpsed.
        duration: refused || failure.kind == FailureKind.offline
            ? const Duration(seconds: 8)
            : const Duration(seconds: 4),
        backgroundColor: refused
            ? colorScheme.errorContainer
            : colorScheme.inverseSurface,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              refused ? Icons.block : Icons.error_outline,
              color: refused
                  ? colorScheme.onErrorContainer
                  : colorScheme.onInverseSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                // Verbatim, as everywhere.
                failure.message,
                style: TextStyle(
                  color: refused
                      ? colorScheme.onErrorContainer
                      : colorScheme.onInverseSurface,
                ),
              ),
            ),
          ],
        ),
        action: onRetry == null
            ? null
            : SnackBarAction(
                label: 'Retry',
                textColor: refused
                    ? colorScheme.onErrorContainer
                    : colorScheme.inversePrimary,
                onPressed: onRetry,
              ),
      ),
    );
}

/// Maps [error] through [mapError] before showing it, for call sites holding
/// a raw thrown object rather than an [AppFailure] — an `AsyncValue.error`
/// out of a controller, most often.
void showErrorSnackBar(
  BuildContext context,
  Object error, {
  StackTrace? stackTrace,
  VoidCallback? onRetry,
}) =>
    showFailureSnackBar(context, mapError(error, stackTrace), onRetry: onRetry);
