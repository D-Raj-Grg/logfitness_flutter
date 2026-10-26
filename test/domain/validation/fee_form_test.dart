// The add/edit fee form's rules. Same sentences as the console's
// `lib/validation/fees.ts`, so a fee refused on one surface reads the same on
// the other.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/validation/fee_form.dart';

FeeValidation _validate({
  String name = 'Registration fee',
  String amount = '500',
  FeeChargeRule rule = FeeChargeRule.once,
  bool allPlans = true,
  List<String> planIds = const <String>[],
  bool isActive = true,
}) => validateFee(
  name: name,
  amount: amount,
  chargeRule: rule,
  allPlans: allPlans,
  planIds: planIds,
  isActive: isActive,
);

void main() {
  test('a valid fee becomes integer paisa and a clean row', () {
    final FeeValidation result = _validate(
      name: '  Registration fee ',
      amount: '500.50',
    );
    expect(result.isValid, isTrue);
    expect(result.values!.toRow(), <String, dynamic>{
      'name': 'Registration fee',
      'charge_rule': 'once',
      'amount_paisa': 50050,
      'all_plans': true,
      'plan_ids': <String>[],
      'is_active': true,
    });
  });

  test('chosen plans are kept, once each', () {
    final FeeValidation result = _validate(
      allPlans: false,
      planIds: <String>['p-1', 'p-1', 'p-2'],
    );
    expect(result.values!.toRow()['plan_ids'], <String>['p-1', 'p-2']);
    expect(result.values!.toRow()['all_plans'], false);
  });

  test('all plans drops any stray plan list', () {
    final FeeValidation result = _validate(planIds: <String>['p-1']);
    expect(result.values!.toRow()['plan_ids'], <String>[]);
  });

  test('the every-sale rule goes over the wire as every_sale', () {
    final FeeValidation result = _validate(rule: FeeChargeRule.everySale);
    expect(result.values!.toRow()['charge_rule'], 'every_sale');
  });

  test('name is required and capped at 120', () {
    expect(_validate(name: '  ').errors[FeeField.name], 'Name is required');
    expect(
      _validate(name: 'x' * 121).errors[FeeField.name],
      'Name is too long',
    );
    expect(_validate(name: 'x' * 120).isValid, isTrue);
  });

  test('amount: required, numeric, above zero, below the ceiling', () {
    expect(_validate(amount: '').errors[FeeField.amount], 'Enter an amount');
    expect(
      _validate(amount: 'abc').errors[FeeField.amount],
      'Enter a valid amount',
    );
    expect(
      _validate(amount: '0').errors[FeeField.amount],
      'Amount must be more than zero',
    );
    expect(
      _validate(amount: '-5').errors[FeeField.amount],
      'Amount cannot be negative',
    );
    expect(
      _validate(amount: '100000.01').errors[FeeField.amount],
      'That fee looks too large',
    );
    expect(_validate(amount: '100000').isValid, isTrue);
  });

  test('a fee on chosen plans needs at least one plan', () {
    final FeeValidation result = _validate(allPlans: false);
    expect(result.errors[FeeField.planIds], kFeeNeedsPlans);
    expect(result.values, isNull);
  });

  test('values are absent whenever there is an error', () {
    expect(_validate(name: '').values, isNull);
  });

  test('the rule is described in words an owner uses', () {
    expect(feeRuleLabel(FeeChargeRule.once), 'Once, on the first membership');
    expect(feeRuleLabel(FeeChargeRule.everySale), 'On every sale');
  });
}
