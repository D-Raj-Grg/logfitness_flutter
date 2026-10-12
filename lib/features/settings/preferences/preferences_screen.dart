// Settings -> Preferences (owner only).
//
// Port of the web console's `org-preferences-form.tsx`: the class
// cancellation window and the language of automatic messages. Gated by
// `StaffCapability.manageOrgProfile`; the RPC enforces owner-only on its own.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/validation/org_preferences.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/docked_action.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/settings/preferences/preferences_providers.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<OrgPreferences?> prefs = ref.watch(orgPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: AsyncValueView<OrgPreferences?>(
        value: prefs,
        onRetry: () => ref.invalidate(orgPreferencesProvider),
        isEmpty: (OrgPreferences? p) => p == null,
        emptyMessage: "Could not find this gym's settings.",
        data: (OrgPreferences? p) => _PreferencesForm(initial: p!),
      ),
    );
  }
}

class _PreferencesForm extends ConsumerStatefulWidget {
  const _PreferencesForm({required this.initial});

  final OrgPreferences initial;

  @override
  ConsumerState<_PreferencesForm> createState() => _PreferencesFormState();
}

class _PreferencesFormState extends ConsumerState<_PreferencesForm> {
  late final TextEditingController _window;
  late String _locale;
  Map<PreferencesField, String> _errors = <PreferencesField, String>{};

  @override
  void initState() {
    super.initState();
    _window = TextEditingController(
      text: widget.initial.cancellationWindowMinutes.toString(),
    );
    _locale = widget.initial.notificationLocale;
  }

  @override
  void dispose() {
    _window.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final PreferencesValidation result = validatePreferences(
      cancellationWindow: _window.text,
      notificationLocale: _locale,
    );
    setState(() => _errors = result.errors);
    if (!result.isValid) return;

    final AppFailure? failure = await ref
        .read(preferencesSaveProvider.notifier)
        .save(result.values!);
    if (!mounted) return;
    if (failure == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preferences saved.')));
    } else {
      showFailureSnackBar(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool saving = ref.watch(preferencesSaveProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: DockedAction(
        label: saving ? 'Saving…' : 'Save preferences',
        icon: Icons.check,
        onPressed: saving ? null : () => unawaited(_save()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Brand.spaceMd),
        children: <Widget>[
          Text('Classes', style: theme.textTheme.titleSmall),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('preferences-cancellation-window'),
            controller: _window,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cancellation window (minutes)',
              helperText:
                  'Bookings cannot be cancelled this close to the class start. 0 to $kMaxCancellationWindowMinutes.',
              helperMaxLines: 3,
              errorText: _errors[PreferencesField.cancellationWindow],
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: Brand.spaceLg),
          const Divider(),
          const SizedBox(height: Brand.spaceSm),
          Text('Messages', style: theme.textTheme.titleSmall),
          const SizedBox(height: Brand.spaceMd),
          DropdownButtonFormField<String>(
            key: const ValueKey<String>('preferences-locale'),
            initialValue: _locale,
            decoration: InputDecoration(
              labelText: 'Notification language',
              errorText: _errors[PreferencesField.notificationLocale],
              border: const OutlineInputBorder(),
            ),
            items: <DropdownMenuItem<String>>[
              for (final String l in kNotificationLocales)
                DropdownMenuItem<String>(
                  value: l,
                  child: Text(notificationLocaleLabel(l)),
                ),
            ],
            onChanged: saving
                ? null
                : (String? v) => setState(() => _locale = v ?? _locale),
          ),
        ],
      ),
    );
  }
}
