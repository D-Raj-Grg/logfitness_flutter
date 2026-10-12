// What the plan form will and will not accept, decided without a widget.
//
// Dart port of `planSchema` in `logfitness_saas/lib/validation/plans.ts` and
// of `canScopePlan` in `logfitness_saas/components/plans/plan-scope.ts`. The
// sentences are copied so the console and the phone refuse the same things in
// the same words; the `membership_plans_shape` check constraint and the RLS
// policies are the second layer behind this one.
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/money.dart';

enum PlanField {
  name,
  description,
  planType,
  durationDays,
  sessionCount,
  price,
  signupFee,
  branchIds,
}

const int kMaxPlanNameLength = 120;
const int kMaxPlanDescriptionLength = 500;

/// Stops a pasted number from overflowing the integer paisa column. The
/// console has no ceiling; this one is far above any real membership.
const int _maxPaisa = 9000000000000000;

/// Shown when a non-owner picks no branch, or one that is not theirs.
const String kPlanOutOfScope =
    'A plan must be sold at your own branches. Pick at least one.';

/// Shown when a non-owner tries to change a plan sold outside their branches.
const String kPlanEditOutOfScope =
    'Only an owner can change a plan sold outside your branches.';

/// Postgres 23505 on `membership_plans (org_id, name)`.
const String kPlanDuplicateName = 'A plan with that name already exists.';

/// Whether [role] may create or edit a plan sold at [planBranchIds].
///
/// Owners may scope a plan anywhere, including org-wide (empty list).
/// Managers -- and the front desk, on the console -- are limited to a
/// non-empty subset of their own branches. Anyone else may not.
bool canScopePlan(
  StaffRole role,
  List<String> actorBranchIds,
  List<String> planBranchIds,
) {
  if (role == StaffRole.owner) {
    return true;
  }
  if (role != StaffRole.manager && role != StaffRole.frontDesk) {
    return false;
  }
  return planBranchIds.isNotEmpty &&
      planBranchIds.every(actorBranchIds.contains);
}

/// Cleaned values, ready to write. Money is integer paisa.
class PlanValues {
  const PlanValues({
    required this.name,
    required this.description,
    required this.planType,
    required this.durationDays,
    required this.sessionCount,
    required this.pricePaisa,
    required this.signupFeePaisa,
    required this.branchIds,
    required this.isActive,
  });

  final String name;
  final String? description;
  final PlanType planType;
  final int? durationDays;
  final int? sessionCount;
  final int pricePaisa;
  final int signupFeePaisa;
  final List<String> branchIds;
  final bool isActive;

  /// The columns the console writes, in its own names (`lib/db/plans.ts`).
  Map<String, dynamic> toRow() => <String, dynamic>{
    'name': name,
    'description': description,
    'plan_type': planType.toDb(),
    'duration_days': durationDays,
    'session_count': sessionCount,
    'price_paisa': pricePaisa,
    'signup_fee_paisa': signupFeePaisa,
    'branch_ids': branchIds,
    'is_active': isActive,
  };
}

class PlanValidation {
  const PlanValidation({required this.errors, this.values});

  final Map<PlanField, String> errors;

  /// Present only when [errors] is empty.
  final PlanValues? values;

  bool get isValid => errors.isEmpty && values != null;
}

/// Rupees typed by a person, to paisa. Returns the paisa or an error sentence.
({int? paisa, String? error}) _rupees(String raw, {required bool required}) {
  final String text = raw.trim();
  if (text.isEmpty) {
    return required
        ? (paisa: null, error: 'Enter an amount')
        : (paisa: 0, error: null);
  }
  final int paisa;
  try {
    paisa = toPaisa(text);
  } catch (_) {
    return (paisa: null, error: 'Enter a valid amount');
  }
  if (paisa < 0) {
    return (paisa: null, error: 'Amount cannot be negative');
  }
  if (paisa > _maxPaisa) {
    return (paisa: null, error: 'Enter a valid amount');
  }
  return (paisa: paisa, error: null);
}

/// A whole number above zero, or null for blank. Anything else is an error.
({int? value, bool invalid}) _wholeNumber(String raw) {
  final String text = raw.trim();
  if (text.isEmpty) {
    return (value: null, invalid: false);
  }
  final int? parsed = int.tryParse(text);
  if (parsed == null || parsed <= 0) {
    return (value: null, invalid: true);
  }
  return (value: parsed, invalid: false);
}

const String _wholeNumberMessage = 'Enter a whole number greater than zero';

PlanValidation validatePlan({
  required String name,
  required String description,
  required PlanType planType,
  required String durationDays,
  required String sessionCount,
  required String price,
  required String signupFee,
  required List<String> branchIds,
  required StaffRole role,
  required List<String> actorBranchIds,
  bool isActive = true,
}) {
  final Map<PlanField, String> errors = <PlanField, String>{};

  final String cleanName = name.trim();
  if (cleanName.isEmpty) {
    errors[PlanField.name] = 'Name is required';
  } else if (cleanName.length > kMaxPlanNameLength) {
    errors[PlanField.name] = 'Name is too long';
  }

  final String cleanDescription = description.trim();
  if (cleanDescription.length > kMaxPlanDescriptionLength) {
    errors[PlanField.description] = 'Description is too long';
  }

  final ({int? paisa, String? error}) priceResult = _rupees(
    price,
    required: true,
  );
  if (priceResult.error != null) {
    errors[PlanField.price] = priceResult.error!;
  }
  final ({int? paisa, String? error}) feeResult = _rupees(
    signupFee,
    required: false,
  );
  if (feeResult.error != null) {
    errors[PlanField.signupFee] = feeResult.error!;
  }

  final ({int? value, bool invalid}) days = _wholeNumber(durationDays);
  final ({int? value, bool invalid}) sessions = _wholeNumber(sessionCount);

  // Mirrors `membership_plans_shape`, so the error lands on the right field
  // instead of arriving as a database exception. A time plan needs days; a
  // session pack needs sessions and may also carry a validity window.
  if (planType == PlanType.time) {
    if (days.invalid) {
      errors[PlanField.durationDays] = _wholeNumberMessage;
    } else if (days.value == null) {
      errors[PlanField.durationDays] = 'A time plan needs a duration in days';
    }
  } else {
    if (sessions.invalid) {
      errors[PlanField.sessionCount] = _wholeNumberMessage;
    } else if (sessions.value == null) {
      errors[PlanField.sessionCount] = 'A session pack needs a session count';
    }
    if (days.invalid) {
      errors[PlanField.durationDays] = _wholeNumberMessage;
    }
  }

  final List<String> branches = List<String>.unmodifiable(
    branchIds.toSet().toList(),
  );
  if (!canScopePlan(role, actorBranchIds, branches)) {
    errors[PlanField.branchIds] = kPlanOutOfScope;
  }

  if (errors.isNotEmpty) {
    return PlanValidation(errors: errors);
  }

  return PlanValidation(
    errors: errors,
    values: PlanValues(
      name: cleanName,
      description: cleanDescription.isEmpty ? null : cleanDescription,
      planType: planType,
      durationDays: days.value,
      // A time plan never carries a session count.
      sessionCount: planType == PlanType.sessionPack ? sessions.value : null,
      pricePaisa: priceResult.paisa!,
      signupFeePaisa: feeResult.paisa!,
      branchIds: branches,
      isActive: isActive,
    ),
  );
}
