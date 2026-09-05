import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

void main() {
  group('MemberStatus', () {
    test('round-trips every wire value', () {
      for (final value in [
        'active',
        'expired',
        'frozen',
        'left',
      ]) {
        expect(MemberStatus.fromDb(value).toDb(), value);
      }
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => MemberStatus.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('MemberGender', () {
    test('round-trips every wire value', () {
      for (final value in ['male', 'female', 'other']) {
        expect(MemberGender.fromDb(value).toDb(), value);
      }
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => MemberGender.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('PlanType', () {
    test('round-trips every wire value', () {
      for (final value in ['time', 'session_pack']) {
        expect(PlanType.fromDb(value).toDb(), value);
      }
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => PlanType.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('MembershipStatus', () {
    test('round-trips every wire value', () {
      for (final value in [
        'upcoming',
        'active',
        'frozen',
        'expired',
        'cancelled',
      ]) {
        expect(MembershipStatus.fromDb(value).toDb(), value);
      }
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => MembershipStatus.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('PaymentMethod', () {
    test('round-trips every wire value', () {
      for (final value in [
        'cash',
        'esewa',
        'khalti',
        'fonepay',
        'bank',
        'card',
      ]) {
        expect(PaymentMethod.fromDb(value).toDb(), value);
      }
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => PaymentMethod.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('PaymentKind', () {
    test('round-trips every wire value', () {
      for (final value in ['payment', 'refund']) {
        expect(PaymentKind.fromDb(value).toDb(), value);
      }
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => PaymentKind.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('InvoiceStatus', () {
    test('round-trips every wire value', () {
      for (final value in ['unpaid', 'partial', 'paid', 'void']) {
        expect(InvoiceStatus.fromDb(value).toDb(), value);
      }
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => InvoiceStatus.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('StaffRole', () {
    test('round-trips every wire value', () {
      for (final value in ['owner', 'manager', 'front_desk', 'trainer']) {
        expect(StaffRole.fromDb(value).toDb(), value);
      }
    });

    test('maps StaffRole.frontDesk to front_desk', () {
      expect(StaffRole.frontDesk.wire, 'front_desk');
      expect(StaffRole.fromDb('front_desk'), StaffRole.frontDesk);
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => StaffRole.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });
}
