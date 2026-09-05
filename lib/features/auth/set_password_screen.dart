import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/app/router.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/auth/auth_error_text.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

/// Route path for [SetPasswordScreen]. Re-exported by `router.dart`, which
/// wires this into `goRouterProvider` and gives it a redirect exemption
/// (a session that lands here from an invite email carries no claims yet,
/// and must not be bounced to `/link` before it gets a chance to set a
/// password).
const setPasswordPath = '/set-password';

/// Where an invited member lands after opening the "set your password"
/// email. By the time this screen builds, supabase_flutter has already
/// exchanged the link for a session (see `auth_deep_links.dart`) -- this
/// screen's job is just to confirm the account, collect a new password
/// twice, save it, and hand off to the link step.
class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a password.';
    }
    if (value.length < 8) {
      return 'Use at least 8 characters.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter the password again.';
    }
    if (value != _passwordController.text) {
      return "Passwords don't match.";
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .updatePassword(_passwordController.text);

      // The account now has a password; hand off to the link step so the
      // account gets connected to its membership/staff row and claims
      // refresh. Any outcome (linked, not linked, or an unexpected error)
      // is rendered by whatever screen the router sends the session to
      // next -- this screen does not duplicate that logic.
      await ref.read(authControllerProvider.notifier).linkPrincipal();

      // Navigate explicitly rather than trusting the redirect: when linking
      // does not find an invitation the principal stays `notLinked`, and the
      // guard leaves this route alone in that state -- which would strand the
      // member here with a password set and nowhere to go. /link renders the
      // outcome, whichever way it went.
      if (mounted) {
        context.go(linkPath);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = mapUpdatePasswordErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(Brand.spaceLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This link has expired',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Brand.spaceSm),
                  Text(
                    'This invitation link is no longer valid. Please sign '
                    'in, or ask the gym to send a new invitation.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Brand.spaceLg),
                  FilledButton(
                    onPressed: () => context.go(loginPath),
                    child: const Text('Back to login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Brand.spaceLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Set your password',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      "You're almost done. Choose a password for your "
                      'account.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Brand.spaceXl),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !_submitting,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: Brand.spaceMd),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !_submitting,
                      decoration: const InputDecoration(
                        labelText: 'Confirm new password',
                      ),
                      validator: _validateConfirm,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: Brand.spaceMd),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: Brand.spaceLg),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
