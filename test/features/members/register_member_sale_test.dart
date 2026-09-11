// The optional sale on the registration form, checked where it can take money
// that never changed hands -- or send a payload the RPC refuses.
//
// Three of the four tests below are regressions from 2026-09-11:
//  * the plan picker was empty for an owner, because the branch options came
//    off a claim that is empty by design for that role;
//  * the amount box was free-typed with no paid/part/unpaid choice, so the
//    fastest path through the form recorded a payment nobody made;
//  * a discount was sent without a reason, which `register_member` refuses
//    outright (`20260910130100_discount_reason_rpcs.sql`).
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/data/orgs/orgs_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/common/payment_status_choice.dart';
import 'package:logfitness_flutter/features/members/register_member_screen.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

MembershipPlan _plan(
  String id,
  String name, {
  int pricePaisa = 300000,
  int signupFeePaisa = 0,
}) => MembershipPlan(
  id: id,
  orgId: 'org-1',
  name: name,
  planType: PlanType.time,
  durationDays: 30,
  sessionCount: null,
  pricePaisa: pricePaisa,
  signupFeePaisa: signupFeePaisa,
  branchIds: const <String>[],
  isActive: true,
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

Branch _branch(String id, String name) => Branch(
  id: id,
  orgId: 'org-1',
  name: name,
  status: BranchStatus.active,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

class _FakePlansRepository implements PlansRepository {
  _FakePlansRepository({this.plans = const <MembershipPlan>[]});

  final List<MembershipPlan> plans;
  String? lastBranchId;

  @override
  Future<List<MembershipPlan>> listPlansForBranch(String branchId) async {
    lastBranchId = branchId;
    return plans;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakeOrgsRepository implements OrgsRepository {
  _FakeOrgsRepository({this.feePaisa = 0});

  final int feePaisa;

  @override
  Future<int> standardSignupFeePaisa(String orgId) async => feePaisa;

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakeMembersRepository implements MembersRepository {
  Map<String, Object?>? lastCall;

  @override
  Future<RegisterMemberResult> registerMember({
    required String fullName,
    required String phone,
    required String homeBranchId,
    String? email,
    DateTime? dateOfBirth,
    MemberGender? gender,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    String? planId,
    int discountPaisa = 0,
    int amountPaidPaisa = 0,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    DateTime? startDate,
    DiscountReason? discountReason,
    String? discountNote,
  }) async {
    lastCall = <String, Object?>{
      'homeBranchId': homeBranchId,
      'planId': planId,
      'discountPaisa': discountPaisa,
      'discountReason': discountReason,
      'discountNote': discountNote,
      'amountPaidPaisa': amountPaidPaisa,
      'method': method,
      'referenceNo': referenceNo,
    };
    return const RegisterMemberResult(
      memberId: 'm-1',
      memberCode: 'GT-0001',
      sold: true,
    );
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

AppClaims _claims(StaffRole role, List<String> branchIds) => AppClaims(
  orgId: 'org-1',
  staffId: 'staff-1',
  staffRole: role,
  branchIds: branchIds,
);

Future<void> _pump(
  WidgetTester tester, {
  required _FakeMembersRepository members,
  required _FakePlansRepository plans,
  StaffRole role = StaffRole.owner,
  List<String> claimedBranches = const <String>[],
  List<Branch> branches = const <Branch>[],
  int orgFeePaisa = 0,
}) async {
  final claims = _claims(role, claimedBranches);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        claimsProvider.overrideWithValue(claims),
        principalProvider.overrideWithValue(
          AsyncValue<Principal>.data(Principal.staff(claims)),
        ),
        branchesProvider.overrideWith((ref) => branches),
        plansRepositoryProvider.overrideWithValue(plans),
        membersRepositoryProvider.overrideWithValue(members),
        orgsRepositoryProvider.overrideWithValue(
          _FakeOrgsRepository(feePaisa: orgFeePaisa),
        ),
      ],
      child: MaterialApp(
        theme: appLightTheme,
        home: const RegisterMemberScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Fills the two required member fields and switches the sale on.
Future<void> _startSale(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Full name'),
    'Anjali Shrestha',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Phone'),
    '9800000000',
  );
  final toggle = find.byKey(const ValueKey<String>('register-sell-plan'));
  await tester.scrollUntilVisible(
    toggle,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

Future<void> _pickPlan(WidgetTester tester, String name) async {
  final picker = find.byKey(const ValueKey<String>('register-plan-branch-a'));
  await tester.scrollUntilVisible(
    picker,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(picker);
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  final submit = find.byKey(const ValueKey<String>('register-submit'));
  await tester.scrollUntilVisible(
    submit,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an owner is offered the plans of the branch they pick', (
    tester,
  ) async {
    // The 2026-09-11 bug: an owner's `branch_ids` claim is empty, the form
    // therefore resolved no home branch, and the catalogue was never queried
    // at all -- an empty picker with nothing to say why.
    final plans = _FakePlansRepository(
      plans: <MembershipPlan>[_plan('p-1', 'Gym Only')],
    );
    await _pump(
      tester,
      members: _FakeMembersRepository(),
      plans: plans,
      branches: <Branch>[_branch('branch-a', 'Thamel')],
    );

    await _startSale(tester);

    expect(plans.lastBranchId, 'branch-a');
    expect(find.text('Gym Only'), findsNothing, reason: 'not picked yet');

    await _pickPlan(tester, 'Gym Only');
    expect(find.text('Gym Only'), findsOneWidget);
  });

  testWidgets('paid in full prefills the price, and records exactly that', (
    tester,
  ) async {
    final members = _FakeMembersRepository();
    await _pump(
      tester,
      members: members,
      plans: _FakePlansRepository(
        plans: <MembershipPlan>[
          _plan('p-1', 'Gym Only', pricePaisa: 300000, signupFeePaisa: 50000),
        ],
      ),
      branches: <Branch>[_branch('branch-a', 'Thamel')],
    );

    await _startSale(tester);
    await _pickPlan(tester, 'Gym Only');

    // Price plus the joining fee, which a member being registered always pays.
    final amount = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('register-amount-paid')),
        matching: find.byType(TextField),
      ),
    );
    expect(amount.controller?.text, '3500');
    expect(amount.readOnly, isTrue, reason: 'full is not a typed figure');

    await _submit(tester);

    expect(members.lastCall!['amountPaidPaisa'], 350000);
    expect(members.lastCall!['planId'], 'p-1');
    expect(members.lastCall!['discountPaisa'], 0);
    expect(members.lastCall!['discountReason'], isNull);
  });

  testWidgets('unpaid sends no money at all, and hides the amount', (
    tester,
  ) async {
    final members = _FakeMembersRepository();
    await _pump(
      tester,
      members: members,
      plans: _FakePlansRepository(
        plans: <MembershipPlan>[_plan('p-1', 'Gym Only')],
      ),
      branches: <Branch>[_branch('branch-a', 'Thamel')],
    );

    await _startSale(tester);
    await _pickPlan(tester, 'Gym Only');

    final unpaid = find.byKey(paymentStatusKey(PaymentStatus.unpaid));
    await tester.scrollUntilVisible(
      unpaid,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(unpaid);
    await tester.pumpAndSettle();

    // The amount is gone, not merely emptied: an unmounted field cannot be
    // left holding a figure nobody meant to send.
    expect(
      find.byKey(const ValueKey<String>('register-amount-paid')),
      findsNothing,
    );

    await _submit(tester);

    expect(members.lastCall!['amountPaidPaisa'], 0);
    expect(members.lastCall!['referenceNo'], isNull);
    expect(members.lastCall!['planId'], 'p-1');
  });

  testWidgets('a discount cannot be sent without the reason the RPC demands', (
    tester,
  ) async {
    final members = _FakeMembersRepository();
    await _pump(
      tester,
      members: members,
      plans: _FakePlansRepository(
        plans: <MembershipPlan>[_plan('p-1', 'Gym Only', pricePaisa: 300000)],
      ),
      branches: <Branch>[_branch('branch-a', 'Thamel')],
    );

    await _startSale(tester);
    await _pickPlan(tester, 'Gym Only');

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Discount'),
      '500',
    );
    await tester.pumpAndSettle();

    // Refused here rather than by Postgres: `register_member` raises
    // `check_violation` for a discount with no reason, which reaches the desk
    // as a failed registration rather than a missing field.
    await _submit(tester);
    expect(members.lastCall, isNull);

    // Upwards: the failed submit left the form scrolled to the button, and
    // the reason picker sits above it.
    final reason = find.byKey(
      const ValueKey<String>('register-discount-reason'),
    );
    await tester.scrollUntilVisible(
      reason,
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(reason);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student').last);
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(members.lastCall!['discountPaisa'], 50000);
    expect(members.lastCall!['discountReason'], DiscountReason.student);
    // Paid in full follows the discount down, rather than leaving the old
    // full price sitting in a read-only box.
    expect(members.lastCall!['amountPaidPaisa'], 250000);
  });
}
