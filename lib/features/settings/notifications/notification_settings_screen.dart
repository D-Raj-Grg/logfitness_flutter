// Settings → Notifications. Owner only.
//
// Port of `logfitness_saas/app/(app)/settings/notifications/page.tsx`, laid out
// the same way and for the same reason: three channel tabs carrying one gateway
// form each, and then -- outside the tabs, because they are not per-channel --
// the reminder schedule and the gym's own wording.
//
// **The tab labels carry the state of all three channels.** That tri-state is
// the console's 2026-09-12 change and it exists so a gym with SMS working and
// email half-configured does not have to click twice to find that out.
//
// Owner-only twice over. `StaffCapability.configureNotifications` decides
// whether the row in Settings is offered and whether this screen renders; RLS
// decides whether anything can actually be read or written, and the two are
// deliberately independent (see `staff_capabilities.dart`). The RLS half has a
// sharp edge worth naming: `notification_providers` has an owner-only SELECT
// policy, so a manager reaching this screen would get an **empty list rather
// than a refusal** and be told a gym with three gateways has none. That is why
// the capability gate is here and not only on the Settings row.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/settings/notifications/gateway_form.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_controllers.dart';
import 'package:logfitness_flutter/features/settings/notifications/rules_form.dart';
import 'package:logfitness_flutter/features/settings/notifications/template_editor.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

/// The three channels, in the console's order.
const List<NotificationChannel> kNotificationChannels = <NotificationChannel>[
  NotificationChannel.sms,
  NotificationChannel.viber,
  NotificationChannel.email,
];

/// What one channel's tab says under its name.
enum ChannelReadiness {
  /// An active gateway with a token stored. Messages on this channel go out.
  connected,

  /// A gateway exists but `is_active` is false. Nothing goes out, and nothing
  /// is lost -- the account details are still here.
  paused,

  /// An active gateway with no credential. Configured and mute: every send
  /// lands in the log as "Not sent". Not one of the console's three states --
  /// it carries this as a separate badge -- but calling it Connected would be
  /// a lie and calling it Not set up would throw the row away.
  noToken,

  /// Nothing has been set up on this channel.
  notSetUp,
}

String channelReadinessLabel(ChannelReadiness readiness) => switch (readiness) {
  ChannelReadiness.connected => 'Connected',
  ChannelReadiness.paused => 'Paused',
  ChannelReadiness.noToken => 'No token yet',
  ChannelReadiness.notSetUp => 'Not set up',
};

ChannelReadiness channelReadiness(
  NotificationProvider? gateway,
  bool hasToken,
) {
  if (gateway == null) return ChannelReadiness.notSetUp;
  if (!gateway.isActive) return ChannelReadiness.paused;
  return hasToken ? ChannelReadiness.connected : ChannelReadiness.noToken;
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool allowed = ref
        .watch(staffCapabilitiesProvider)
        .contains(StaffCapability.configureNotifications);

    if (!allowed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const FailureView(
          failure: AppFailure(
            FailureKind.refused,
            'Only an owner can change how this gym sends messages.',
          ),
        ),
      );
    }

    final AsyncValue<GatewaySettings> gateways = ref.watch(
      notificationGatewaysProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: AsyncValueView<GatewaySettings>(
        value: gateways,
        onRetry: () => ref.invalidate(notificationGatewaysProvider),
        data: (GatewaySettings settings) => ListView(
          padding: const EdgeInsets.all(Brand.spaceMd),
          children: <Widget>[
            Text(
              'Which gateway carries your messages, when reminders go out, and '
              'what they say.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Brand.spaceSm),
            Text(
              'Every gym uses its own SMS account, so the credits and the sender '
              'ID are yours. Tokens are stored encrypted and cannot be read back '
              'from this screen, only replaced or cleared.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
            _ChannelTabs(settings: settings),
            const SizedBox(height: Brand.spaceLg),
            const RulesForm(),
            const SizedBox(height: Brand.spaceLg),
            const TemplateEditor(),
            const SizedBox(height: Brand.spaceXl),
          ],
        ),
      ),
    );
  }
}

/// The three tabs and the one gateway form under whichever is selected.
///
/// A `TabBarView` is deliberately not used here. It sizes itself to its
/// constraints, and inside a scrolling column there are none -- while the form
/// under each tab is a different height depending on the gateway chosen, so
/// there is no honest fixed height to give it either. Rendering only the
/// selected channel's form keeps the tabs, the scroll and the variable height
/// all working together.
class _ChannelTabs extends StatelessWidget {
  const _ChannelTabs({required this.settings});

  final GatewaySettings settings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DefaultTabController(
      length: kNotificationChannels.length,
      child: Builder(
        builder: (BuildContext context) {
          final TabController controller = DefaultTabController.of(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: <Widget>[
                  for (final NotificationChannel channel
                      in kNotificationChannels)
                    Tab(
                      key: ValueKey<String>('channel-tab-${channel.wire}'),
                      // Two lines, so the default 46 is not enough: the state
                      // word sits under the channel name rather than beside
                      // it, which is what keeps three tabs on a phone.
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(notificationChannelLabel(channel)),
                          Text(
                            channelReadinessLabel(
                              channelReadiness(
                                settings.forChannel(channel),
                                settings.tokenFor(settings.forChannel(channel)),
                              ),
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Brand.spaceMd),
              AnimatedBuilder(
                animation: controller,
                builder: (BuildContext context, Widget? _) {
                  final NotificationChannel channel =
                      kNotificationChannels[controller.index];
                  final NotificationProvider? gateway = settings.forChannel(
                    channel,
                  );

                  return GatewayForm(
                    // Keyed on the row itself, so a save rebuilds the form
                    // from what the database ended up with rather than from
                    // whatever was typed into it.
                    key: ValueKey<String>(
                      'gateway-${channel.wire}-${gateway?.id}-${gateway?.updatedAt}',
                    ),
                    channel: channel,
                    gateway: gateway,
                    hasToken: settings.tokenFor(gateway),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
