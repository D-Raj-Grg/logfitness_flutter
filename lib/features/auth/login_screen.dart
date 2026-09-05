import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/auth/auth_error_text.dart';

final _emailShape = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Email + password sign-in, shared by both principals: staff sign in with
/// their console account, invited members with the address they were
/// invited at. The screen never asks which one a user is -- the claims the
/// session comes back with decide that (see `AppClaims` / `Principal`), and
/// the router sends the session to the right place afterwards.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _resettingPassword = false;
  String? _resetPasswordMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Enter your email address.';
    }
    if (!_emailShape.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _resetPasswordMessage = null);
    await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _forgotPassword() async {
    final error = _validateEmail(_emailController.text);
    if (error != null) {
      setState(() => _resetPasswordMessage = error);
      return;
    }

    setState(() {
      _resettingPassword = true;
      _resetPasswordMessage = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _resetPasswordMessage =
            "If that email has an account, we've sent a link to reset "
            'the password.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _resetPasswordMessage = kGenericAuthErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _resettingPassword = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isSigningIn = authState.isLoading;
    final signInError = authState.hasError
        ? mapSignInErrorMessage(authState.error!)
        : null;

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
                      'Lord of Gyms',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      'Sign in to continue.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Brand.spaceXl),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !isSigningIn,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: Brand.spaceMd),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !isSigningIn,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (signInError != null) ...[
                      const SizedBox(height: Brand.spaceMd),
                      Text(
                        signInError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: Brand.spaceLg),
                    FilledButton(
                      onPressed: isSigningIn ? null : _submit,
                      child: isSigningIn
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Sign in'),
                    ),
                    const SizedBox(height: Brand.spaceSm),
                    TextButton(
                      onPressed: _resettingPassword ? null : _forgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                    if (_resetPasswordMessage != null) ...[
                      const SizedBox(height: Brand.spaceSm),
                      Text(
                        _resetPasswordMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
