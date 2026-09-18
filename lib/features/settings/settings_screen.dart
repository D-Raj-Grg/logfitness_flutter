// The signed-in person's own settings — plus, for an owner, the one piece of
// org configuration that lives in this app.
//
// This file used to say that notification gateways stay on the web console.
// **That stopped being true on 2026-09-12**, when the whole notification
// surface — gateway, reminder schedule and the gym's own wording, along with
// the delivery log and sending by hand — was scoped into this app. The desk
// standing in front of a member who owes money can now text them and can see
// whether last night's reminder went out, and the owner can set all of that up
// from the phone.
//
// What is still console-only is **branch and staff administration**: creating
// branches, inviting staff, setting roles and branch assignments. Everything
// else a gym runs on reached parity here (CLAUDE.md, "Scope discipline";
// `TASKS.md`, "Staff parity programme" and "Notifications parity").
//
// Everything else on this screen is what this person, on this phone, can change
// about their own use of the app.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/app/legal_links.dart';
import 'package:logfitness_flutter/app/theme_mode_controller.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_screen.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

/// What each mode is called on screen. "System" rather than "Automatic",
/// because it follows the phone's setting and saying so is shorter than
/// explaining it.
String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'System',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};

IconData themeModeIcon(ThemeMode mode) => switch (mode) {
  ThemeMode.system => Icons.brightness_auto_outlined,
  ThemeMode.light => Icons.light_mode_outlined,
  ThemeMode.dark => Icons.dark_mode_outlined,
};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    // Owner only. RLS says the same thing without consulting this line, and
    // says it differently: `notification_providers` has an owner-only SELECT
    // policy, so a manager who reached that screen anyway would be shown an
    // empty list rather than a refusal. Hiding the row is the only place the
    // distinction can be made honestly.
    final bool canConfigureNotifications = ref
        .watch(staffCapabilitiesProvider)
        .contains(StaffCapability.configureNotifications);

    return ListView(
      padding: const EdgeInsets.all(Brand.spaceMd),
      children: <Widget>[
        Text('Appearance', style: theme.textTheme.titleSmall),
        const SizedBox(height: Brand.spaceSm),
        SegmentedButton<ThemeMode>(
          key: const ValueKey<String>('theme-mode-selector'),
          segments: <ButtonSegment<ThemeMode>>[
            for (final ThemeMode m in ThemeMode.values)
              ButtonSegment<ThemeMode>(
                value: m,
                icon: Icon(themeModeIcon(m)),
                label: Text(themeModeLabel(m)),
              ),
          ],
          selected: <ThemeMode>{mode},
          // Applies immediately and is written afterwards, so the screen never
          // waits on a disk write to change colour.
          onSelectionChanged: (Set<ThemeMode> next) =>
              ref.read(themeModeProvider.notifier).set(next.first),
        ),
        const SizedBox(height: Brand.spaceSm),
        Text(
          mode == ThemeMode.system
              ? "Follows this phone's setting."
              : 'Stays ${themeModeLabel(mode).toLowerCase()} whatever the phone is set to.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        if (canConfigureNotifications) ...<Widget>[
          const SizedBox(height: Brand.spaceLg),
          const Divider(),
          const SizedBox(height: Brand.spaceSm),
          Text('This gym', style: theme.textTheme.titleSmall),
          ListTile(
            key: const ValueKey<String>('settings-notifications'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.sms_outlined),
            title: const Text('Notifications'),
            subtitle: const Text(
              'Gateway, reminders and what the messages say',
            ),
            trailing: const Icon(Icons.chevron_right),
            // `Navigator.push`, not a `GoRoute`. In-shell navigation in this
            // app is imperative; `go_router` owns the shell-level routes only.
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ),
          ),
        ],

        const SizedBox(height: Brand.spaceLg),
        const Divider(),
        const SizedBox(height: Brand.spaceSm),
        Text('Legal and support', style: theme.textTheme.titleSmall),
        // Reachable from inside the app, not only from the store listing.
        // Apple has required an in-app route to account deletion since 2022
        // for anything that creates an account, and a support URL that only
        // exists in App Store Connect is a URL the person holding the phone
        // cannot use.
        _LinkTile(
          key: const ValueKey<String>('settings-privacy'),
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy policy',
          url: privacyPolicyUrl,
        ),
        _LinkTile(
          key: const ValueKey<String>('settings-terms'),
          icon: Icons.description_outlined,
          label: 'Terms of use',
          url: termsUrl,
        ),
        _LinkTile(
          key: const ValueKey<String>('settings-support'),
          icon: Icons.help_outline,
          label: 'Support',
          subtitle: 'Questions, problems, and how to reach us',
          url: supportUrl,
        ),
        _LinkTile(
          key: const ValueKey<String>('settings-delete-account'),
          icon: Icons.person_remove_outlined,
          label: 'Delete my account',
          // Accounts here are created by the gym, not by self-signup, so
          // deletion is a request with consequences for the gym's own records
          // -- the page says what happens before anything is destroyed.
          subtitle: 'How to have your account and data removed',
          url: deleteAccountUrl,
        ),
        const SizedBox(height: Brand.spaceMd),
      ],
    );
  }
}

/// One row that opens a hosted page in the phone's browser.
///
/// External, not an in-app web view: these are documents a person may want to
/// keep, print or send on, and a review engineer opening them should land in
/// a real browser with a URL bar.
class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.url,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => unawaited(_open(context)),
    );
  }

  Future<void> _open(BuildContext context) async {
    // A phone with no browser that will take the URL is rare and not
    // hypothetical -- a locked-down work profile does it -- and silently
    // doing nothing on a tap is how a person concludes the app is broken.
    final bool opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((Object _) => false);

    if (!opened && context.mounted) {
      showFailureSnackBar(
        context,
        AppFailure(
          FailureKind.unknown,
          'Could not open $url. Copy it into a browser.',
        ),
      );
    }
  }
}
