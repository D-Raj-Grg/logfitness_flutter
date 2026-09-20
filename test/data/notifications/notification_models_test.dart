// The notification models against rows shaped like the ones PostgREST actually
// returns -- column for column from `public.notification_messages`,
// `notification_providers`, `notification_rules` and `notification_templates`.
//
// The nulls carry as much weight as the values here. A message with no branch
// is an org-wide one, a message with no provider has not gone out yet, and a
// message with no `created_by` was raised by a sweep rather than by a person.
// All three are ordinary rows, and a model that threw on any of them would
// break the log on the days it matters most.
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_previews.dart';
import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/data/notifications/notification_rule.dart';
import 'package:logfitness_flutter/data/notifications/notification_template.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _messageRow({
  Map<String, dynamic> overrides = const <String, dynamic>{},
}) => <String, dynamic>{
  'id': '11111111-1111-1111-1111-111111111111',
  'org_id': '22222222-2222-2222-2222-222222222222',
  'branch_id': '33333333-3333-3333-3333-333333333333',
  'member_id': '44444444-4444-4444-4444-444444444444',
  'staff_id': null,
  'visitor_id': null,
  'channel': 'sms',
  'event': 'renewal_reminder',
  'provider': 'sparrow_sms',
  'to_address': '9779800000000',
  'subject': null,
  'body': 'Your membership at Log Fitness ends on 14 Sep.',
  'status': 'sent',
  'attempts': 1,
  'scheduled_for': '2026-09-11T02:30:00+00:00',
  'next_attempt_at': '2026-09-11T02:30:00+00:00',
  'provider_status': 200,
  'provider_message_id': 'sp-99123',
  'last_error': null,
  'sent_at': '2026-09-11T02:30:04+00:00',
  'dedupe_key': 'renewal_reminder:44444444:2026-09-14',
  'created_by': '55555555-5555-5555-5555-555555555555',
  'created_at': '2026-09-11T02:30:00+00:00',
  'updated_at': '2026-09-11T02:30:04+00:00',
  ...overrides,
};

void main() {
  group('NotificationMessage.fromJson', () {
    test('maps a realistic sent row', () {
      final message = NotificationMessage.fromJson(_messageRow());

      expect(message.id, '11111111-1111-1111-1111-111111111111');
      expect(message.orgId, '22222222-2222-2222-2222-222222222222');
      expect(message.branchId, '33333333-3333-3333-3333-333333333333');
      expect(message.memberId, '44444444-4444-4444-4444-444444444444');
      expect(message.staffId, isNull);
      expect(message.visitorId, isNull);
      expect(message.channel, NotificationChannel.sms);
      expect(message.event, NotificationEvent.renewalReminder);
      expect(message.provider, NotificationProviderKind.sparrowSms);
      expect(message.toAddress, '9779800000000');
      expect(message.subject, isNull);
      expect(message.status, NotificationStatus.sent);
      expect(message.attempts, 1);
      expect(message.scheduledFor, DateTime.parse('2026-09-11T02:30:00Z'));
      expect(message.nextAttemptAt, DateTime.parse('2026-09-11T02:30:00Z'));
      expect(message.providerStatus, 200);
      expect(message.providerMessageId, 'sp-99123');
      expect(message.lastError, isNull);
      expect(message.sentAt, DateTime.parse('2026-09-11T02:30:04Z'));
      expect(message.dedupeKey, 'renewal_reminder:44444444:2026-09-14');
      expect(message.createdBy, '55555555-5555-5555-5555-555555555555');
    });

    test('a queued row carries no provider -- it is resolved at send time', () {
      final message = NotificationMessage.fromJson(
        _messageRow(
          overrides: <String, dynamic>{
            'provider': null,
            'status': 'queued',
            'attempts': 0,
            'provider_status': null,
            'provider_message_id': null,
            'sent_at': null,
          },
        ),
      );

      expect(message.provider, isNull);
      expect(message.status, NotificationStatus.queued);
      expect(message.sentAt, isNull);
    });

    test('a null branch_id is an org-wide message, not a broken row', () {
      // A staff invitation or a gateway test belongs to the org rather than to
      // a branch. Every branch filter has to carry it; a model that refused it
      // would hide it first.
      final message = NotificationMessage.fromJson(
        _messageRow(
          overrides: <String, dynamic>{
            'branch_id': null,
            'member_id': null,
            'event': 'test_message',
          },
        ),
      );

      expect(message.branchId, isNull);
      expect(message.memberId, isNull);
      expect(message.event, NotificationEvent.testMessage);
    });

    test('a null created_by means a sweep raised it', () {
      final swept = NotificationMessage.fromJson(
        _messageRow(overrides: <String, dynamic>{'created_by': null}),
      );
      expect(swept.createdBy, isNull);
      expect(swept.isAutomatic, isTrue);

      expect(NotificationMessage.fromJson(_messageRow()).isAutomatic, isFalse);
    });

    test('ignores request_id, which the model omits on purpose', () {
      // `notification_messages.request_id bigint` is pg_net bookkeeping the
      // response reaper joins on, and nothing on a screen can use it. It is
      // left off the model deliberately; this asserts the decoder drops the
      // extra key rather than throwing on it, so the deliberate omission stays
      // a decision instead of becoming a crash the first time a row carries it.
      final message = NotificationMessage.fromJson(
        _messageRow(overrides: <String, dynamic>{'request_id': 90210}),
      );

      expect(message.id, '11111111-1111-1111-1111-111111111111');
      expect(message.toJson().containsKey('request_id'), isFalse);
    });

    test('a skipped row reads its reason out of last_error', () {
      final message = NotificationMessage.fromJson(
        _messageRow(
          overrides: <String, dynamic>{
            'status': 'skipped',
            'provider': null,
            'sent_at': null,
            'last_error': 'No active sms gateway',
          },
        ),
      );

      expect(message.status, NotificationStatus.skipped);
      expect(message.lastError, 'No active sms gateway');
    });
  });

  group('NotificationMessage state', () {
    NotificationMessage withStatus(NotificationStatus status) =>
        NotificationMessage.fromJson(
          _messageRow(overrides: <String, dynamic>{'status': status.wire}),
        );

    test('isPending is queued and sending only -- what live refresh polls', () {
      expect(withStatus(NotificationStatus.queued).isPending, isTrue);
      expect(withStatus(NotificationStatus.sending).isPending, isTrue);
      for (final status in <NotificationStatus>[
        NotificationStatus.sent,
        NotificationStatus.failed,
        NotificationStatus.cancelled,
        NotificationStatus.skipped,
      ]) {
        expect(withStatus(status).isPending, isFalse);
      }
    });

    test('isResendable matches the three states retry_notification takes', () {
      // Including `skipped`: the RPC allows it, so once the gateway is
      // configured the row that was never sent can be sent.
      expect(withStatus(NotificationStatus.failed).isResendable, isTrue);
      expect(withStatus(NotificationStatus.cancelled).isResendable, isTrue);
      expect(withStatus(NotificationStatus.skipped).isResendable, isTrue);
      expect(withStatus(NotificationStatus.sent).isResendable, isFalse);
      expect(withStatus(NotificationStatus.queued).isResendable, isFalse);
      expect(withStatus(NotificationStatus.sending).isResendable, isFalse);
    });

    test('only a queued row may be cancelled', () {
      // `sending` is already claimed by the outbox: cancelling it would
      // promise something the gateway has already been told.
      expect(withStatus(NotificationStatus.queued).isCancellable, isTrue);
      for (final status in <NotificationStatus>[
        NotificationStatus.sending,
        NotificationStatus.sent,
        NotificationStatus.failed,
        NotificationStatus.cancelled,
        NotificationStatus.skipped,
      ]) {
        expect(withStatus(status).isCancellable, isFalse);
      }
    });
  });

  group('NotificationProvider.fromJson', () {
    test('maps a realistic SMSPasal row, config and all', () {
      final provider = NotificationProvider.fromJson(<String, dynamic>{
        'id': '66666666-6666-6666-6666-666666666666',
        'org_id': '22222222-2222-2222-2222-222222222222',
        'channel': 'sms',
        'provider': 'smspasal_sms',
        'sender_id': 'LOGFIT',
        'endpoint_url': null,
        'config': <String, dynamic>{
          'campaign': '1234',
          'routeid': '66',
          'sender_ntc': 'LOGFIT',
        },
        'is_active': true,
        'secret_name': 'notif:66666666-6666-6666-6666-666666666666',
        'created_by': '55555555-5555-5555-5555-555555555555',
        'created_at': '2026-09-10T06:00:00+00:00',
        'updated_at': '2026-09-10T06:00:00+00:00',
      });

      expect(provider.channel, NotificationChannel.sms);
      expect(provider.provider, NotificationProviderKind.smspasalSms);
      expect(provider.senderId, 'LOGFIT');
      expect(provider.endpointUrl, isNull);
      expect(provider.isActive, isTrue);
      // A reference, never a token: `notification_credential` is revoked from
      // every client role, so this is the most the app can ever hold.
      expect(
        provider.secretName,
        'notif:66666666-6666-6666-6666-666666666666',
      );
      expect(provider.configString('routeid'), '66');
      expect(provider.configString('campaign'), '1234');
      expect(provider.configString('missing'), isNull);
    });

    test('a senderless gateway and an empty config still decode', () {
      final provider = NotificationProvider.fromJson(<String, dynamic>{
        'id': 'p-2',
        'org_id': 'org-1',
        'channel': 'sms',
        'provider': 'aakash_sms',
        'sender_id': null,
        'endpoint_url': null,
        'config': <String, dynamic>{},
        'is_active': false,
        'secret_name': null,
        'created_by': null,
        'created_at': '2026-09-10T06:00:00+00:00',
        'updated_at': '2026-09-10T06:00:00+00:00',
      });

      // Aakash fixes the sender on the account, so the column is genuinely
      // empty rather than unfilled.
      expect(provider.senderId, isNull);
      expect(provider.config, isEmpty);
      expect(provider.isActive, isFalse);
      expect(provider.secretName, isNull);
    });

    test('a blank config value reads as absent, not as an empty string', () {
      final provider = NotificationProvider.fromJson(<String, dynamic>{
        'id': 'p-3',
        'org_id': 'org-1',
        'channel': 'sms',
        'provider': 'sparrow_sms',
        'config': <String, dynamic>{'routeid': '   '},
        'is_active': true,
        'created_at': '2026-09-10T06:00:00+00:00',
        'updated_at': '2026-09-10T06:00:00+00:00',
      });

      expect(provider.configString('routeid'), isNull);
    });
  });

  group('GatewayBalanceRoute.fromJson', () {
    test('decodes SCREAMING keys with a numeric BALANCE', () {
      // What SMSPasal actually answers, whatever its documentation says.
      final route = GatewayBalanceRoute.fromJson(<String, dynamic>{
        'ROUTE_ID': 66,
        'ROUTE': 'NTC',
        'BALANCE': 1450,
      });

      expect(route.route, 'NTC');
      expect(route.routeIdText, '66');
      expect(route.balanceText, '1450');
    });

    test('decodes the same row with a string BALANCE', () {
      // What its documentation says it answers. Both are accepted rather than
      // trusting either, because a screen that threw here would show "balance
      // unavailable" on a gateway that answered perfectly well.
      final route = GatewayBalanceRoute.fromJson(<String, dynamic>{
        'ROUTE_ID': '66',
        'ROUTE': 'NTC',
        'BALANCE': '1450',
      });

      expect(route.routeIdText, '66');
      expect(route.balanceText, '1450');
    });

    test('missing keys read as empty rather than throwing', () {
      final route = GatewayBalanceRoute.fromJson(<String, dynamic>{});
      expect(route.routeIdText, '');
      expect(route.route, '');
      expect(route.balanceText, '');
    });
  });

  group('GatewayBalance.fromJson', () {
    test('a pending answer has no routes and no error yet', () {
      final balance = GatewayBalance.fromJson(<String, dynamic>{
        'pending': true,
      });

      expect(balance.pending, isTrue);
      expect(balance.routes, isNull);
      expect(balance.error, isNull);
      expect(balance.hasAnswer, isFalse);
    });

    test('a settled answer carries its routes and the time it was read', () {
      final balance = GatewayBalance.fromJson(<String, dynamic>{
        'pending': false,
        'routes': <dynamic>[
          <String, dynamic>{'ROUTE_ID': '66', 'ROUTE': 'NTC', 'BALANCE': 1450},
          <String, dynamic>{'ROUTE_ID': 67, 'ROUTE': 'NCELL', 'BALANCE': '12'},
        ],
        'error': null,
        'checked_at': '2026-09-12T04:00:00+00:00',
      });

      expect(balance.pending, isFalse);
      expect(balance.routes, hasLength(2));
      expect(balance.routes![1].route, 'NCELL');
      expect(balance.routes![1].balanceText, '12');
      expect(balance.checkedAt, DateTime.parse('2026-09-12T04:00:00Z'));
      expect(balance.hasAnswer, isTrue);
    });

    test('a refusal is an answer too', () {
      final balance = GatewayBalance.fromJson(<String, dynamic>{
        'pending': false,
        'error': 'Gateway returned 401',
      });

      expect(balance.error, 'Gateway returned 401');
      expect(balance.hasAnswer, isTrue);
    });
  });

  group('NotificationRule', () {
    NotificationRule rule({
      String event = 'renewal_reminder',
      String sendAt = '09:00:00',
      int offsetDays = 7,
      int minAmountPaisa = 0,
      int repeatAfterDays = 0,
    }) => NotificationRule.fromJson(<String, dynamic>{
      'id': 'r-1',
      'org_id': 'org-1',
      'event': event,
      'channel': 'sms',
      'enabled': true,
      'offset_days': offsetDays,
      'min_amount_paisa': minAmountPaisa,
      'repeat_after_days': repeatAfterDays,
      'send_at_local': sendAt,
      'created_at': '2026-09-09T10:00:00+00:00',
      'updated_at': '2026-09-09T10:00:00+00:00',
    });

    test('maps a realistic dues row', () {
      final duesRule = rule(
        event: 'dues_reminder',
        offsetDays: 3,
        minAmountPaisa: 50000,
        repeatAfterDays: 7,
      );

      expect(duesRule.event, NotificationEvent.duesReminder);
      expect(duesRule.channel, NotificationChannel.sms);
      expect(duesRule.enabled, isTrue);
      expect(duesRule.offsetDays, 3);
      // Paisa, integer, formatted only at the render boundary -- Rs 500.
      expect(duesRule.minAmountPaisa, 50000);
      expect(duesRule.repeatAfterDays, 7);
      expect(duesRule.hasMinAmount, isTrue);
      expect(duesRule.hasRepeat, isTrue);
    });

    test('send_at_local stays text: 09:00:00 shows as 09:00', () {
      // A `time` has no date and no zone. Anything that routed it through a
      // DateTime would move the sweep hour by the device's offset.
      expect(rule().sendAtLocal, '09:00:00');
      expect(rule().sendAtHhMm, '09:00');
      expect(rule(sendAt: '18:45:00').sendAtHhMm, '18:45');
      // A column already trimmed to HH:MM survives unchanged.
      expect(rule(sendAt: '07:15').sendAtHhMm, '07:15');
    });

    test('sendAt parses the text into a picker value', () {
      expect(rule(sendAt: '18:45:00').sendAt, const TimeOfDay(hour: 18, minute: 45));
      expect(rule(sendAt: '00:00:00').sendAt, const TimeOfDay(hour: 0, minute: 0));
    });

    test('sendAtToWire turns a picker value back, zero-padded', () {
      expect(sendAtToWire(const TimeOfDay(hour: 9, minute: 0)), '09:00');
      expect(sendAtToWire(const TimeOfDay(hour: 18, minute: 45)), '18:45');
      expect(sendAtToWire(const TimeOfDay(hour: 0, minute: 5)), '00:05');
    });

    test('a time round-trips through the picker and back unchanged', () {
      expect(sendAtToWire(rule(sendAt: '09:00:00').sendAt), '09:00');
      expect(sendAtToWire(rule(sendAt: '23:59:00').sendAt), '23:59');
    });

    test('isImmediate is true for the four trigger-driven rules', () {
      // Each rides an `after insert` or `after update` trigger on the row that
      // causes it, so there is no hour to choose. Offering a time picker would
      // promise a schedule that does not exist.
      for (final event in <String>[
        'visitor_welcome',
        'member_welcome',
        'payment_received',
        'dues_cleared',
      ]) {
        expect(rule(event: event).isImmediate, isTrue, reason: event);
      }
      for (final event in <String>[
        'renewal_reminder',
        'dues_reminder',
        'birthday_greeting',
        'visitor_follow_up',
      ]) {
        expect(rule(event: event).isImmediate, isFalse, reason: event);
      }
    });

    test('hasMinAmount is true for the dues chase and the receipt', () {
      // Both spend a message on an amount an owner may consider too small to
      // be worth one. Nothing else reads the column.
      expect(rule(event: 'dues_reminder').hasMinAmount, isTrue);
      expect(rule(event: 'payment_received').hasMinAmount, isTrue);
      for (final event in <String>[
        'renewal_reminder',
        'birthday_greeting',
        'visitor_welcome',
        'member_welcome',
        'dues_cleared',
      ]) {
        expect(rule(event: event).hasMinAmount, isFalse, reason: event);
      }
    });

    test('hasRepeat is true for dues_reminder only', () {
      // A cadence belongs to a chase. The receipt fires every time money
      // arrives, which is not the same thing as asking again.
      expect(rule(event: 'dues_reminder').hasRepeat, isTrue);
      for (final event in <String>[
        'renewal_reminder',
        'payment_received',
        'member_welcome',
        'dues_cleared',
      ]) {
        expect(rule(event: event).hasRepeat, isFalse, reason: event);
      }
    });
  });

  group('NotificationTemplate', () {
    test('maps a realistic org-owned row', () {
      final template = NotificationTemplate.fromJson(<String, dynamic>{
        'id': 't-1',
        'org_id': 'org-1',
        'event': 'renewal_reminder',
        'channel': 'sms',
        'locale': 'ne',
        'subject': null,
        'body': 'नमस्ते {{name}}, तपाईंको सदस्यता {{end_date}} मा सकिन्छ।',
        'is_active': true,
        'updated_by': '55555555-5555-5555-5555-555555555555',
        'created_at': '2026-09-09T10:00:00+00:00',
        'updated_at': '2026-09-10T11:00:00+00:00',
      });

      expect(template.event, NotificationEvent.renewalReminder);
      expect(template.channel, NotificationChannel.sms);
      // A CHECK constraint upstream, not an enum, so it stays a String here.
      expect(template.locale, 'ne');
      expect(template.subject, isNull);
      expect(template.isActive, isTrue);
      expect(template.updatedBy, '55555555-5555-5555-5555-555555555555');
    });

    test('a preview with a template_id is the org\'s own wording', () {
      final preview = NotificationTemplatePreview.fromJson(<String, dynamic>{
        'template_id': 't-1',
        'subject': null,
        'body': 'Your membership ends on {{end_date}}.',
      });

      expect(preview.isOrgOwned, isTrue);
      expect(preview.templateId, 't-1');
      expect(preview.body, 'Your membership ends on {{end_date}}.');
    });

    test('a preview with no template_id is the built-in', () {
      // Which is what decides whether "reset to the built-in wording" is even
      // offered: there is nothing to reset when the org never edited it.
      final preview = NotificationTemplatePreview.fromJson(<String, dynamic>{
        'template_id': null,
        'subject': null,
        'body': 'Built-in wording.',
      });

      expect(preview.isOrgOwned, isFalse);
    });

    test('a missing body reads as empty rather than throwing', () {
      expect(
        NotificationTemplatePreview.fromJson(<String, dynamic>{}).body,
        '',
      );
    });
  });

  group('MemberMessagePreview.canSend', () {
    Map<String, dynamic> row({
      bool optOut = false,
      bool reachable = true,
      bool hasGateway = true,
    }) => <String, dynamic>{
      'to_address': '9779800000000',
      'subject': null,
      'body': 'You owe Rs 3,400.',
      'opt_out': optOut,
      'reachable': reachable,
      'has_gateway': hasGateway,
    };

    test('true only when all three are clear', () {
      final preview = MemberMessagePreview.fromJson(row());
      expect(preview.toAddress, '9779800000000');
      expect(preview.body, 'You owe Rs 3,400.');
      expect(preview.canSend, isTrue);
    });

    test('an opted-out member is refused -- consent is not overridable', () {
      // `send_member_notification` raises `check_violation` for this, so the
      // button being hidden and the database refusing agree by construction.
      final preview = MemberMessagePreview.fromJson(row(optOut: true));
      expect(preview.optOut, isTrue);
      expect(preview.canSend, isFalse);
    });

    test('an unreachable number blocks the send', () {
      // `normalise_msisdn` could make nothing deliverable of what is on file.
      expect(
        MemberMessagePreview.fromJson(row(reachable: false)).canSend,
        isFalse,
      );
    });

    test('no gateway on the channel blocks the send', () {
      expect(
        MemberMessagePreview.fromJson(row(hasGateway: false)).canSend,
        isFalse,
      );
    });

    test('a missing flag fails closed', () {
      // The decoder tests `== true`, so an absent or null flag reads as false
      // rather than as permission.
      final preview = MemberMessagePreview.fromJson(<String, dynamic>{
        'to_address': null,
        'body': null,
      });

      expect(preview.optOut, isFalse);
      expect(preview.reachable, isFalse);
      expect(preview.hasGateway, isFalse);
      expect(preview.canSend, isFalse);
    });
  });

  group('VisitorMessagePreview.canSend', () {
    // A walk-in has no standing instruction to honour -- there is no opt-out
    // concept at all, and the desk removes them from the sweep by marking them
    // "not joining" instead.
    Map<String, dynamic> row({
      bool reachable = true,
      bool hasGateway = true,
    }) => <String, dynamic>{
      'to_address': '9779811111111',
      'subject': null,
      'body': 'Thanks for visiting Log Fitness.',
      'reachable': reachable,
      'has_gateway': hasGateway,
    };

    test('true when the number works and a gateway exists', () {
      final preview = VisitorMessagePreview.fromJson(row());
      expect(preview.toAddress, '9779811111111');
      expect(preview.canSend, isTrue);
    });

    test('an opt_out key on the row changes nothing', () {
      // Guards the asymmetry on purpose: if the RPC ever started sending one,
      // the visitor sheet must not start honouring a flag the product does not
      // hold for a walk-in.
      final preview = VisitorMessagePreview.fromJson(<String, dynamic>{
        ...row(),
        'opt_out': true,
      });

      expect(preview.canSend, isTrue);
    });

    test('unreachable or no gateway blocks the send', () {
      expect(
        VisitorMessagePreview.fromJson(row(reachable: false)).canSend,
        isFalse,
      );
      expect(
        VisitorMessagePreview.fromJson(row(hasGateway: false)).canSend,
        isFalse,
      );
    });
  });
}
