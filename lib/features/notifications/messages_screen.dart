// The Messages destination: the delivery log, and announcements.
//
// Two tabs rather than two nav entries. They answer adjacent questions about
// the same table -- "did last night's reminders go out" and "what have we told
// everybody" -- and the phone's bar holds five destinations
// (`staff_destinations.dart`), which is already the constraint the shell's
// overflow split exists for.
//
// THE KEEP-ALIVE IS NOT DECORATION. `TabBarView` disposes the `State` of the
// child that is off screen. `NotificationLogScreen` owns a `ScrollController`,
// a search field and a poller whose fifteen-minute give-up clock starts when it
// does, and `notificationLogProvider` is autoDispose and watched only by that
// screen -- so without `AutomaticKeepAliveClientMixin` a glance at the other
// tab would drop the reader to the top of a freshly re-fetched list and restart
// the clock. `staff_shell.dart` solves the same problem for destinations with
// an `IndexedStack`; this is that, with the swipe kept.
//
// EACH TAB OWNS ITS OWN `AppLifecycleListener`, and that is deliberate rather
// than lazy. Hosting one listener here that poked both pollers reads better and
// is wrong: `ref.read(announcementLiveRefreshProvider.notifier)` *builds* that
// poller, whose `build` watches the announcements list, which fetches it -- so
// a manager backgrounding their phone on the delivery log would issue a query
// for a tab they never opened, and a log-only role would issue one for a tab
// they do not have. A listener that lives with the thing it drives cannot do
// that, because a tab that was never built never registers one.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/features/announcements/announcements_tab.dart';
import 'package:logfitness_flutter/features/notifications/notification_log_screen.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with TickerProviderStateMixin {
  TabController? _tabs;
  int _tabCount = 0;

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Set<StaffCapability> capabilities = ref.watch(
      staffCapabilitiesProvider,
    );
    final bool canSeeLog = capabilities.contains(
      StaffCapability.viewNotificationLog,
    );
    final bool canAnnounce = capabilities.contains(
      StaffCapability.sendAnnouncement,
    );

    final List<(String, Widget)> tabs = <(String, Widget)>[
      if (canSeeLog) ('Log', const NotificationLogScreen()),
      if (canAnnounce) ('Announcements', const AnnouncementsTab()),
    ];

    // A role with one of the two gets that one, with no tab bar to tap: a
    // single tab is a label, not a choice. A role with neither never reaches
    // this screen -- the destination requires one of them -- but an empty state
    // is cheaper than an assertion that fires on a phone.
    if (tabs.isEmpty) return const SizedBox.shrink();
    if (tabs.length == 1) return tabs.single.$2;

    // Rebuilt only when the number of tabs changes, which happens when the role
    // does. Recreating it on every build would reset the selected tab.
    if (_tabs == null || _tabCount != tabs.length) {
      _tabs?.dispose();
      _tabs = TabController(length: tabs.length, vsync: this);
      _tabCount = tabs.length;
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          TabBar(
            controller: _tabs,
            tabs: <Widget>[
              for (final (String label, _) in tabs)
                Tab(key: ValueKey<String>('messages-tab-$label'), text: label),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: <Widget>[
                for (final (_, Widget child) in tabs) _KeepAlive(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `IndexedStack` semantics inside a `TabBarView`.
///
/// See the file header: without this, switching tabs tears down the log's
/// scroll position, its loaded pages, its search text and its poller's clock.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Required by the mixin, and it must come first.
    super.build(context);
    return widget.child;
  }
}
