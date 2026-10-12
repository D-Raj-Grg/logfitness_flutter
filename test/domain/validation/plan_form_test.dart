// The plan form's rules, checked without a widget. Sentences and rules are
// the console's (`lib/validation/plans.ts`, `plan-scope.ts`).
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/validation/plan_form.dart';

const String _a = 'branch-a';
const String _b = 'branch-b';
const String _c = 'branch-c';

PlanValidation _validate({
  String name = 'Monthly',
  String description = '',
  PlanType type = PlanType.time,
  String days = '30',
  String sessions = '',
  String price = '1500',
  String fee = '',
  List<String> branches = const <String>[],
  StaffRole role = StaffRole.owner,
  List<String> mine = const <String>[],
}) => validatePlan(
  name: name,
  description: description,
  planType: type,
  durationDays: days,
  sessionCount: sessions,
  price: price,
  signupFee: fee,
  branchIds: branches,
  role: role,
  actorBranchIds: mine,
);

void main() {
  group('canScopePlan', () {
    test('an owner may scope a plan anywhere, including org-wide', () {
      expect(
        canScopePlan(StaffRole.owner, const <String>[], const <String>[]),
        isTrue,
      );
      expect(
        canScopePlan(StaffRole.owner, const <String>[], const <String>[_c]),
        isTrue,
      );
    });

    test('a manager needs a non-empty subset of their own branches', () {
      const mine = <String>[_a, _b];
      expect(canScopePlan(StaffRole.manager, mine, const <String>[_a]), isTrue);
      expect(
        canScopePlan(StaffRole.manager, mine, const <String>[_a, _b]),
        isTrue,
      );
      expect(canScopePlan(StaffRole.manager, mine, const <String>[]), isFalse);
      expect(
        canScopePlan(StaffRole.manager, mine, const <String>[_a, _c]),
        isFalse,
      );
    });

    test('front desk follows the manager rule; a trainer never may', () {
      expect(
        canScopePlan(
          StaffRole.frontDesk,
          const <String>[_a],
          const <String>[_a],
        ),
        isTrue,
      );
      expect(
        canScopePlan(StaffRole.frontDesk, const <String>[_a], const <String>[]),
        isFalse,
      );
      expect(
        canScopePlan(StaffRole.trainer, const <String>[_a], const <String>[_a]),
        isFalse,
      );
    });
  });

  group('validatePlan', () {
    test('a valid time plan becomes integer paisa and a clean row', () {
      final r = _validate(
        price: '1,500.50',
        fee: '200',
        description: '  Gym floor ',
      );
      expect(r.isValid, isTrue);
      final v = r.values!;
      expect(v.pricePaisa, 150050);
      expect(v.signupFeePaisa, 20000);
      expect(v.durationDays, 30);
      expect(v.sessionCount, isNull);
      expect(v.description, 'Gym floor');
      expect(v.toRow(), <String, dynamic>{
        'name': 'Monthly',
        'description': 'Gym floor',
        'plan_type': 'time',
        'duration_days': 30,
        'session_count': null,
        'price_paisa': 150050,
        'signup_fee_paisa': 20000,
        'branch_ids': <String>[],
        'is_active': true,
      });
    });

    test('a blank joining fee is zero and a blank description is null', () {
      final v = _validate().values!;
      expect(v.signupFeePaisa, 0);
      expect(v.description, isNull);
    });

    test('name is required and capped at 120', () {
      expect(_validate(name: '   ').errors[PlanField.name], 'Name is required');
      expect(
        _validate(name: 'x' * 121).errors[PlanField.name],
        'Name is too long',
      );
      expect(_validate(name: 'x' * 120).isValid, isTrue);
    });

    test('description is capped at 500', () {
      expect(
        _validate(description: 'x' * 501).errors[PlanField.description],
        isNotNull,
      );
      expect(_validate(description: 'x' * 500).isValid, isTrue);
    });

    test('price: required, numeric, not negative', () {
      expect(_validate(price: '').errors[PlanField.price], 'Enter an amount');
      expect(
        _validate(price: 'abc').errors[PlanField.price],
        'Enter a valid amount',
      );
      expect(
        _validate(price: '-5').errors[PlanField.price],
        'Amount cannot be negative',
      );
      expect(
        _validate(price: 'Infinity').errors[PlanField.price],
        'Enter a valid amount',
      );
      expect(_validate(price: '0').isValid, isTrue);
    });

    test('joining fee: the same rules, but blank is allowed', () {
      expect(
        _validate(fee: '-1').errors[PlanField.signupFee],
        'Amount cannot be negative',
      );
      expect(
        _validate(fee: 'x').errors[PlanField.signupFee],
        'Enter a valid amount',
      );
    });

    test('a time plan needs a duration in days', () {
      expect(
        _validate(days: '').errors[PlanField.durationDays],
        'A time plan needs a duration in days',
      );
      expect(_validate(days: '0').errors[PlanField.durationDays], isNotNull);
      expect(_validate(days: '1.5').errors[PlanField.durationDays], isNotNull);
    });

    test('a time plan drops any stray session count', () {
      expect(_validate(sessions: '10').values!.sessionCount, isNull);
    });

    test('a session pack needs sessions; validity days are optional', () {
      final missing = _validate(type: PlanType.sessionPack, days: '');
      expect(
        missing.errors[PlanField.sessionCount],
        'A session pack needs a session count',
      );
      expect(missing.errors.containsKey(PlanField.durationDays), isFalse);

      final ok = _validate(
        type: PlanType.sessionPack,
        days: '',
        sessions: '10',
      );
      expect(ok.isValid, isTrue);
      expect(ok.values!.sessionCount, 10);
      expect(ok.values!.durationDays, isNull);

      final withValidity = _validate(
        type: PlanType.sessionPack,
        days: '90',
        sessions: '10',
      );
      expect(withValidity.values!.durationDays, 90);
    });

    test('a non-owner must pick branches, and only their own', () {
      const mine = <String>[_a, _b];
      final none = _validate(role: StaffRole.manager, mine: mine);
      expect(none.errors[PlanField.branchIds], kPlanOutOfScope);
      final foreign = _validate(
        role: StaffRole.manager,
        mine: mine,
        branches: const <String>[_a, _c],
      );
      expect(foreign.errors[PlanField.branchIds], kPlanOutOfScope);
      final fine = _validate(
        role: StaffRole.manager,
        mine: mine,
        branches: const <String>[_b],
      );
      expect(fine.isValid, isTrue);
      expect(fine.values!.branchIds, <String>[_b]);
    });

    test('an owner may leave branches empty (every branch)', () {
      expect(_validate().isValid, isTrue);
    });

    test('values are absent whenever there is an error', () {
      expect(_validate(name: '').values, isNull);
    });
  });
}
