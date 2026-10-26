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
import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/settings/catalogue/branches_screen.dart';
import 'package:logfitness_flutter/features/settings/catalogue/fees_screen.dart';
import 'package:logfitness_flutter/features/settings/catalogue/plans_screen.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/settings/letterhead/letterhead_screen.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_controllers.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_screen.dart';
import 'package:logfitness_flutter/features/settings/preferences/preferences_screen.dart';
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
    final Set<StaffCapability> caps = ref.watch(staffCapabilitiesProvider);
    // Owner only. RLS says the same thing without consulting this line, and
    // says it differently: `notification_providers` has an owner-only SELECT
    // policy, so a manager who reached that screen anyway would be shown an
    // empty list rather than a refusal. Hiding the row is the only place the
    // distinction can be made honestly.
    final bool canConfigureNotifications = caps.contains(
      StaffCapability.configureNotifications,
    );
    final bool canManageOrgProfile = caps.contains(
      StaffCapability.manageOrgProfile,
    );
    // Owner and manager: the read-only branch list. Same set as
    // `viewBranchReports` (manager and up); branches are edited on the console.
    final bool canViewCatalogue = caps.contains(
      StaffCapability.viewBranchReports,
    );
    final bool canManagePlans = caps.contains(StaffCapability.managePlans);
    // Owner only: pricing the gym. Every seller reads the catalogue to quote a
    // sale; only the owner writes it.
    final bool canManageFees = caps.contains(StaffCapability.manageFees);

    // Only read for an owner: the provider's rows are owner-only in RLS.
    final String? messagingStatus = canConfigureNotifications
        ? _messagingStatus(ref.watch(notificationGatewaysProvider).value)
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        Brand.spaceSm,
        Brand.spaceMd,
        Brand.spaceMd,
      ),
      children: <Widget>[
        if (canManageOrgProfile || canViewCatalogue)
          _Section(
            title: 'Gym profile',
            children: <Widget>[
              if (canManageOrgProfile)
                _NavRow(
                  key: const ValueKey<String>('settings-letterhead'),
                  icon: Icons.badge_outlined,
                  title: 'Letterhead and invoices',
                  subtitle:
                      'Name, address, PAN/VAT, logo and terms on every invoice',
                  builder: (_) => const LetterheadScreen(),
                ),
              if (canViewCatalogue)
                _NavRow(
                  key: const ValueKey<String>('settings-branches'),
                  icon: Icons.store_outlined,
                  title: 'Branches',
                  subtitle: 'Address, phone and status (view only)',
                  builder: (_) => const BranchesScreen(),
                ),
            ],
          ),
        if (canManagePlans)
          _Section(
            title: 'Plans',
            children: <Widget>[
              _NavRow(
                key: const ValueKey<String>('settings-plans'),
                icon: Icons.card_membership_outlined,
                title: 'Membership plans',
                subtitle:
                    'Add or change price, term and where each is sold',
                builder: (_) => const PlansScreen(),
              ),
              if (canManageFees)
                _NavRow(
                  key: const ValueKey<String>('settings-fees'),
                  icon: Icons.receipt_long_outlined,
                  title: 'Fees',
                  subtitle:
                      'Registration, card and other charges, and which plans carry them',
                  builder: (_) => const FeesScreen(),
                ),
            ],
          ),
        if (canConfigureNotifications)
          _Section(
            title: 'Messaging',
            children: <Widget>[
              // `Navigator.push`, not a `GoRoute`. In-shell navigation in this
              // app is imperative; `go_router` owns the shell-level routes only.
              _NavRow(
                key: const ValueKey<String>('settings-notifications'),
                icon: Icons.sms_outlined,
                title: 'SMS, Viber and email',
                subtitle:
                    messagingStatus ??
                    'Sending accounts, reminders and message wording',
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ],
          ),
        _Section(
          title: 'Preferences',
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(Brand.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Appearance', style: theme.textTheme.titleSmall),
                  const SizedBox(height: Brand.spaceSm),
                  SegmentedButton<ThemeMode>(
                    key: const ValueKey<String>('theme-mode-selector'),
                    showSelectedIcon: false,
                    segments: <ButtonSegment<ThemeMode>>[
                      for (final ThemeMode m in ThemeMode.values)
                        ButtonSegment<ThemeMode>(
                          value: m,
                          label: Text(themeModeLabel(m)),
                        ),
                    ],
                    selected: <ThemeMode>{mode},
                    // Applies immediately and is written afterwards, so the
                    // screen never waits on a disk write to change colour.
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
                ],
              ),
            ),
            if (canManageOrgProfile)
              _NavRow(
                key: const ValueKey<String>('settings-preferences'),
                icon: Icons.tune_outlined,
                title: 'Gym preferences',
                subtitle: 'Class cancellation window and message language',
                builder: (_) => const PreferencesScreen(),
              ),
          ],
        ),
        // Reachable from inside the app, not only from the store listing.
        // Apple has required an in-app route to account deletion since 2022
        // for anything that creates an account, and a support URL that only
        // exists in App Store Connect is a URL the person holding the phone
        // cannot use.
        const _Section(
          title: 'Legal and support',
          children: <Widget>[
            _LinkTile(
              key: ValueKey<String>('settings-privacy'),
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy policy',
              url: privacyPolicyUrl,
            ),
            _LinkTile(
              key: ValueKey<String>('settings-terms'),
              icon: Icons.description_outlined,
              label: 'Terms of use',
              url: termsUrl,
            ),
            _LinkTile(
              key: ValueKey<String>('settings-support'),
              icon: Icons.help_outline,
              label: 'Support',
              subtitle: 'Questions, problems, and how to reach us',
              url: supportUrl,
            ),
            _LinkTile(
              key: ValueKey<String>('settings-delete-account'),
              icon: Icons.person_remove_outlined,
              label: 'Delete my account',
              // Accounts here are created by the gym, not by self-signup, so
              // deletion is a request with consequences for the gym's own
              // records -- the page says what happens before anything is
              // destroyed.
              subtitle: 'How to have your account and data removed',
              url: deleteAccountUrl,
            ),
          ],
        ),
      ],
    );
  }

  /// One line saying what is working, e.g. "SMS and Email connected".
  static String? _messagingStatus(GatewaySettings? settings) {
    if (settings == null) return null;
    final List<String> connected = <String>[];
    var needsAttention = false;
    for (final NotificationChannel channel in kNotificationChannels) {
      final NotificationProvider? gateway = settings.forChannel(channel);
      final ChannelReadiness readiness = channelReadiness(
        gateway,
        settings.tokenFor(gateway),
      );
      if (readiness == ChannelReadiness.connected) {
        connected.add(notificationChannelLabel(channel));
      } else if (readiness == ChannelReadiness.noToken) {
        needsAttention = true;
      }
    }
    if (connected.isEmpty) {
      return needsAttention ? 'Needs an API token' : 'Not set up';
    }
    return 'Connected: ${connected.join(', ')}';
  }
}

/// A titled group of rows on one tinted surface.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: Brand.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Brand.spaceXs,
              Brand.spaceSm,
              Brand.spaceXs,
              Brand.spaceSm,
            ),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Material(
            color: scheme.surfaceContainerLow,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Brand.radiusMedium),
            ),
            child: Column(
              children: <Widget>[
                for (var i = 0; i < children.length; i++) ...<Widget>[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: Brand.spaceMd,
                      endIndent: Brand.spaceMd,
                      color: scheme.outlineVariant,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row that opens another settings screen.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: builder)),
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
