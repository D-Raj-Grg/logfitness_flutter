// The org's letterhead: everything a printed invoice or receipt says about the
// gym. Mirrors the `OrgLetterhead` pick in `logfitness_saas/lib/db/orgs.ts`.
//
// Plain class rather than freezed: it is read and written whole through one
// repository and never serialised anywhere else.
import 'package:flutter/foundation.dart';

@immutable
class OrgProfile {
  const OrgProfile({
    required this.id,
    required this.name,
    required this.currency,
    required this.timezone,
    required this.standardSignupFeePaisa,
    this.legalName,
    this.address,
    this.phone,
    this.email,
    this.panNo,
    this.taxNote,
    this.invoiceTerms,
    this.logoPath,
  });

  factory OrgProfile.fromRow(Map<String, dynamic> row) {
    String? text(String key) {
      final Object? value = row[key];
      return value is String ? value : null;
    }

    final Object? fee = row['standard_signup_fee_paisa'];
    return OrgProfile(
      id: row['id'] as String,
      name: (row['name'] as String?) ?? '',
      legalName: text('legal_name'),
      address: text('address'),
      phone: text('phone'),
      email: text('email'),
      panNo: text('pan_no'),
      taxNote: text('tax_note'),
      invoiceTerms: text('invoice_terms'),
      logoPath: text('logo_path'),
      standardSignupFeePaisa: fee is int ? fee : 0,
      // Read-only on purpose: changing either would reinterpret every stored
      // amount and timestamp (`lib/validation/orgs.ts` upstream).
      currency: text('currency') ?? 'NPR',
      timezone: text('timezone') ?? 'Asia/Kathmandu',
    );
  }

  /// Columns read for the letterhead, shared by the screen and the PDFs.
  static const String columns =
      'id, name, legal_name, address, phone, email, pan_no, tax_note, '
      'invoice_terms, logo_path, standard_signup_fee_paisa, currency, timezone';

  final String id;
  final String name;
  final String? legalName;
  final String? address;
  final String? phone;
  final String? email;
  final String? panNo;
  final String? taxNote;
  final String? invoiceTerms;
  final String? logoPath;
  final int standardSignupFeePaisa;
  final String currency;
  final String timezone;

  /// The heading a document prints: the registered name when there is one.
  String get displayName {
    final String? legal = legalName?.trim();
    return (legal != null && legal.isNotEmpty) ? legal : name;
  }
}
