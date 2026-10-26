// The docked bar on the five desk forms (register, renew, take a payment,
// refund, edit member) must stay a slim single row, whatever the phone or the
// text size. It was once a tall Total / Paid / Due card that sat on the
// screen while the form scrolled beneath it; the breakdown now lives in a
// normal Summary section at the end of the scrolling form.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/fees/fees_repository.dart' show FeeSetup;
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/members/member_edit_screen.dart';
import 'package:logfitness_flutter/features/members/register_member_screen.dart';
import 'package:logfitness_flutter/features/members/widgets/sale_form_kit.dart';
import 'package:logfitness_flutter/features/memberships/refund_payment_screen.dart';
import 'package:logfitness_flutter/features/settings/catalogue/fee_providers.dart';
import 'package:logfitness_flutter/features/payments/payment_queries.dart';
import 'package:logfitness_flutter/features/payments/record_payment_screen.dart';
import 'package:logfitness_flutter/features/payments/renew_membership_screen.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

/// The bar is one row: button (44) + padding (16) + the iPhone home-indicator
/// inset (34) is 94 at its very tallest on a notched phone with nothing
/// saved by the safe area, so the ceiling is set on the bar *with* a 34dp
/// inset: it must stay at or under 90.
const double _maxBarHeight = 90;

final MembershipPlan _plan = MembershipPlan(
  id: 'plan-1',
  orgId: 'org-1',
  name: 'Gym Only Quarterly Unlimited',
  planType: PlanType.time,
  durationDays: 90,
  sessionCount: null,
  pricePaisa: 600000,
  signupFeePaisa: 100000,
  branchIds: const <String>[],
  isActive: true,
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

final Invoice _invoice = Invoice(
  id: 'inv-1',
  orgId: 'org-1',
  branchId: 'branch-a',
  memberId: 'member-1',
  invoiceNo: 'INV-2026-000123',
  subtotalPaisa: 600000,
  discountPaisa: 0,
  totalPaisa: 600000,
  paidPaisa: 260000,
  duePaisa: 340000,
  status: InvoiceStatus.partial,
  issuedOn: DateTime.utc(2026, 9, 1),
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

final Member _member = Member(
  id: 'member-1',
  orgId: 'org-1',
  homeBranchId: 'branch-a',
  memberCode: 'M-0042',
  fullName: 'Anjali Shrestha',
  phone: '9800000000',
  status: MemberStatus.active,
  joinedOn: DateTime.utc(2026, 1, 4),
  createdAt: DateTime.utc(2026, 1, 4),
  updatedAt: DateTime.utc(2026, 1, 4),
);

final PaymentWithCollector _payment = PaymentWithCollector(
  payment: Payment(
    id: 'pay-1',
    orgId: 'org-1',
    branchId: 'branch-a',
    memberId: 'member-1',
    kind: PaymentKind.payment,
    amountPaisa: 400000,
    method: PaymentMethod.cash,
    paidAt: DateTime.utc(2026, 9, 1, 12, 30),
    createdAt: DateTime.utc(2026, 9, 1, 12, 30),
  ),
  collectorName: 'Ramesh',
);

Branch _branch() => Branch(
  id: 'branch-a',
  orgId: 'org-1',
  name: 'Lazimpat',
  status: BranchStatus.active,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

/// One desk form under test: how to mount it, and how to get it to show a
/// sale (so the bar carries its widest content).
class _Scenario {
  const _Scenario(
    this.name,
    this.screen, {
    this.prepare,
    this.hasSummary = true,
  });

  final String name;
  final Widget screen;
  final Future<void> Function(WidgetTester)? prepare;
  final bool hasSummary;
}

Future<void> _pickPlan(WidgetTester tester, String keyName) async {
  final Finder picker = find.byKey(ValueKey<String>(keyName));
  await tester.scrollUntilVisible(
    picker,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(picker);
  await tester.pumpAndSettle();
  await tester.tap(picker);
  await tester.pumpAndSettle();
  await tester.tap(find.text(_plan.name).last);
  await tester.pumpAndSettle();
}

final List<_Scenario> _scenarios = <_Scenario>[
  _Scenario(
    'register member',
    const RegisterMemberScreen(),
    prepare: (WidgetTester tester) async {
      final Finder toggle = find.byKey(
        const ValueKey<String>('register-sell-plan'),
      );
      await tester.scrollUntilVisible(
        toggle,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await _pickPlan(tester, 'register-plan-branch-a');
    },
  ),
  _Scenario(
    'renew membership',
    const RenewMembershipScreen(memberId: 'member-1', memberName: 'Anjali'),
    prepare: (WidgetTester tester) => _pickPlan(tester, 'renew-plan-branch-a'),
  ),
  const _Scenario(
    'record payment',
    RecordPaymentScreen(memberId: 'member-1', memberName: 'Anjali'),
  ),
  _Scenario('refund payment', RefundPaymentScreen(payment: _payment)),
  _Scenario(
    'edit member',
    MemberEditScreen(member: _member),
    hasSummary: false,
  ),
];

Future<void> _mount(WidgetTester tester, _Scenario scenario) async {
  final AppClaims claims = const AppClaims(
    orgId: 'org-1',
    staffId: 'staff-1',
    staffRole: StaffRole.manager,
    branchIds: <String>['branch-a'],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        claimsProvider.overrideWithValue(claims),
        principalProvider.overrideWithValue(
          AsyncValue<Principal>.data(Principal.staff(claims)),
        ),
        branchesProvider.overrideWith((ref) => <Branch>[_branch()]),
        feeSetupProvider.overrideWith((ref) async => FeeSetup.legacy),
        branchPlansProvider.overrideWith(
          (ref, String branchId) async => <MembershipPlan>[_plan],
        ),
        sellablePlansProvider.overrideWith(
          (ref, String branchId) async => <MembershipPlan>[_plan],
        ),
        memberMembershipsProvider.overrideWith(
          (ref, String memberId) async => const [],
        ),
        openInvoicesProvider.overrideWith(
          (ref, String memberId) async => <Invoice>[_invoice],
        ),
      ],
      child: MaterialApp(theme: appLightTheme, home: scenario.screen),
    ),
  );
  await tester.pumpAndSettle();
}

void _setView(WidgetTester tester, Size size, double textScale) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  // An iPhone with a home indicator: the bar has to absorb this inset and
  // still come in under the ceiling.
  tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

void main() {
  const List<Size> sizes = <Size>[Size(390, 844), Size(320, 640)];
  const List<double> scales = <double>[1.0, 2.0];

  for (final _Scenario scenario in _scenarios) {
    for (final Size size in sizes) {
      for (final double scale in scales) {
        testWidgets(
          '${scenario.name}: slim docked bar at ${size.width.toInt()}x'
          '${size.height.toInt()}, text ${scale}x',
          (WidgetTester tester) async {
            _setView(tester, size, scale);
            await _mount(tester, scenario);
            await scenario.prepare?.call(tester);

            final Finder bar = find.byKey(SaleSummaryBar.dockedBarKey);
            expect(bar, findsOneWidget);
            expect(
              tester.getSize(bar).height,
              lessThanOrEqualTo(_maxBarHeight),
            );
            // The bar spans the screen and nothing in it overflows.
            expect(tester.getSize(bar).width, size.width);
            expect(tester.getRect(bar).bottom, lessThanOrEqualTo(size.height));
            expect(tester.takeException(), isNull);

            // The breakdown is not in the bar.
            expect(
              find.descendant(of: bar, matching: find.text('Breakdown')),
              findsNothing,
            );

            if (scenario.hasSummary) {
              // It is a section of the scrolling form instead.
              final Finder summary = find.text('Summary', skipOffstage: false);
              expect(summary, findsOneWidget);
              expect(
                find.ancestor(of: summary, matching: find.byType(Scrollable)),
                findsWidgets,
              );
              // And it scrolls clear of the bar, never beneath it.
              await tester.ensureVisible(summary);
              await tester.pumpAndSettle();
              expect(
                tester.getRect(summary).bottom,
                lessThanOrEqualTo(tester.getRect(bar).top),
              );
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('keyboard up: only the primary button is left in the bar', (
    WidgetTester tester,
  ) async {
    _setView(tester, const Size(390, 844), 1.0);
    await _mount(tester, _scenarios[2]);

    final Finder bar = find.byKey(SaleSummaryBar.dockedBarKey);
    expect(
      find.descendant(of: bar, matching: find.textContaining('NPR')),
      findsOneWidget,
      reason: 'the key figure shows while not typing',
    );

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: bar, matching: find.textContaining('NPR')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: bar,
        matching: find.byKey(const ValueKey<String>('payment-submit')),
      ),
      findsOneWidget,
    );
    expect(tester.getSize(bar).height, lessThanOrEqualTo(_maxBarHeight));
    expect(tester.takeException(), isNull);
  });
}
