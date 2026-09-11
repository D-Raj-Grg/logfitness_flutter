// What each role is *offered* on the action panel, and what a refusal looks
// like when the database disagrees with that offer.
//
// The first group is PLANNING.md §4 rendered: freezes, cancellations and
// refunds belong to `manager` and up, so a front desk is offered none of
// them. The second group is the reason the first one is not enough -- the
// gate is UX only (CLAUDE.md), the database refuses independently, and its
// refusal has to arrive on screen looking like a refusal.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so override lists stay
// untyped literals (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/memberships/membership_action_panel.dart';
import 'package:logfitness_flutter/features/memberships/refund_payment_screen.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Member _member({MemberStatus status = MemberStatus.active}) => Member(
      id: 'member-1',
      orgId: 'org-1',
      homeBranchId: 'branch-1',
      memberCode: 'M-0042',
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      status: status,
      joinedOn: DateTime.utc(2026, 1, 4),
      createdAt: DateTime.utc(2026, 1, 4),
      updatedAt: DateTime.utc(2026, 1, 4),
    );

Membership _membership({
  MembershipStatus status = MembershipStatus.active,
}) =>
    Membership(
      id: 'ms-1',
      orgId: 'org-1',
      branchId: 'branch-1',
      memberId: 'member-1',
      planId: 'plan-1',
      planName: 'Monthly',
      planType: PlanType.time,
      startDate: DateTime.utc(2026, 9, 1),
      endDate: DateTime.utc(2026, 10, 1),
      pricePaisa: 400000,
      discountPaisa: 0,
      signupFeePaisa: 0,
      status: status,
      frozenDays: 0,
      createdAt: DateTime.utc(2026, 9, 1),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

PaymentWithCollector _payment({
  PaymentKind kind = PaymentKind.payment,
  int amountPaisa = 400000,
}) =>
    PaymentWithCollector(
      payment: Payment(
        id: 'pay-1',
        orgId: 'org-1',
        branchId: 'branch-1',
        memberId: 'member-1',
        kind: kind,
        amountPaisa: amountPaisa,
        method: PaymentMethod.cash,
        paidAt: DateTime.utc(2026, 9, 1, 12, 30),
        createdAt: DateTime.utc(2026, 9, 1, 12, 30),
      ),
      collectorName: 'Ramesh',
    );

class _FakePaymentsRepository implements PaymentsRepository {
  Object? error;
  int refundCalls = 0;

  @override
  Future<RefundPaymentResult> refundPayment({
    required String paymentId,
    required int amountPaisa,
    required String reason,
    PaymentMethod? method,
    String? referenceNo,
  }) async {
    refundCalls++;
    if (error != null) {
      throw error!;
    }
    return RefundPaymentResult(refundId: 'r-1', amountPaisa: -amountPaisa);
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

Widget _panelUnder(
  StaffRole role, {
  Member? member,
  Membership? membership,
  List<PaymentWithCollector> payments = const <PaymentWithCollector>[],
}) {
  return ProviderScope(
    overrides: [
      // The capability set is what the panel reads. Overriding it directly
      // keeps this a test of §4's consequences rather than of the auth stack.
      staffCapabilitiesProvider.overrideWithValue(capabilitiesFor(role)),
    ],
    child: MaterialApp(
      home: Scaffold(
        // The panel is a Column by design, so it composes into the member
        // detail screen's scroll view. Mounted here the way that host will
        // mount it -- a bare Column of eight three-line tiles overflows a
        // phone screen, which is a rendering error rather than a cosmetic
        // one.
        body: SingleChildScrollView(
          child: MembershipActionPanel(
            member: member ?? _member(),
            membership: membership ?? _membership(),
            payments: payments,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    // Tall enough that every action is laid out and hit-testable. The panel
    // is scrolled by its host in the real app; this stands in for that.
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
        .first;
    view.physicalSize = const Size(1000, 3000);
    view.devicePixelRatio = 1;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  group('PLANNING.md §4, rendered', () {
    testWidgets('a front desk is offered no corrective action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.frontDesk,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      // Everything that moves money or voids something paid for stays
      // manager-and-up.
      expect(find.byKey(refundActionKey), findsNothing);
      expect(find.byKey(reverseActionKey), findsNothing);
      expect(find.byKey(cancelActionKey), findsNothing);
      expect(find.byKey(freezeActionKey), findsNothing);
      expect(find.byKey(adjustDatesActionKey), findsNothing);
    });

    testWidgets('a front desk can record that a member has left', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.frontDesk,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      // Decided 2026-09-11: the database already permits this
      // (`jwt_can_serve_members` is {owner, manager, front_desk}), the console
      // already allows it, and an unrecorded departure leaves someone counted
      // as an active member — inflating the churn numbers the chain reports
      // exist to get right.
      expect(find.byKey(markLeftActionKey), findsOneWidget);
    });

    testWidgets('a trainer is offered nothing here either',
        (WidgetTester tester) async {
      // §4 gives a trainer their own classes and nothing off the front desk
      // row, let alone off the manager row.
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.trainer,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      expect(find.byKey(refundActionKey), findsNothing);
      expect(find.byKey(reverseActionKey), findsNothing);
      expect(find.byKey(cancelActionKey), findsNothing);
    });

    testWidgets('a manager is offered all of them',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      expect(find.byKey(freezeActionKey), findsOneWidget);
      expect(find.byKey(cancelActionKey), findsOneWidget);
      expect(find.byKey(adjustDatesActionKey), findsOneWidget);
      expect(find.byKey(markLeftActionKey), findsOneWidget);
      expect(find.byKey(refundActionKey), findsOneWidget);
      expect(find.byKey(reverseActionKey), findsOneWidget);
    });

    testWidgets('an owner is offered all of them too',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.owner,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      expect(find.byKey(refundActionKey), findsOneWidget);
      expect(find.byKey(cancelActionKey), findsOneWidget);
    });
  });

  group('refund and reversal are not the same button', () {
    testWidgets('both are offered, and each says what it means',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      // Two separate entries. A reversal is not a refund: one says cash left
      // the drawer, the other says a note rung up never arrived.
      expect(find.byKey(refundActionKey), findsOneWidget);
      expect(find.byKey(reverseActionKey), findsOneWidget);

      expect(find.textContaining('Money goes back to the member'),
          findsOneWidget);
      expect(find.textContaining('never arrived'), findsOneWidget);
      expect(find.textContaining('this is not a refund'), findsOneWidget);
    });

    testWidgets('the refund entry says it never deletes the original',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      // CLAUDE.md: financial history is append-only. The panel has to say so,
      // because "refund" reads like "undo" otherwise.
      expect(
        find.textContaining('negative line'),
        findsOneWidget,
      );
    });

    testWidgets('a refund cannot be refunded', (WidgetTester tester) async {
      // Correcting a correction is the original entry's problem. With only a
      // refund row in history there is nothing correctable.
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[
            _payment(kind: PaymentKind.refund, amountPaisa: -400000),
          ],
        ),
      );

      final ListTile refund =
          tester.widget<ListTile>(find.byKey(refundActionKey));
      expect(refund.enabled, isFalse);
      expect(find.textContaining('nothing to refund'), findsOneWidget);
    });

    testWidgets('a reversal row is not correctable either',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[
            _payment(kind: PaymentKind.reversal, amountPaisa: -400000),
          ],
        ),
      );

      final ListTile reverse =
          tester.widget<ListTile>(find.byKey(reverseActionKey));
      expect(reverse.enabled, isFalse);
    });
  });

  group('the confirmation says what will happen', () {
    testWidgets('cancelling states the date it counts from and that money stays',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      await tester.tap(find.byKey(cancelActionKey));
      await tester.pumpAndSettle();

      // A cancellation counts on the day it was cancelled, not on the end
      // date the row still carries -- the thing a desk gets wrong.
      expect(
        find.textContaining('counts as cancelled on today’s date'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Money already taken stays on the invoice'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Nothing is refunded by cancelling'),
        findsOneWidget,
      );
    });

    testWidgets('a cancellation will not submit without a reason',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      await tester.tap(find.byKey(cancelActionKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(confirmSubmitKey));
      await tester.pumpAndSettle();

      // Still on the dialog, with the rule stated.
      expect(find.text('A reason is required.'), findsOneWidget);
    });

    testWidgets('freezing states that the paused days come back',
        (WidgetTester tester) async {
      await tester.pumpWidget(_panelUnder(StaffRole.manager));

      await tester.tap(find.byKey(freezeActionKey));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('days paused are added back on'),
        ),
        findsOneWidget,
      );
      // A freeze takes a note, not a date range -- the RPC stamps the start
      // from the org's today and measures the end at unfreeze.
      expect(find.text('Note (optional)'), findsOneWidget);
    });

    testWidgets('reversing asks what arrived, not what goes back',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      await tester.tap(find.byKey(reverseActionKey));
      await tester.pumpAndSettle();

      expect(find.text('Payment never received'), findsOneWidget);
      expect(find.byKey(reverseWholeKey), findsOneWidget);
      expect(find.byKey(reversePartKey), findsOneWidget);
      // No payment method is collected, because no money moved.
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('Nothing left the drawer'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a reversal will not submit without a reason',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          payments: <PaymentWithCollector>[_payment()],
        ),
      );

      await tester.tap(find.byKey(reverseActionKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(reverseSubmitKey));
      await tester.pumpAndSettle();

      expect(find.text('A reason is required.'), findsOneWidget);
    });

    testWidgets('reactivating does not promise they become active',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          member: _member(status: MemberStatus.left),
          membership: _membership(status: MembershipStatus.expired),
        ),
      );

      await tester.tap(find.byKey(reactivateActionKey));
      await tester.pumpAndSettle();

      // `members.status` is trigger-derived; a member with no live
      // membership comes back expired.
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('show as expired until a new plan'),
        ),
        findsOneWidget,
      );
    });
  });

  group('status decides what is on offer', () {
    testWidgets('a frozen membership offers unfreeze, not freeze',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          membership: _membership(status: MembershipStatus.frozen),
        ),
      );

      expect(find.byKey(unfreezeActionKey), findsOneWidget);
      expect(find.byKey(freezeActionKey), findsNothing);
    });

    testWidgets('a cancelled membership offers neither freeze nor cancel',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          membership: _membership(status: MembershipStatus.cancelled),
        ),
      );

      expect(find.byKey(freezeActionKey), findsNothing);
      expect(find.byKey(cancelActionKey), findsNothing);
      // And not adjust dates either -- there is no live window to correct.
      expect(find.byKey(adjustDatesActionKey), findsNothing);
    });

    testWidgets('a member who has left offers reactivate, not mark left',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _panelUnder(
          StaffRole.manager,
          member: _member(status: MemberStatus.left),
        ),
      );

      expect(find.byKey(reactivateActionKey), findsOneWidget);
      expect(find.byKey(markLeftActionKey), findsNothing);
    });
  });

  group('the refund screen', () {
    Widget refundScreen(_FakePaymentsRepository repository) => ProviderScope(
          overrides: [
            paymentsRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            home: RefundPaymentScreen(payment: _payment()),
          ),
        );

    testWidgets('shows the payment it is correcting',
        (WidgetTester tester) async {
      await tester.pumpWidget(refundScreen(_FakePaymentsRepository()));

      // The desk has to be able to see which entry this corrects before
      // agreeing to it.
      expect(find.byKey(refundOriginalPaymentKey), findsOneWidget);
      expect(find.text('NPR 4,000'), findsWidgets);
      expect(find.textContaining('Taken by Ramesh'), findsOneWidget);
      expect(
        find.textContaining('The original payment stays on the books'),
        findsOneWidget,
      );
    });

    testWidgets('a refund requires a reason', (WidgetTester tester) async {
      final repository = _FakePaymentsRepository();
      await tester.pumpWidget(refundScreen(repository));

      await tester.tap(find.byKey(refundSubmitKey));
      await tester.pumpAndSettle();

      expect(find.text('A reason is required.'), findsOneWidget);
      // And nothing was sent.
      expect(repository.refundCalls, 0);
    });

    testWidgets('will not refund more than was taken',
        (WidgetTester tester) async {
      final repository = _FakePaymentsRepository();
      await tester.pumpWidget(refundScreen(repository));

      await tester.enterText(find.byKey(refundAmountFieldKey), '9000');
      await tester.enterText(find.byKey(refundReasonFieldKey), 'Paid twice');
      await tester.tap(find.byKey(refundSubmitKey));
      await tester.pumpAndSettle();

      expect(find.textContaining('more than the'), findsOneWidget);
      expect(repository.refundCalls, 0);
    });

    testWidgets('a refusal renders as a refusal, not a generic error',
        (WidgetTester tester) async {
      // The gate on the panel is UX only. If the database refuses anyway --
      // and it is the only real boundary -- the desk has to be told it was
      // refused, not that "something went wrong". This is the 2026-09-07
      // console bug, which was a swallowed 42501.
      final repository = _FakePaymentsRepository()
        ..error = const PostgrestException(
          message: 'permission denied for function refund_payment',
          code: '42501',
        );
      await tester.pumpWidget(refundScreen(repository));

      await tester.enterText(find.byKey(refundReasonFieldKey), 'Paid twice');
      await tester.tap(find.byKey(refundSubmitKey));
      await tester.pumpAndSettle();

      // The refusal's own sentence, not a Dart exception and not a paraphrase.
      expect(
        find.textContaining('outside the branches or the role'),
        findsOneWidget,
      );
      // And the treatment that distinguishes it: the block icon, which the
      // generic failure branch never uses.
      expect(find.byIcon(Icons.block), findsOneWidget);
      // Still on the screen, so nothing reads as having succeeded.
      expect(find.byKey(refundSubmitKey), findsOneWidget);
    });

    testWidgets('offline says nothing was saved', (WidgetTester tester) async {
      // Writes are never queued locally (PLANNING.md scope), so this must not
      // read as "will sync later".
      final repository = _FakePaymentsRepository()
        ..error = const PostgrestException(message: 'boom', code: 'XXYY0');
      await tester.pumpWidget(refundScreen(repository));

      await tester.enterText(find.byKey(refundReasonFieldKey), 'Paid twice');
      await tester.tap(find.byKey(refundSubmitKey));
      await tester.pumpAndSettle();

      // An unmapped code still surfaces the database's own words rather than
      // silence.
      expect(find.textContaining('boom'), findsOneWidget);
    });

    testWidgets('a successful refund reports the amount and pops',
        (WidgetTester tester) async {
      final repository = _FakePaymentsRepository();
      await tester.pumpWidget(refundScreen(repository));

      await tester.enterText(find.byKey(refundReasonFieldKey), 'Paid twice');
      await tester.tap(find.byKey(refundSubmitKey));
      await tester.pump();
      await tester.pump();

      expect(repository.refundCalls, 1);
      // Reported with the sign flipped: "NPR 4,000 refunded" is the sentence,
      // even though the row written is negative.
      expect(find.textContaining('NPR 4,000 refunded'), findsOneWidget);
    });
  });

  group('the failure treatment is the shared one', () {
    testWidgets('FailureView keys the refusal distinctly',
        (WidgetTester tester) async {
      // Guards the assumption the panel leans on: a refusal is not styled the
      // same as an ordinary error anywhere in this app.
      expect(refusedFailureKey, isNot(equals(failureViewKey)));
    });
  });
}
