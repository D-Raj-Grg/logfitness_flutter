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
      // `reversal` was missing here until 2026-09-09, and this list is why it
      // survived: the test asserted the values the enum happened to have
      // rather than the values `public.payment_kind` actually declares. A
      // list written from the migration is the point of the test.
      for (final value in ['payment', 'refund', 'reversal']) {
        expect(PaymentKind.fromDb(value).toDb(), value);
      }
    });

    test('covers the whole Postgres enum, with nothing left over', () {
      expect(
        PaymentKind.values.map((e) => e.wire).toSet(),
        <String>{'payment', 'refund', 'reversal'},
      );
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

  // --- the notification enums (2026-09-12) ---------------------------------
  //
  // Each value set is spelled out literally rather than derived from
  // `.values`, because a test written off the enum it is testing cannot
  // notice a value that was never added. These lists are transcribed from the
  // Postgres types in
  // `logfitness_saas/supabase/migrations/20260909140000_notification_schema.sql`
  // and the two migrations that grew them.

  group('NotificationChannel', () {
    test('round-trips every wire value', () {
      for (final value in ['sms', 'viber', 'email']) {
        expect(NotificationChannel.fromDb(value).toDb(), value);
      }
    });

    test('carries exactly the values notification_channel has', () {
      expect(
        NotificationChannel.values.map((e) => e.wire).toList(),
        ['sms', 'viber', 'email'],
      );
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => NotificationChannel.fromDb('whatsapp'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('NotificationEvent', () {
    test('round-trips every wire value', () {
      for (final value in [
        'renewal_reminder',
        'dues_reminder',
        'birthday_greeting',
        'staff_invite',
        'test_message',
        'custom_message',
        'visitor_welcome',
        'visitor_follow_up',
        'announcement',
      ]) {
        expect(NotificationEvent.fromDb(value).toDb(), value);
      }
    });

    test('carries exactly the nine values notification_event has', () {
      // Five from the original schema, `custom_message` from the manual-send
      // migration, the two visitor events from 20260912100100, and
      // `announcement` from 20260917100000.
      //
      // This test is the reason the ninth value is here at all. It was added
      // upstream on 2026-09-17 and not mirrored, and because
      // `NotificationMessage.event` is a required non-nullable enum, the first
      // broadcast sent from the console stopped every row of the delivery log
      // from parsing -- in a build that was already in App Store review. The
      // count is not pedantry; it is the only thing that fails when the
      // database grows a value nobody told this app about.
      expect(
        NotificationEvent.values.map((e) => e.wire).toList(),
        [
          'renewal_reminder',
          'dues_reminder',
          'birthday_greeting',
          'staff_invite',
          'test_message',
          'custom_message',
          'visitor_welcome',
          'visitor_follow_up',
          'announcement',
        ],
      );
    });

    test('camelCase names map to their snake_case wire values', () {
      expect(NotificationEvent.renewalReminder.wire, 'renewal_reminder');
      expect(NotificationEvent.visitorFollowUp.wire, 'visitor_follow_up');
      expect(
        NotificationEvent.fromDb('custom_message'),
        NotificationEvent.customMessage,
      );
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => NotificationEvent.fromDb('bogus'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('NotificationProviderKind', () {
    test('round-trips every wire value', () {
      for (final value in [
        'sparrow_sms',
        'aakash_sms',
        'smspasal_sms',
        'viber_business',
        'resend_email',
        'custom_http',
        'log_only',
      ]) {
        expect(NotificationProviderKind.fromDb(value).toDb(), value);
      }
    });

    test('carries exactly the values notification_provider has', () {
      expect(
        NotificationProviderKind.values.map((e) => e.wire).toList(),
        [
          'sparrow_sms',
          'aakash_sms',
          'smspasal_sms',
          'viber_business',
          'resend_email',
          'custom_http',
          'log_only',
        ],
      );
    });

    test('log_only is carried, because the column can return it', () {
      // It is a development sink and is deliberately absent from the gateway
      // picker -- but a row written with it still has to decode, or the log
      // throws on a message that was sent perfectly well.
      expect(
        NotificationProviderKind.fromDb('log_only'),
        NotificationProviderKind.logOnly,
      );
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => NotificationProviderKind.fromDb('twilio'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });

  group('NotificationStatus', () {
    test('round-trips every wire value', () {
      for (final value in [
        'queued',
        'sending',
        'sent',
        'failed',
        'cancelled',
        'skipped',
      ]) {
        expect(NotificationStatus.fromDb(value).toDb(), value);
      }
    });

    test('carries exactly the six values notification_status has', () {
      expect(
        NotificationStatus.values.map((e) => e.wire).toList(),
        ['queued', 'sending', 'sent', 'failed', 'cancelled', 'skipped'],
      );
    });

    test('skipped is its own state, not a spelling of failed', () {
      // The distinction the whole delivery log rests on: a skipped message is
      // one the gym deliberately did not send.
      expect(
        NotificationStatus.fromDb('skipped'),
        isNot(NotificationStatus.failed),
      );
    });

    test('throws UnknownEnumValue on a bogus value', () {
      expect(
        () => NotificationStatus.fromDb('delivered'),
        throwsA(isA<UnknownEnumValue>()),
      );
    });
  });
}
