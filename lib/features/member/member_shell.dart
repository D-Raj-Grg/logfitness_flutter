import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/features/member/classes/member_classes_screen.dart';
import 'package:logfitness_flutter/features/member/home/member_home_screen.dart';
import 'package:logfitness_flutter/features/member/payments/member_payments_screen.dart';
import 'package:logfitness_flutter/features/member/profile/member_profile_screen.dart';
import 'package:logfitness_flutter/features/member/qr/member_qr_screen.dart';

/// Root shell for the `member` role: five bottom tabs. Messages is reached
/// from Home and Profile; bookings from the Classes screen (Agent D owns
/// `MemberBookingsScreen`). Role gates the shell, RLS gates the data.
class MemberShell extends ConsumerStatefulWidget {
  const MemberShell({super.key});

  @override
  ConsumerState<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends ConsumerState<MemberShell> {
  int _index = 0;

  static const List<Widget> _tabs = <Widget>[
    MemberHomeScreen(),
    MemberClassesScreen(),
    MemberQrScreen(),
    MemberPaymentsScreen(),
    MemberProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_2),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
