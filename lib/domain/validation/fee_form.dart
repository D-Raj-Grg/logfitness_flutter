// Validation for the add/edit fee form. Pure Dart, no Flutter, no Riverpod.
//
// Port of `logfitness_saas/lib/validation/fees.ts` (and the form that feeds
// it). The same sentences, so a fee refused on one surface reads the same on
// the other.
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/money.dart';

enum FeeField { name, amount, chargeRule, planIds }

const int kMaxFeeNameLength = 120;

/// 100,000.00 rupees in paisa -- the console's ceiling. A fat-fingered extra
/// zero stops here.
const int kMaxFeePaisa = 10000000;

/// Postgres 23505 on `fees (org_id, lower(name))`.
const String kFeeDuplicateName = 'A fee with that name already exists.';

const String kFeeNeedsPlans =
    'Pick at least one plan, or apply the fee to all plans';

/// What a fee's rule means, in words a gym owner uses.
String feeRuleLabel(FeeChargeRule rule) => switch (rule) {
  FeeChargeRule.once => 'Once, on the first membership',
  FeeChargeRule.everySale => 'On every sale',
};

/// Cleaned values, ready to write. Money is integer paisa.
class FeeValues {
  const FeeValues({
    required this.name,
    required this.chargeRule,
    required this.amountPaisa,
    required this.allPlans,
    required this.planIds,
    required this.isActive,
  });

  final String name;
  final FeeChargeRule chargeRule;
  final int amountPaisa;
  final bool allPlans;
  final List<String> planIds;
  final bool isActive;

  /// The columns the console writes. `plan_ids` is empty when the fee is on for
  /// all plans, as the database forces anyway.
  Map<String, dynamic> toRow() => <String, dynamic>{
    'name': name,
    'charge_rule': chargeRule.toDb(),
    'amount_paisa': amountPaisa,
    'all_plans': allPlans,
    'plan_ids': allPlans ? const <String>[] : planIds,
    'is_active': isActive,
  };
}

class FeeValidation {
  const FeeValidation({required this.errors, this.values});

  final Map<FeeField, String> errors;

  /// Present only when [errors] is empty.
  final FeeValues? values;

  bool get isValid => errors.isEmpty && values != null;
}

FeeValidation validateFee({
  required String name,
  required String amount,
  required FeeChargeRule chargeRule,
  required bool allPlans,
  required List<String> planIds,
  bool isActive = true,
}) {
  final Map<FeeField, String> errors = <FeeField, String>{};

  final String cleanName = name.trim();
  if (cleanName.isEmpty) {
    errors[FeeField.name] = 'Name is required';
  } else if (cleanName.length > kMaxFeeNameLength) {
    errors[FeeField.name] = 'Name is too long';
  }

  int paisa = 0;
  final String amountText = amount.trim();
  if (amountText.isEmpty) {
    errors[FeeField.amount] = 'Enter an amount';
  } else {
    try {
      paisa = toPaisa(amountText);
      if (paisa < 0) {
        errors[FeeField.amount] = 'Amount cannot be negative';
      } else if (paisa == 0) {
        errors[FeeField.amount] = 'Amount must be more than zero';
      } else if (paisa > kMaxFeePaisa) {
        errors[FeeField.amount] = 'That fee looks too large';
      }
    } catch (_) {
      errors[FeeField.amount] = 'Enter a valid amount';
    }
  }

  // A fee that reaches no plan charges nothing, which is never what the owner
  // meant.
  final List<String> plans = List<String>.unmodifiable(
    planIds.toSet().toList(),
  );
  if (!allPlans && plans.isEmpty) {
    errors[FeeField.planIds] = kFeeNeedsPlans;
  }

  if (errors.isNotEmpty) {
    return FeeValidation(errors: errors);
  }

  return FeeValidation(
    errors: errors,
    values: FeeValues(
      name: cleanName,
      chargeRule: chargeRule,
      amountPaisa: paisa,
      allPlans: allPlans,
      planIds: allPlans ? const <String>[] : plans,
      isActive: isActive,
    ),
  );
}
