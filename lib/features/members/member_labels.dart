// The words the member screens use, in one place.
//
// Every string here is copied from `logfitness_saas/lib/members.ts` --
// `MEMBER_STATUS_LABELS`, `MEMBERSHIP_STATUS_LABELS`, `PAYMENT_METHOD_LABELS`,
// `PAYMENT_KIND_LABELS`, `INVOICE_STATUS_LABELS` -- and from
// `components/members/member-status-badge.tsx`. A manager reading the console
// and a desk reading the phone are discussing the same person, and the enum
// name is not what either of them calls it: `session_pack` is "Session pack",
// `esewa` is "eSewa", and `reversal` is "Never received". Rendering the raw
// wire value instead is the defect this file closes -- the lookup panel showed
// `member.status.wire` and the register form's method dropdown showed
// `PaymentMethod.wire`, both of which put a Postgres enum in front of a person
// at a counter.
//
// Pinned by `test/features/members/member_labels_test.dart`. Changing a string
// here without changing it in the console is how the two clients start
// describing the same row differently.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/members/member_list_query.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

/// Mirrors `MEMBER_STATUS_LABELS`. The plain word for the stored status, with
/// none of the narrowing [memberStatusLabel] applies.
String memberStatusText(MemberStatus status) => switch (status) {
  MemberStatus.active => 'Active',
  MemberStatus.expired => 'Expired',
  MemberStatus.frozen => 'Frozen',
  MemberStatus.left => 'Left',
};

/// Mirrors `MEMBERSHIP_STATUS_LABELS`. `upcoming` reads as "Starts later"
/// because `members.status` has no upcoming value and the membership row is
/// the honest label for a plan sold for a future date.
String membershipStatusLabel(MembershipStatus status) => switch (status) {
  MembershipStatus.upcoming => 'Starts later',
  MembershipStatus.active => 'Active',
  MembershipStatus.frozen => 'Frozen',
  MembershipStatus.expired => 'Expired',
  MembershipStatus.cancelled => 'Cancelled',
};

/// Mirrors `PAYMENT_METHOD_LABELS`. The casing is the rails' own -- "eSewa"
/// and "FonePay" are how those wallets spell themselves on a receipt.
String paymentMethodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'Cash',
  PaymentMethod.esewa => 'eSewa',
  PaymentMethod.khalti => 'Khalti',
  PaymentMethod.fonepay => 'FonePay',
  PaymentMethod.bank => 'Bank transfer',
  PaymentMethod.card => 'Card',
};

/// Mirrors `DISCOUNT_REASON_LABELS`. Printed on the invoice beside the amount
/// saved, so the words have to be the console's.
String discountReasonLabel(DiscountReason reason) => switch (reason) {
  DiscountReason.festival => 'Festival offer',
  DiscountReason.student => 'Student',
  DiscountReason.staffReferral => 'Staff referral',
  DiscountReason.friendReferral => 'Friend referral',
  DiscountReason.corporate => 'Corporate',
  DiscountReason.other => 'Other',
};

/// Mirrors `PAYMENT_KIND_LABELS`. A refund is money handed back; a reversal is
/// money that never arrived and should not have been recorded. Both are
/// negative rows, so only the word tells the drawer which happened.
String paymentKindLabel(PaymentKind kind) => switch (kind) {
  PaymentKind.payment => 'Payment',
  PaymentKind.refund => 'Refund',
  PaymentKind.reversal => 'Never received',
};

/// Mirrors `INVOICE_STATUS_LABELS`.
String invoiceStatusLabel(InvoiceStatus status) => switch (status) {
  InvoiceStatus.unpaid => 'Unpaid',
  InvoiceStatus.partial => 'Part paid',
  InvoiceStatus.paid => 'Paid',
  InvoiceStatus.voided => 'Void',
};

/// Mirrors `PLAN_TYPE_LABELS`.
String planTypeLabel(PlanType type) => switch (type) {
  PlanType.time => 'Time-based',
  PlanType.sessionPack => 'Session pack',
};

/// The label on a status filter chip. `null` is the absence of a filter, not
/// a filter of its own. Mirrors `STATUS_OPTIONS` in
/// `components/members/member-search.tsx`, including the seven-day window
/// spelled out in the "Expiring" option -- the number is the console's, and
/// saying it on the chip is what stops the two surfaces disagreeing quietly.
String memberListFilterLabel(MemberListFilter? filter) => switch (filter) {
  null => 'All statuses',
  MemberListFilter.active => 'Active',
  MemberListFilter.expiring => 'Expiring in 7 days',
  MemberListFilter.expired => 'Expired',
  MemberListFilter.frozen => 'Frozen',
  MemberListFilter.dues => 'Dues outstanding',
  MemberListFilter.left => 'Left',
  MemberListFilter.archived => 'Archived',
};

/// The status as a person should read it, which is not always the status
/// stored. Mirrors `memberStatusLabel` in
/// `components/members/member-status-badge.tsx` case for case.
///
/// Three of these narrowings exist because `members.status` is trigger-derived
/// and has only four values, and two of them are wrong words for a desk:
///
///  * a member registered without a plan computes to `expired`, which is what
///    the arrears report needs and the wrong thing to say two minutes after
///    the name was typed in;
///  * a plan sold for a future date leaves the member `expired` until the
///    nightly sweep starts it, so the membership row is the honest label;
///  * an active membership inside seven days is the renewal conversation, and
///    "Active" hides it.
String memberStatusLabel(
  MemberStatus status, {
  int? daysToExpiry,
  MembershipStatus? membershipStatus,
  bool hasMembershipHistory = true,
}) {
  if (status == MemberStatus.expired && !hasMembershipHistory) {
    return 'New';
  }
  if (status == MemberStatus.expired &&
      membershipStatus == MembershipStatus.upcoming) {
    return membershipStatusLabel(MembershipStatus.upcoming);
  }
  if (status == MemberStatus.active &&
      daysToExpiry != null &&
      daysToExpiry <= 7) {
    if (daysToExpiry <= 0) {
      return 'Expires today';
    }
    return 'Expiring in $daysToExpiry day${daysToExpiry == 1 ? '' : 's'}';
  }
  return memberStatusText(status);
}

/// How loudly a status should read. Mirrors `memberStatusTone`.
///
/// Neither "New" nor "Starts later" is an alarm, so neither is red -- a
/// registration waiting for a plan is not a lapsed member, however the status
/// column computes it.
enum _MemberTone { strong, quiet, outlined, alarm }

_MemberTone _toneFor(
  MemberStatus status,
  int? daysToExpiry,
  MembershipStatus? membershipStatus,
  bool hasMembershipHistory,
) {
  if (status == MemberStatus.expired && !hasMembershipHistory) {
    return _MemberTone.quiet;
  }
  if (status == MemberStatus.expired &&
      membershipStatus == MembershipStatus.upcoming) {
    return _MemberTone.outlined;
  }
  if (status == MemberStatus.active &&
      daysToExpiry != null &&
      daysToExpiry <= 7) {
    return _MemberTone.outlined;
  }
  if (status == MemberStatus.active) {
    return _MemberTone.strong;
  }
  if (status == MemberStatus.frozen) {
    return _MemberTone.quiet;
  }
  return _MemberTone.alarm;
}

/// The status pill on a member row, the counterpart of
/// [VisitorStatusBadge](../visitors/widgets/visitor_status_badge.dart).
///
/// Colour carries meaning, so it comes from the theme's semantic roles rather
/// than being picked (PLANNING.md §6): nothing here is a hardcoded colour, and
/// the alarm tone takes the error container so a lapsed member reads as one in
/// both light and dark.
class MemberStatusBadge extends StatelessWidget {
  const MemberStatusBadge({
    required this.status,
    this.daysToExpiry,
    this.membershipStatus,
    this.hasMembershipHistory = true,
    super.key,
  });

  final MemberStatus status;

  /// `end_date - org_today(org_id)`, straight off `member_overview`. Never
  /// recomputed from the device clock -- the org's today is the database's.
  final int? daysToExpiry;

  /// The current membership row's own status, when the caller has it.
  final MembershipStatus? membershipStatus;

  /// False when nothing has ever been sold to this member.
  final bool hasMembershipHistory;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final _MemberTone tone = _toneFor(
      status,
      daysToExpiry,
      membershipStatus,
      hasMembershipHistory,
    );

    final (Color background, Color foreground, Color? border) = switch (tone) {
      _MemberTone.strong => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        null,
      ),
      _MemberTone.outlined => (
        Colors.transparent,
        scheme.onSurfaceVariant,
        scheme.outline,
      ),
      _MemberTone.quiet => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        null,
      ),
      _MemberTone.alarm => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        null,
      ),
    };

    final String label = memberStatusLabel(
      status,
      daysToExpiry: daysToExpiry,
      membershipStatus: membershipStatus,
      hasMembershipHistory: hasMembershipHistory,
    );

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceSm,
          vertical: Brand.spaceXs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Brand.radiusSmall),
          border: border == null ? null : Border.all(color: border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Mirrors `public.member_gender`. Kept here rather than private to a form,
/// because the register screen and the edit screen must not drift into
/// spelling the same three values differently.
String memberGenderLabel(MemberGender gender) => switch (gender) {
      MemberGender.male => 'Male',
      MemberGender.female => 'Female',
      MemberGender.other => 'Other',
    };
