// PLANNING.md §4 as an assertion. If the table in `staff_capabilities.dart`
// drifts from the spec, this fails before a screen does.
//
// It checks both halves of every row -- what a role holds AND what it does
// not -- because a capability model only ever fails in the second direction.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

void main() {
  group('PLANNING.md §4', () {
    test('front_desk: check-in, payment, walk-in, renewals, collection', () {
      expect(capabilitiesFor(StaffRole.frontDesk), <StaffCapability>{
        StaffCapability.checkIn,
        StaffCapability.collectPayment,
        StaffCapability.walkInSignup,
        StaffCapability.renewMembership,
        StaffCapability.viewTodaysCollection,
        StaffCapability.lookUpMember,
        // Added 2026-09-11. The database already permits it
        // (`jwt_can_serve_members` is {owner, manager, front_desk} and
        // `set_member_left` is security invoker) and the console already
        // allows it, so refusing it here hid the action from the only person
        // who learns that someone has left.
        StaffCapability.recordDeparture,
        // Added 2026-09-12 with the notification surfaces. Transcribed from
        // `member_message_target`, which gates on {owner, manager, front_desk}
        // itself: the desk is who chases dues, and the member standing at the
        // counter owing money is the one the nightly sweep already missed.
        StaffCapability.sendMemberMessage,
      });
    });

    test('a departure is not a cancellation', () {
      // Cancelling voids an entitlement someone paid for; recording a
      // departure writes down a fact and is reversible. Keeping them one
      // capability is what put mark-as-left behind a manager.
      final frontDesk = capabilitiesFor(StaffRole.frontDesk);
      expect(frontDesk, contains(StaffCapability.recordDeparture));
      expect(frontDesk, isNot(contains(StaffCapability.cancelMembership)));
      expect(frontDesk, isNot(contains(StaffCapability.refundPayment)));
    });

    test('trainer: own classes only, and nothing off the front desk row', () {
      expect(capabilitiesFor(StaffRole.trainer), <StaffCapability>{
        StaffCapability.manageOwnClasses,
      });
    });

    test('manager: everything front desk can do, plus the manager row', () {
      final manager = capabilitiesFor(StaffRole.manager);

      expect(manager, containsAll(capabilitiesFor(StaffRole.frontDesk)));
      expect(
        manager,
        containsAll(<StaffCapability>[
          StaffCapability.manageMembers,
          StaffCapability.freezeMembership,
          StaffCapability.cancelMembership,
          StaffCapability.refundPayment,
          StaffCapability.viewBranchReports,
        ]),
      );
      // A manager is branch-scoped; only an owner reaches the whole org.
      expect(manager, isNot(contains(StaffCapability.accessAllBranches)));
    });

    test('owner: manager capability, widened to every branch', () {
      final owner = capabilitiesFor(StaffRole.owner);

      expect(owner, containsAll(capabilitiesFor(StaffRole.manager)));
      expect(owner, contains(StaffCapability.accessAllBranches));
      expect(
        owner.difference(capabilitiesFor(StaffRole.manager)),
        <StaffCapability>{
          StaffCapability.accessAllBranches,
          // The one exception to "reach, not a different job", and it is the
          // database's exception rather than this file's: every policy on
          // notification_providers, notification_rules and
          // notification_templates is owner-only, so a manager offered the
          // screen would be refused 42501 by the RPC behind every button on
          // it.
          StaffCapability.configureNotifications,
        },
        reason: 'an owner is a manager with reach, plus the gateway keys',
      );
    });

    test('the destructive half never reaches front desk or trainer', () {
      const destructive = <StaffCapability>[
        StaffCapability.refundPayment,
        StaffCapability.cancelMembership,
        StaffCapability.freezeMembership,
        StaffCapability.manageMembers,
        StaffCapability.viewBranchReports,
        StaffCapability.accessAllBranches,
      ];

      for (final role in <StaffRole>[StaffRole.frontDesk, StaffRole.trainer]) {
        for (final capability in destructive) {
          expect(
            capabilitiesFor(role),
            isNot(contains(capability)),
            reason: '${role.wire} must not be offered ${capability.name}',
          );
        }
      }
    });

    test('every staff_role has a row -- an unmapped role sees nothing', () {
      for (final role in StaffRole.values) {
        expect(
          capabilitiesFor(role),
          isNotEmpty,
          reason: '${role.wire} would land in an empty shell',
        );
      }
    });
  });

  group('the notification capabilities (2026-09-12)', () {
    // Three capabilities, three different gates upstream, and they are not
    // the same set. Each is transcribed from whatever actually refuses --
    // a guard function, a console route, or an RLS policy -- rather than from
    // a guess about who "should" see a screen.
    const notification = <StaffCapability>[
      StaffCapability.sendMemberMessage,
      StaffCapability.viewNotificationLog,
      StaffCapability.configureNotifications,
    ];

    test('a trainer holds none of the three', () {
      // `member_message_target` refuses a trainer outright, and a trainer has
      // no reason to read a delivery log or hold the gateway keys.
      final trainer = capabilitiesFor(StaffRole.trainer);

      for (final capability in notification) {
        expect(
          trainer,
          isNot(contains(capability)),
          reason: 'trainer must not be offered ${capability.name}',
        );
      }
    });

    test('front desk sends messages and nothing else', () {
      final frontDesk = capabilitiesFor(StaffRole.frontDesk);

      expect(frontDesk, contains(StaffCapability.sendMemberMessage));
      // The desk sells the renewal; it does not audit whether the chain's SMS
      // credits are running out, and it certainly does not hold the token.
      expect(frontDesk, isNot(contains(StaffCapability.viewNotificationLog)));
      expect(
        frontDesk,
        isNot(contains(StaffCapability.configureNotifications)),
      );
    });

    test('a manager reads the log but does not configure the gateway', () {
      final manager = capabilitiesFor(StaffRole.manager);

      expect(manager, contains(StaffCapability.sendMemberMessage));
      // Matching the console's requireRole('owner', 'manager') on
      // /notifications.
      expect(manager, contains(StaffCapability.viewNotificationLog));
      // Owner-only RLS on all three notification tables. Worth stating twice:
      // a manager *reading* notification_providers gets an empty list rather
      // than a refusal, so anything derived from "has this org got a gateway"
      // has to be gated on configureNotifications, or a manager is told a gym
      // with three gateways has none.
      expect(manager, isNot(contains(StaffCapability.configureNotifications)));
    });

    test('an owner holds all three', () {
      expect(capabilitiesFor(StaffRole.owner), containsAll(notification));
    });

    test('each capability is held by exactly the roles it names', () {
      Set<StaffRole> holdersOf(StaffCapability capability) => StaffRole.values
          .where((role) => capabilitiesFor(role).contains(capability))
          .toSet();

      expect(holdersOf(StaffCapability.sendMemberMessage), <StaffRole>{
        StaffRole.owner,
        StaffRole.manager,
        StaffRole.frontDesk,
      });
      expect(holdersOf(StaffCapability.viewNotificationLog), <StaffRole>{
        StaffRole.owner,
        StaffRole.manager,
      });
      expect(holdersOf(StaffCapability.configureNotifications), <StaffRole>{
        StaffRole.owner,
      });
    });
  });
}
