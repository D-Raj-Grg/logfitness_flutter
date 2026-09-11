// Renewing. The renewal inserts; nothing is edited. What is tested here is
// that the write happens once, that a refusal is legible, and that the sale
// the screen shows is the sale that goes over the wire.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so override lists stay
// untyped literals (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/memberships/membership_rpc_results.dart';
import 'package:logfitness_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/payments/payment_formatting.dart';
import 'package:logfitness_flutter/features/payments/renew_membership_controller.dart';
import 'package:logfitness_flutter/features/payments/renew_membership_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeMembershipsRepository implements MembershipsRepository {
  int renewCallCount = 0;
  Map<String, Object?> lastArgs = <String, Object?>{};
  Object? error;

  @override
  Future<RenewMembershipResult> renewMembership({
    required String memberId,
    required String planId,
    required String branchId,
    DateTime? startDate,
    int discountPaisa = 0,
    int amountPaidPaisa = 0,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    String? notes,
    DiscountReason? discountReason,
    String? discountNote,
  }) async {
    renewCallCount++;
    lastArgs = <String, Object?>{
      'memberId': memberId,
      'planId': planId,
      'branchId': branchId,
      'startDate': startDate,
      'discountPaisa': discountPaisa,
      'amountPaidPaisa': amountPaidPaisa,
      'method': method,
      'referenceNo': referenceNo,
      'discountReason': discountReason,
      'discountNote': discountNote,
    };
    // Let a concurrent second call observe the in-flight guard.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (error != null) {
      throw error!;
    }
    return RenewMembershipResult(
      membershipId: 'ms-2',
      invoiceId: 'inv-2',
      invoiceNo: 'INV-0012',
      startDate: DateTime.utc(2026, 10, 1),
      endDate: DateTime.utc(2026, 10, 30),
      totalPaisa: 500000 - discountPaisa,
      duePaisa: (500000 - discountPaisa) - amountPaidPaisa,
    );
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

List<dynamic> _overrides(_FakeMembershipsRepository repo) => <dynamic>[
  membershipsRepositoryProvider.overrideWithValue(repo),
];

MembershipPlan _plan({
  int pricePaisa = 500000,
  int signupFeePaisa = 100000,
  int? durationDays = 30,
}) => MembershipPlan(
  id: 'plan-1',
  orgId: 'org-1',
  name: 'Monthly',
  planType: durationDays == null ? PlanType.sessionPack : PlanType.time,
  durationDays: durationDays,
  pricePaisa: pricePaisa,
  signupFeePaisa: signupFeePaisa,
  branchIds: const <String>[],
  isActive: true,
  sortOrder: 1,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

Membership _membership({
  required DateTime startDate,
  DateTime? endDate,
  MembershipStatus status = MembershipStatus.active,
}) => Membership(
  id: 'ms-1',
  orgId: 'org-1',
  branchId: 'branch-1',
  memberId: 'm-1',
  planId: 'plan-1',
  planName: 'Monthly',
  planType: PlanType.time,
  startDate: startDate,
  endDate: endDate,
  pricePaisa: 500000,
  discountPaisa: 0,
  signupFeePaisa: 0,
  status: status,
  frozenDays: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  late _FakeMembershipsRepository memberships;
  late ProviderContainer container;

  setUp(() {
    memberships = _FakeMembershipsRepository();
    container = ProviderContainer(overrides: [..._overrides(memberships)]);

    // The screen holds this provider with `ref.watch`; without an equivalent
    // subscription here the notifier auto-disposes across the first await.
    container.listen<bool>(renewMembershipProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  RenewMembership notifier() => container.read(renewMembershipProvider.notifier);

  group('the controller', () {
    test('rupees reach the RPC as integer paisa, converted exactly once',
        () async {
      await notifier().submit(
        memberId: 'm-1',
        planId: 'plan-1',
        branchId: 'branch-1',
        discountPaisa: paisaOrZero('250.50'),
        amountPaidPaisa: paisaOrZero('1234.56'),
      );

      expect(memberships.lastArgs['discountPaisa'], 25050);
      expect(memberships.lastArgs['amountPaidPaisa'], 123456);
      expect(memberships.lastArgs['amountPaidPaisa'], isA<int>());
    });

    test('a double submit reaches the RPC once', () async {
      // `renew_membership` is not idempotent: a second call sells a second
      // membership and takes the money twice.
      final Future<RenewOutcome> first = notifier().submit(
        memberId: 'm-1',
        planId: 'plan-1',
        branchId: 'branch-1',
        amountPaidPaisa: 500000,
      );
      final Future<RenewOutcome> second = notifier().submit(
        memberId: 'm-1',
        planId: 'plan-1',
        branchId: 'branch-1',
        amountPaidPaisa: 500000,
      );

      final List<RenewOutcome> results =
          await Future.wait<RenewOutcome>(<Future<RenewOutcome>>[first, second]);

      expect(memberships.renewCallCount, 1);
      expect(results.whereType<RenewSucceeded>(), hasLength(1));
      expect(results.whereType<RenewFailed>(), hasLength(1));
    });

    test('a 42501 surfaces as a refusal, and sells nothing', () async {
      memberships.error = const PostgrestException(
        message: 'new row violates row-level security policy',
        code: '42501',
      );

      final RenewOutcome outcome = await notifier().submit(
        memberId: 'm-1',
        planId: 'plan-1',
        branchId: 'branch-1',
      );

      expect(outcome, isA<RenewFailed>());
      final RenewFailed failed = outcome as RenewFailed;
      expect(failed.isRefusal, isTrue);
      expect(failed.failure.kind, FailureKind.refused);
    });

    test("the RPC's own sentence survives a check_violation", () async {
      memberships.error = const PostgrestException(
        message: 'Payment cannot exceed the amount due',
        code: '23514',
      );

      final RenewOutcome outcome = await notifier().submit(
        memberId: 'm-1',
        planId: 'plan-1',
        branchId: 'branch-1',
        amountPaidPaisa: 900000,
      );

      expect(outcome, isA<RenewFailed>());
      expect(
        (outcome as RenewFailed).failure.message,
        'Payment cannot exceed the amount due',
      );
    });

    test('a start date stays a calendar day', () async {
      await notifier().submit(
        memberId: 'm-1',
        planId: 'plan-1',
        branchId: 'branch-1',
        startDate: DateTime.utc(2026, 10, 1),
      );

      final DateTime start = memberships.lastArgs['startDate']! as DateTime;
      expect(start.isUtc, isTrue);
      expect(start.hour, 0);
      expect(start, DateTime.utc(2026, 10, 1));
    });
  });

  group('projectRenewal', () {
    final DateTime today = DateTime.utc(2026, 9, 10);

    test('charges the joining fee only on a first membership', () {
      final RenewalProjection first = projectRenewal(
        plan: _plan(),
        existing: const <Membership>[],
        today: today,
        chosenStartDate: null,
        discountPaisa: 0,
        amountPaidPaisa: 0,
      );
      expect(first.signupFeePaisa, 100000);
      expect(first.subtotalPaisa, 600000);

      final RenewalProjection renewal = projectRenewal(
        plan: _plan(),
        existing: <Membership>[
          _membership(
            startDate: DateTime.utc(2026, 8, 1),
            endDate: DateTime.utc(2026, 8, 30),
            status: MembershipStatus.expired,
          ),
        ],
        today: today,
        chosenStartDate: null,
        discountPaisa: 0,
        amountPaidPaisa: 0,
      );
      expect(renewal.signupFeePaisa, 0);
      expect(renewal.subtotalPaisa, 500000);
    });

    test('follows on from a membership still running, so no day is covered '
        'twice', () {
      final RenewalProjection projection = projectRenewal(
        plan: _plan(),
        existing: <Membership>[
          _membership(
            startDate: DateTime.utc(2026, 9, 1),
            endDate: DateTime.utc(2026, 9, 30),
          ),
        ],
        today: today,
        chosenStartDate: null,
        discountPaisa: 0,
        amountPaidPaisa: 0,
      );

      expect(projection.startDate, DateTime.utc(2026, 10, 1));
      // A 30-day plan starting on the 1st runs through the 30th.
      expect(projection.endDate, DateTime.utc(2026, 10, 30));
    });

    test('starts today when the last membership has already lapsed', () {
      final RenewalProjection projection = projectRenewal(
        plan: _plan(),
        existing: <Membership>[
          _membership(
            startDate: DateTime.utc(2026, 7, 1),
            endDate: DateTime.utc(2026, 7, 30),
            status: MembershipStatus.expired,
          ),
        ],
        today: today,
        chosenStartDate: null,
        discountPaisa: 0,
        amountPaidPaisa: 0,
      );

      expect(projection.startDate, today);
    });

    test('a session pack has no end date', () {
      final RenewalProjection projection = projectRenewal(
        plan: _plan(durationDays: null),
        existing: const <Membership>[],
        today: today,
        chosenStartDate: null,
        discountPaisa: 0,
        amountPaidPaisa: 0,
      );

      expect(projection.endDate, isNull);
    });

    test(
      'an overpayment is clamped to the total, the way the console clamps it',
      () {
        // `renew-form.tsx` does `Math.min(paisaOrZero(paid), total)`, and the
        // RPC would raise "Payment cannot exceed the amount due" anyway. The
        // screen sends the clamped figure, so what is shown in the summary is
        // what is written.
        final RenewalProjection projection = projectRenewal(
          plan: _plan(signupFeePaisa: 0),
          existing: <Membership>[
            _membership(
              startDate: DateTime.utc(2026, 8, 1),
              endDate: DateTime.utc(2026, 8, 30),
              status: MembershipStatus.expired,
            ),
          ],
          today: today,
          chosenStartDate: null,
          discountPaisa: 0,
          amountPaidPaisa: 900000,
        );

        expect(projection.totalPaisa, 500000);
        expect(projection.amountPaidPaisa, 500000);
        expect(projection.duePaisa, 0);
      },
    );

    test('a discount over the price is clamped to the price', () {
      final RenewalProjection projection = projectRenewal(
        plan: _plan(signupFeePaisa: 0),
        existing: <Membership>[
          _membership(
            startDate: DateTime.utc(2026, 8, 1),
            endDate: DateTime.utc(2026, 8, 30),
            status: MembershipStatus.expired,
          ),
        ],
        today: today,
        chosenStartDate: null,
        discountPaisa: 900000,
        amountPaidPaisa: 0,
      );

      expect(projection.discountPaisa, 500000);
      expect(projection.totalPaisa, 0);
      expect(projection.duePaisa, 0);
    });

    test('a part payment leaves the rest outstanding', () {
      final RenewalProjection projection = projectRenewal(
        plan: _plan(signupFeePaisa: 0),
        existing: <Membership>[
          _membership(
            startDate: DateTime.utc(2026, 8, 1),
            endDate: DateTime.utc(2026, 8, 30),
            status: MembershipStatus.expired,
          ),
        ],
        today: today,
        chosenStartDate: null,
        discountPaisa: paisaOrZero('500'),
        amountPaidPaisa: paisaOrZero('2000.50'),
      );

      expect(projection.discountPaisa, 50000);
      expect(projection.totalPaisa, 450000);
      expect(projection.amountPaidPaisa, 200050);
      expect(projection.duePaisa, 249950);
    });
  });
}
