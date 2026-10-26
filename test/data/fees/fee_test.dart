// One row of `public.fees` in, one `Fee` out.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/fees/fee.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _row([Map<String, dynamic> over = const <String, dynamic>{}]) =>
    <String, dynamic>{
      'id': 'fee-1',
      'org_id': 'org-1',
      'name': 'Registration fee',
      'charge_rule': 'once',
      'amount_paisa': 50000,
      'all_plans': false,
      'plan_ids': <dynamic>['p-1', 'p-2'],
      'is_active': true,
      'sort_order': 0,
      'created_at': '2026-10-27T00:00:00Z',
      'updated_at': '2026-10-27T00:00:00Z',
      ...over,
    };

void main() {
  test('maps a realistic PostgREST row', () {
    final Fee fee = Fee.fromRow(_row());
    expect(fee.name, 'Registration fee');
    expect(fee.chargeRule, FeeChargeRule.once);
    expect(fee.amountPaisa, 50000);
    expect(fee.planIds, <String>['p-1', 'p-2']);
    expect(fee.isActive, isTrue);
  });

  test('reads the every_sale rule', () {
    final Fee fee = Fee.fromRow(_row(<String, dynamic>{'charge_rule': 'every_sale'}));
    expect(fee.chargeRule, FeeChargeRule.everySale);
  });

  test('an unknown rule fails loudly rather than defaulting', () {
    expect(
      () => Fee.fromRow(_row(<String, dynamic>{'charge_rule': 'sometimes'})),
      throwsA(isA<Object>()),
    );
  });

  test('a fee on for all plans applies to a plan it does not list', () {
    final Fee fee = Fee.fromRow(
      _row(<String, dynamic>{'all_plans': true, 'plan_ids': <dynamic>[]}),
    );
    expect(fee.appliesTo('any-plan-at-all'), isTrue);
  });

  test('a fee on chosen plans applies only to those', () {
    final Fee fee = Fee.fromRow(_row());
    expect(fee.appliesTo('p-1'), isTrue);
    expect(fee.appliesTo('p-3'), isFalse);
  });
}
