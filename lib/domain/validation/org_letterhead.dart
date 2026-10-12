// What the letterhead form will and will not accept, decided without a widget.
//
// Dart port of `orgLetterheadSchema` in `logfitness_saas/lib/validation/orgs.ts`;
// the database CHECK constraints from `20260906120000_org_letterhead.sql` are
// the second layer behind it. Lengths and sentences are copied so the console
// and the phone refuse the same things in the same words.
import 'package:logfitness_flutter/domain/format/money.dart';

enum LetterheadField {
  name,
  legalName,
  address,
  phone,
  email,
  panNo,
  taxNote,
  invoiceTerms,
  standardSignupFee,
}

/// Bucket limit for `org-logos`; refused before upload, not after.
const int kMaxLogoBytes = 2 * 1024 * 1024;
const List<String> kAllowedLogoTypes = <String>[
  'image/jpeg',
  'image/png',
  'image/webp',
];

/// 100,000.00 rupees in paisa -- the console's ceiling.
const int kMaxSignupFeePaisa = 10000000;

class LetterheadValues {
  const LetterheadValues({
    required this.name,
    required this.legalName,
    required this.address,
    required this.phone,
    required this.email,
    required this.panNo,
    required this.taxNote,
    required this.invoiceTerms,
    required this.standardSignupFeePaisa,
  });

  final String name;
  final String? legalName;
  final String? address;
  final String? phone;
  final String? email;
  final String? panNo;
  final String? taxNote;
  final String? invoiceTerms;
  final int standardSignupFeePaisa;
}

class LetterheadValidation {
  const LetterheadValidation({required this.errors, this.values});

  final Map<LetterheadField, String> errors;

  /// Cleaned values, present only when [errors] is empty.
  final LetterheadValues? values;

  bool get isValid => errors.isEmpty && values != null;
}

String? _blankToNull(String raw) {
  final String trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}

LetterheadValidation validateLetterhead({
  required String name,
  required String legalName,
  required String address,
  required String phone,
  required String email,
  required String panNo,
  required String taxNote,
  required String invoiceTerms,
  required String standardSignupFee,
}) {
  final Map<LetterheadField, String> errors = <LetterheadField, String>{};

  final String cleanName = name.trim();
  if (cleanName.isEmpty) {
    errors[LetterheadField.name] = 'Enter the gym name.';
  } else if (cleanName.length > 120) {
    errors[LetterheadField.name] = 'Keep the name under 120 characters.';
  }

  final String? legal = _blankToNull(legalName);
  if (legal != null && legal.length > 160) {
    errors[LetterheadField.legalName] = 'Keep it under 160 characters.';
  }

  final String? addr = _blankToNull(address);
  if (addr != null && addr.length > 500) {
    errors[LetterheadField.address] = 'Keep the address under 500 characters.';
  }

  final String? tel = _blankToNull(phone);
  if (tel != null && (tel.length < 3 || tel.length > 32)) {
    errors[LetterheadField.phone] =
        'Enter a phone number of 3 to 32 characters.';
  }

  final String? mail = _blankToNull(email)?.toLowerCase();
  if (mail != null && (mail.length > 254 || mail.indexOf('@') < 1)) {
    errors[LetterheadField.email] = 'Enter a valid email address.';
  }

  final String? pan = _blankToNull(panNo);
  if (pan != null && pan.length > 32) {
    errors[LetterheadField.panNo] = 'Keep it under 32 characters.';
  }

  final String? tax = _blankToNull(taxNote);
  if (tax != null && tax.length > 200) {
    errors[LetterheadField.taxNote] = 'Keep it under 200 characters.';
  }

  final String? terms = _blankToNull(invoiceTerms);
  if (terms != null && terms.length > 2000) {
    errors[LetterheadField.invoiceTerms] = 'Keep it under 2,000 characters.';
  }

  int feePaisa = 0;
  final String feeText = standardSignupFee.trim().replaceAll(',', '');
  if (feeText.isNotEmpty) {
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(feeText)) {
      errors[LetterheadField.standardSignupFee] =
          'Enter an amount in rupees, like 500 or 500.50.';
    } else {
      feePaisa = toPaisa(feeText);
      if (feePaisa > kMaxSignupFeePaisa) {
        errors[LetterheadField.standardSignupFee] = 'That fee looks too large.';
      }
    }
  }

  if (errors.isNotEmpty) {
    return LetterheadValidation(errors: errors);
  }
  return LetterheadValidation(
    errors: errors,
    values: LetterheadValues(
      name: cleanName,
      legalName: legal,
      address: addr,
      phone: tel,
      email: mail,
      panNo: pan,
      taxNote: tax,
      invoiceTerms: terms,
      standardSignupFeePaisa: feePaisa,
    ),
  );
}

/// Why a picked logo is refused, or null when it is fine.
String? logoProblem({required String contentType, required int bytes}) {
  if (!kAllowedLogoTypes.contains(contentType)) {
    return 'Use a JPEG, PNG or WebP image.';
  }
  if (bytes > kMaxLogoBytes) {
    return 'That logo is over 2 MB. Choose a smaller one.';
  }
  return null;
}
