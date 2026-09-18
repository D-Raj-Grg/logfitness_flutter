// The gateway form's rules, checked without a widget.
//
// The console gets to run `notificationProviderFormSchema` in a unit test;
// this is the other half of that bargain. Each case here is one an owner can
// actually hit on a Tuesday afternoon with a gateway dashboard open in another
// window, and each has cost somebody an evening at least once.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/settings/notifications/gateway_validator.dart';

void main() {
  group('validateGatewayForm', () {
    test(
      'SMSPasal without a sender ID is refused, in the console\'s words',
      () {
        final GatewayFormValidation result = validateGatewayForm(
          provider: NotificationProviderKind.smspasalSms,
          senderId: '   ',
          apiToken: 'key',
        );

        expect(result.isValid, isFalse);
        expect(
          result.errors[GatewayField.senderId],
          'SMSPasal needs a sender ID approved on your account',
        );
      },
    );

    test('SMSPasal with a sender ID is accepted', () {
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.smspasalSms,
        senderId: 'YOURGYM',
        apiToken: 'key',
      );

      expect(result.isValid, isTrue);
      expect(result.senderId, 'YOURGYM');
    });

    test('a custom gateway with no address is refused', () {
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.customHttp,
        endpointUrl: '',
      );

      expect(
        result.errors[GatewayField.endpointUrl],
        'A custom gateway needs an address to call',
      );
    });

    test('an http:// address is refused -- the token travels in the request', () {
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.customHttp,
        endpointUrl: 'http://gateway.example.com/send',
      );

      expect(
        result.errors[GatewayField.endpointUrl],
        'The address must start with https:// -- the gateway token travels in the request',
      );
    });

    test('config that is not JSON at all is refused', () {
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.customHttp,
        endpointUrl: 'https://gateway.example.com/send',
        configJson: '{method:',
      );

      expect(
        result.errors[GatewayField.configJson],
        'The gateway settings must be a JSON object',
      );
    });

    test('config that parses but is not an object is refused', () {
      // A list parses cleanly and then means nothing: the request builder
      // reads named keys out of it.
      for (final String notAnObject in <String>['[1,2]', '"text"', '42']) {
        final GatewayFormValidation result = validateGatewayForm(
          provider: NotificationProviderKind.customHttp,
          endpointUrl: 'https://gateway.example.com/send',
          configJson: notAnObject,
        );

        expect(
          result.errors[GatewayField.configJson],
          'The gateway settings must be a JSON object',
          reason: '$notAnObject is not a JSON object',
        );
      }
    });

    test('a JSON object config is kept, parsed', () {
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.customHttp,
        endpointUrl: 'https://gateway.example.com/send',
        configJson: '{"method":"GET","params":{"to":"{{to}}"}}',
      );

      expect(result.isValid, isTrue);
      expect(result.config['method'], 'GET');
    });

    test('a blank token means "leave the stored token alone"', () {
      // The one that matters most. There is no path from this app to a stored
      // token, so blank cannot be allowed to mean "clear it" -- clearing is
      // its own button, and a form that guessed would silence a gym's SMS on
      // an unrelated edit.
      for (final String? blank in <String?>[null, '', '   ']) {
        final GatewayFormValidation result = validateGatewayForm(
          provider: NotificationProviderKind.sparrowSms,
          senderId: 'YOURGYM',
          apiToken: blank,
        );

        expect(result.isValid, isTrue);
        expect(result.apiToken, isNull, reason: 'blank must not reach the RPC');
      }
    });

    test('a token that was typed is carried through, trimmed', () {
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.sparrowSms,
        senderId: 'YOURGYM',
        apiToken: '  v2-token  ',
      );

      expect(result.apiToken, 'v2-token');
    });

    test('a cleared sender ID reaches the column as null', () {
      // Not an omission: "the owner cleared the sender ID" is a real edit and
      // the whole-form save has to carry it.
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.sparrowSms,
        senderId: '',
      );

      expect(result.isValid, isTrue);
      expect(result.senderId, isNull);
    });

    test('Aakash needs neither a sender ID nor an address', () {
      // The sender identity is fixed on the account, so the field is not even
      // on screen and arrives null.
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.aakashSms,
        apiToken: 'auth-token',
      );

      expect(result.isValid, isTrue);
    });

    test(
      'campaign and route ids refuse what could not survive a query string',
      () {
        final GatewayFormValidation result = validateGatewayForm(
          provider: NotificationProviderKind.smspasalSms,
          senderId: 'YOURGYM',
          campaign: 'nine hundred',
          routeid: 'route/1',
        );

        expect(
          result.errors[GatewayField.campaign],
          'Use only letters, numbers, dashes or underscores',
        );
        expect(
          result.errors[GatewayField.routeid],
          'Use only letters, numbers, dashes or underscores',
        );
      },
    );
  });

  group('gatewayConfig', () {
    test('drops a blank SMSPasal id rather than storing an empty string', () {
      // Sending `campaign=` is a different request from sending no campaign at
      // all: the builder omits the parameter when the key is absent, which is
      // what makes the gateway fall back to the account default.
      final GatewayFormValidation result = validateGatewayForm(
        provider: NotificationProviderKind.smspasalSms,
        senderId: 'YOURGYM',
        campaign: '',
        routeid: '10259',
      );

      expect(result.config.containsKey('campaign'), isFalse);
      expect(result.config['routeid'], '10259');
    });

    test(
      'carries the NTC/Ncell sender split under the keys the sender reads',
      () {
        final GatewayFormValidation result = validateGatewayForm(
          provider: NotificationProviderKind.smspasalSms,
          senderId: 'YOURGYM',
          senderNtc: 'GYMNTC',
          senderNcell: 'GYMNCELL',
        );

        expect(result.config['sender_ntc'], 'GYMNTC');
        expect(result.config['sender_ncell'], 'GYMNCELL');
      },
    );

    test('a non-custom gateway never carries a request template', () {
      // `configJson` is only on screen for `custom_http`. Anything left over
      // from a picker change must not be saved behind the owner's back.
      final Map<String, dynamic> config = gatewayConfig(
        provider: NotificationProviderKind.sparrowSms,
        parsedConfigJson: <String, dynamic>{'method': 'GET'},
      );

      expect(config, isEmpty);
    });
  });
}
