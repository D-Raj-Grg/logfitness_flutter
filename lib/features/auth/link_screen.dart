import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/app/router.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/auth/auth_error_text.dart';

/// Shown when a session is authenticated but carries no claims yet -- the
/// principal row (member or staff) has not been linked to this auth user.
/// A normal, stable state (PLANNING.md §5), not an error.
///
/// Tries [AuthController.linkPrincipal] exactly once automatically, on
/// first open -- an invited member who already has a pending invitation
/// should not have to tap anything. After that one attempt, it waits: it
/// never loops on its own, because [LinkFailure.noInvitation] and
/// [LinkFailure.ambiguousInvitation] are states that a second automatic
/// attempt cannot fix, and hammering the RPC would only look broken.
class LinkScreen extends ConsumerStatefulWidget {
  const LinkScreen({super.key});

  @override
  ConsumerState<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends ConsumerState<LinkScreen> {
  bool _autoAttempted = false;
  bool _sentToLogin = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _attempt());
  }

  void _attempt() {
    if (_autoAttempted) return;
    _autoAttempted = true;
    ref.read(authControllerProvider.notifier).linkPrincipal();
  }

  void _retry() {
    ref.read(authControllerProvider.notifier).linkPrincipal();
  }

  void _backToLogin() {
    if (_sentToLogin) return;
    _sentToLogin = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(loginPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    Widget body;
    if (state.hasError) {
      body = _Message(
        title: "Something isn't working",
        detail: kGenericAuthErrorMessage,
        onRetry: _retry,
      );
    } else {
      final outcome = state.value;
      if (outcome == null || state.isLoading) {
        body = const _Message(
          title: "You're signed in, but this account isn't connected to a "
              'membership yet.',
          detail: 'Checking your invitation...',
          loading: true,
        );
      } else {
        switch (outcome) {
          case LinkOutcomeLinked():
            body = const _Message(
              title: "You're signed in, but this account isn't connected "
                  'to a membership yet.',
              detail: "You're connected. Taking you in...",
              loading: true,
            );
          case LinkOutcomeNotLinked(:final reason):
            body = switch (reason) {
              LinkFailure.noInvitation => _Message(
                title: "You're signed in, but this account isn't connected "
                    'to a membership yet.',
                detail: 'Check with the gym\'s front desk -- they may not '
                    'have set up your invitation yet.',
                onRetry: _retry,
              ),
              LinkFailure.ambiguousInvitation => _Message(
                title: "You're signed in, but this account isn't connected "
                    'to a membership yet.',
                detail: 'The same email is invited at two gyms. Staff at '
                    'the front desk need to fix this before you can '
                    'continue.',
                onRetry: _retry,
              ),
              LinkFailure.notAuthenticated => () {
                  _backToLogin();
                  return const _Message(
                    title: "You're signed in, but this account isn't "
                        'connected to a membership yet.',
                    detail: "You're no longer signed in. Taking you back "
                        'to login...',
                    loading: true,
                  );
                }(),
              LinkFailure.unknown => _Message(
                title: "You're signed in, but this account isn't connected "
                    'to a membership yet.',
                detail: kGenericAuthErrorMessage,
                onRetry: _retry,
              ),
            };
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Brand.spaceLg),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.detail,
    this.loading = false,
    this.onRetry,
  });

  final String title;
  final String detail;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: Brand.spaceMd),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (loading) ...[
            const SizedBox(height: Brand.spaceLg),
            const CircularProgressIndicator(),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: Brand.spaceLg),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ],
      ),
    );
  }
}
