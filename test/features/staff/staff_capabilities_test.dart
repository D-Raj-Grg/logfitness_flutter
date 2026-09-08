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
      });
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
        <StaffCapability>{StaffCapability.accessAllBranches},
        reason: 'an owner is a manager with reach, not a different job',
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
}
