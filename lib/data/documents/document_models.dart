// Plain read models for the printed invoice and receipt. They hold exactly
// what `logfitness_saas/lib/db/documents.ts` selects, nothing more.
//
// Hand-written rather than freezed: they are built from one nested select,
// never serialised, and a document is a snapshot not an entity.
//
// Money is integer paisa throughout and is only formatted at render time.
// `date` columns are read as UTC-midnight values (see `plain_date.dart`);
// `timestamptz` columns stay instants.
import 'package:flutter/foundation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

DateTime _plainDate(Object? value) {
  final DateTime parsed = DateTime.parse(value! as String);
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}

DateTime? _plainDateOrNull(Object? value) =>
    value is String ? _plainDate(value) : null;

String? _text(Map<String, dynamic> row, String key) {
  final Object? value = row[key];
  return value is String ? value : null;
}

int _int(Map<String, dynamic> row, String key) {
  final Object? value = row[key];
  return value is num ? value.toInt() : 0;
}

Map<String, dynamic>? _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

String? _staffName(Object? embed) => _map(embed)?['full_name'] as String?;

/// The org letterhead as a document prints it.
@immutable
class DocumentOrg {
  const DocumentOrg({
    required this.name,
    required this.currency,
    required this.timezone,
    this.legalName,
    this.address,
    this.phone,
    this.email,
    this.panNo,
    this.taxNote,
    this.invoiceTerms,
    this.logoPath,
  });

  factory DocumentOrg.fromRow(Map<String, dynamic> row) => DocumentOrg(
    name: _text(row, 'name') ?? '',
    legalName: _text(row, 'legal_name'),
    address: _text(row, 'address'),
    phone: _text(row, 'phone'),
    email: _text(row, 'email'),
    panNo: _text(row, 'pan_no'),
    taxNote: _text(row, 'tax_note'),
    invoiceTerms: _text(row, 'invoice_terms'),
    logoPath: _text(row, 'logo_path'),
    currency: _text(row, 'currency') ?? 'NPR',
    timezone: _text(row, 'timezone') ?? 'Asia/Kathmandu',
  );

  final String name;
  final String? legalName;
  final String? address;
  final String? phone;
  final String? email;
  final String? panNo;
  final String? taxNote;
  final String? invoiceTerms;
  final String? logoPath;
  final String currency;
  final String timezone;

  /// Registered name when there is one, else the display name.
  String get displayName {
    final String? legal = legalName?.trim();
    return (legal != null && legal.isNotEmpty) ? legal : name;
  }
}

@immutable
class DocumentMember {
  const DocumentMember({
    required this.memberCode,
    required this.fullName,
    required this.phone,
    this.email,
    this.address,
  });

  factory DocumentMember.fromRow(Map<String, dynamic> row) => DocumentMember(
    memberCode: _text(row, 'member_code') ?? '',
    fullName: _text(row, 'full_name') ?? '',
    phone: _text(row, 'phone') ?? '',
    email: _text(row, 'email'),
    address: _text(row, 'address'),
  );

  final String memberCode;
  final String fullName;
  final String phone;
  final String? email;
  final String? address;
}

@immutable
class DocumentBranch {
  const DocumentBranch({required this.name, this.address, this.phone});

  factory DocumentBranch.fromRow(Map<String, dynamic> row) => DocumentBranch(
    name: _text(row, 'name') ?? '',
    address: _text(row, 'address'),
    phone: _text(row, 'phone'),
  );

  final String name;
  final String? address;
  final String? phone;
}

/// The membership an invoice or receipt is for. The receipt embed selects
/// fewer columns, so everything beyond the plan and period defaults to zero.
@immutable
class DocumentMembership {
  const DocumentMembership({
    required this.planName,
    required this.planType,
    required this.startDate,
    this.endDate,
    this.sessionsTotal,
    this.pricePaisa = 0,
    this.signupFeePaisa = 0,
    this.signupFeeWaivedPaisa = 0,
    this.discountPaisa = 0,
    this.previousMembershipId,
    this.sellerName,
  });

  factory DocumentMembership.fromRow(Map<String, dynamic> row) =>
      DocumentMembership(
        planName: _text(row, 'plan_name') ?? '',
        planType: PlanType.fromDb(_text(row, 'plan_type') ?? 'time'),
        startDate: _plainDate(row['start_date']),
        endDate: _plainDateOrNull(row['end_date']),
        sessionsTotal: row['sessions_total'] is num
            ? (row['sessions_total'] as num).toInt()
            : null,
        pricePaisa: _int(row, 'price_paisa'),
        signupFeePaisa: _int(row, 'signup_fee_paisa'),
        signupFeeWaivedPaisa: _int(row, 'signup_fee_waived_paisa'),
        discountPaisa: _int(row, 'discount_paisa'),
        previousMembershipId: _text(row, 'previous_membership_id'),
        sellerName: _staffName(row['seller']),
      );

  final String planName;
  final PlanType planType;
  final DateTime startDate;
  final DateTime? endDate;
  final int? sessionsTotal;
  final int pricePaisa;
  final int signupFeePaisa;
  final int signupFeeWaivedPaisa;
  final int discountPaisa;
  final String? previousMembershipId;
  final String? sellerName;
}

/// One payment line in an invoice's history.
@immutable
class DocumentPaymentLine {
  const DocumentPaymentLine({
    required this.id,
    required this.kind,
    required this.amountPaisa,
    required this.method,
    required this.paidAt,
    this.referenceNo,
    this.collectorName,
  });

  factory DocumentPaymentLine.fromRow(Map<String, dynamic> row) =>
      DocumentPaymentLine(
        id: row['id'] as String,
        kind: PaymentKind.fromDb(row['kind'] as String),
        amountPaisa: _int(row, 'amount_paisa'),
        method: PaymentMethod.fromDb(row['method'] as String),
        referenceNo: _text(row, 'reference_no'),
        paidAt: DateTime.parse(row['paid_at'] as String),
        collectorName: _staffName(row['collector']),
      );

  final String id;
  final PaymentKind kind;
  final int amountPaisa;
  final PaymentMethod method;
  final String? referenceNo;
  final DateTime paidAt;
  final String? collectorName;
}

DiscountReason? _discountReason(Map<String, dynamic> row) {
  final String? wire = _text(row, 'discount_reason');
  return wire == null ? null : DiscountReason.fromDb(wire);
}

/// Everything an invoice prints.
///
/// [payments] is branch-scoped by RLS, so an empty list does NOT mean unpaid.
/// [paidPaisa] and [duePaisa] come from the invoice row (trigger-maintained)
/// and are always right.
@immutable
class InvoiceForPrint {
  const InvoiceForPrint({
    required this.id,
    required this.invoiceNo,
    required this.issuedOn,
    required this.subtotalPaisa,
    required this.discountPaisa,
    required this.totalPaisa,
    required this.paidPaisa,
    required this.org,
    required this.member,
    required this.branch,
    this.duePaisa,
    this.discountReason,
    this.discountNote,
    this.notes,
    this.membership,
    this.payments = const <DocumentPaymentLine>[],
  });

  factory InvoiceForPrint.fromRow(Map<String, dynamic> row) {
    final Map<String, dynamic>? membership = _map(row['membership']);
    final List<DocumentPaymentLine> payments =
        ((row['payments'] as List<dynamic>?) ?? const <dynamic>[])
            .map((Object? e) => DocumentPaymentLine.fromRow(_map(e)!))
            .toList()
          ..sort(
            (DocumentPaymentLine a, DocumentPaymentLine b) =>
                a.paidAt.compareTo(b.paidAt),
          );
    return InvoiceForPrint(
      id: row['id'] as String,
      invoiceNo: _text(row, 'invoice_no') ?? '',
      issuedOn: _plainDate(row['issued_on']),
      subtotalPaisa: _int(row, 'subtotal_paisa'),
      discountPaisa: _int(row, 'discount_paisa'),
      totalPaisa: _int(row, 'total_paisa'),
      paidPaisa: _int(row, 'paid_paisa'),
      duePaisa: row['due_paisa'] is num
          ? (row['due_paisa'] as num).toInt()
          : null,
      discountReason: _discountReason(row),
      discountNote: _text(row, 'discount_note'),
      notes: _text(row, 'notes'),
      org: DocumentOrg.fromRow(_map(row['org'])!),
      member: DocumentMember.fromRow(_map(row['member'])!),
      branch: DocumentBranch.fromRow(_map(row['branch'])!),
      membership: membership == null
          ? null
          : DocumentMembership.fromRow(membership),
      payments: payments,
    );
  }

  final String id;
  final String invoiceNo;
  final DateTime issuedOn;
  final int subtotalPaisa;
  final int discountPaisa;
  final int totalPaisa;
  final int paidPaisa;

  /// Generated column, so nullable in principle; see `dueFor`.
  final int? duePaisa;
  final DiscountReason? discountReason;
  final String? discountNote;
  final String? notes;
  final DocumentOrg org;
  final DocumentMember member;
  final DocumentBranch branch;
  final DocumentMembership? membership;
  final List<DocumentPaymentLine> payments;
}

@immutable
class DocumentInvoiceSummary {
  const DocumentInvoiceSummary({
    required this.invoiceNo,
    required this.totalPaisa,
    required this.paidPaisa,
    required this.status,
    this.duePaisa,
    this.discountPaisa = 0,
    this.discountReason,
    this.discountNote,
  });

  factory DocumentInvoiceSummary.fromRow(Map<String, dynamic> row) =>
      DocumentInvoiceSummary(
        invoiceNo: _text(row, 'invoice_no') ?? '',
        totalPaisa: _int(row, 'total_paisa'),
        paidPaisa: _int(row, 'paid_paisa'),
        duePaisa: row['due_paisa'] is num
            ? (row['due_paisa'] as num).toInt()
            : null,
        status: InvoiceStatus.fromDb(row['status'] as String),
        discountPaisa: _int(row, 'discount_paisa'),
        discountReason: _discountReason(row),
        discountNote: _text(row, 'discount_note'),
      );

  final String invoiceNo;
  final int totalPaisa;
  final int paidPaisa;
  final int? duePaisa;
  final InvoiceStatus status;
  final int discountPaisa;
  final DiscountReason? discountReason;
  final String? discountNote;
}

/// Everything a receipt prints: one payment row. `membership` and `invoice`
/// are both nullable (`on delete set null` upstream).
@immutable
class PaymentForPrint {
  const PaymentForPrint({
    required this.id,
    required this.kind,
    required this.amountPaisa,
    required this.method,
    required this.paidAt,
    required this.org,
    required this.member,
    required this.branch,
    this.referenceNo,
    this.reason,
    this.notes,
    this.collectorName,
    this.membership,
    this.invoice,
  });

  factory PaymentForPrint.fromRow(Map<String, dynamic> row) {
    final Map<String, dynamic>? membership = _map(row['membership']);
    final Map<String, dynamic>? invoice = _map(row['invoice']);
    return PaymentForPrint(
      id: row['id'] as String,
      kind: PaymentKind.fromDb(row['kind'] as String),
      amountPaisa: _int(row, 'amount_paisa'),
      method: PaymentMethod.fromDb(row['method'] as String),
      paidAt: DateTime.parse(row['paid_at'] as String),
      referenceNo: _text(row, 'reference_no'),
      reason: _text(row, 'reason'),
      notes: _text(row, 'notes'),
      collectorName: _staffName(row['collector']),
      org: DocumentOrg.fromRow(_map(row['org'])!),
      member: DocumentMember.fromRow(_map(row['member'])!),
      branch: DocumentBranch.fromRow(_map(row['branch'])!),
      membership: membership == null
          ? null
          : DocumentMembership.fromRow(membership),
      invoice: invoice == null ? null : DocumentInvoiceSummary.fromRow(invoice),
    );
  }

  final String id;
  final PaymentKind kind;

  /// Negative for a refund or a reversal.
  final int amountPaisa;
  final PaymentMethod method;
  final DateTime paidAt;
  final String? referenceNo;
  final String? reason;
  final String? notes;
  final String? collectorName;
  final DocumentOrg org;
  final DocumentMember member;
  final DocumentBranch branch;
  final DocumentMembership? membership;
  final DocumentInvoiceSummary? invoice;
}
