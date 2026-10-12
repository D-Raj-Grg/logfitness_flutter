import 'package:flutter_test/flutter_test.dart';

import 'package:logfitness_flutter/domain/validation/org_letterhead.dart';

LetterheadValidation _v({
  String name = 'Lord of Gyms',
  String legalName = '',
  String address = '',
  String phone = '',
  String email = '',
  String panNo = '',
  String taxNote = '',
  String invoiceTerms = '',
  String fee = '',
}) => validateLetterhead(
  name: name,
  legalName: legalName,
  address: address,
  phone: phone,
  email: email,
  panNo: panNo,
  taxNote: taxNote,
  invoiceTerms: invoiceTerms,
  standardSignupFee: fee,
);

void main() {
  test('blank optional fields become null and fee defaults to zero', () {
    final LetterheadValidation r = _v(legalName: '  ', phone: '');
    expect(r.isValid, isTrue);
    expect(r.values!.legalName, isNull);
    expect(r.values!.phone, isNull);
    expect(r.values!.standardSignupFeePaisa, 0);
  });

  test('name is required and capped at 120', () {
    expect(_v(name: ' ').errors, contains(LetterheadField.name));
    expect(_v(name: 'a' * 121).errors, contains(LetterheadField.name));
    expect(_v(name: 'a' * 120).isValid, isTrue);
  });

  test('email is lowercased and must contain an @ after the first char', () {
    expect(_v(email: 'Desk@Gym.COM').values!.email, 'desk@gym.com');
    expect(_v(email: 'nope').errors, contains(LetterheadField.email));
    expect(_v(email: '@gym.com').errors, contains(LetterheadField.email));
  });

  test('phone must be 3..32 characters', () {
    expect(_v(phone: '12').errors, contains(LetterheadField.phone));
    expect(_v(phone: '01-4412345 ext 2').isValid, isTrue);
    expect(_v(phone: '1' * 33).errors, contains(LetterheadField.phone));
  });

  test('length caps match the database CHECKs', () {
    expect(
      _v(legalName: 'a' * 161).errors,
      contains(LetterheadField.legalName),
    );
    expect(_v(address: 'a' * 501).errors, contains(LetterheadField.address));
    expect(_v(panNo: 'a' * 33).errors, contains(LetterheadField.panNo));
    expect(_v(taxNote: 'a' * 201).errors, contains(LetterheadField.taxNote));
    expect(
      _v(invoiceTerms: 'a' * 2001).errors,
      contains(LetterheadField.invoiceTerms),
    );
  });

  test(
    'fee converts rupees to paisa, strips commas, rejects junk and huge',
    () {
      expect(_v(fee: '1,500.50').values!.standardSignupFeePaisa, 150050);
      expect(_v(fee: '500').values!.standardSignupFeePaisa, 50000);
      expect(
        _v(fee: '5.555').errors,
        contains(LetterheadField.standardSignupFee),
      );
      expect(
        _v(fee: 'abc').errors,
        contains(LetterheadField.standardSignupFee),
      );
      expect(
        _v(fee: '100000.01').errors,
        contains(LetterheadField.standardSignupFee),
      );
      expect(_v(fee: '100000').isValid, isTrue);
    },
  );

  test('logoProblem refuses wrong type and oversize', () {
    expect(logoProblem(contentType: 'image/gif', bytes: 10), isNotNull);
    expect(
      logoProblem(contentType: 'image/png', bytes: kMaxLogoBytes + 1),
      isNotNull,
    );
    expect(
      logoProblem(contentType: 'image/webp', bytes: kMaxLogoBytes),
      isNull,
    );
  });
}
