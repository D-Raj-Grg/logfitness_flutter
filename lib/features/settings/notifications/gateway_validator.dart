// What a gateway form will and will not accept, decided without a widget.
//
// Dart port of `notificationProviderFormSchema` in
// `logfitness_saas/lib/validation/notifications.ts`, refinements included. The
// sentences are copied rather than paraphrased: an owner who reads
// "SMSPasal needs a sender ID approved on your account" on the console and
// something else here has to work out whether they are the same complaint.
//
// Pure on purpose -- no widget, no `BuildContext`, no repository. The console
// gets to run its schema in a unit test; this exists so the same eight or nine
// cases can be pinned here instead of being reachable only by driving a form.
// `test/features/settings/notifications/gateway_validator_test.dart` is the
// other half of that bargain.
import 'dart:convert';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

/// One input on the gateway form. Errors are keyed by these rather than by a
/// string so a renamed field is a compile error and not a message that stops
/// appearing.
enum GatewayField {
  provider,
  senderId,
  endpointUrl,
  apiToken,
  configJson,
  campaign,
  routeid,
  senderNtc,
  senderNcell,
}

/// What each field is called when a summary line has to name it. Mirrors
/// `FIELD_LABELS` in the console's `actions.ts`.
String gatewayFieldLabel(GatewayField field) => switch (field) {
  GatewayField.provider => 'Gateway',
  GatewayField.senderId => 'Sender ID',
  GatewayField.endpointUrl => 'Address',
  GatewayField.apiToken => 'API token',
  GatewayField.configJson => 'Request',
  GatewayField.campaign => 'Campaign ID',
  GatewayField.routeid => 'Route ID',
  GatewayField.senderNtc => 'NTC sender ID',
  GatewayField.senderNcell => 'Ncell sender ID',
};

/// The outcome of validating one gateway form.
///
/// Carries the *cleaned* values as well as the errors, so the caller saves what
/// was validated rather than re-trimming the raw controllers and hoping the two
/// passes agree.
class GatewayFormValidation {
  const GatewayFormValidation({
    required this.errors,
    required this.senderId,
    required this.endpointUrl,
    required this.apiToken,
    required this.config,
  });

  final Map<GatewayField, String> errors;

  /// Trimmed, or null when the owner left it blank. Null reaches the column:
  /// "the owner cleared the sender ID" is a real edit.
  final String? senderId;
  final String? endpointUrl;

  /// **Null means "leave the stored token alone".**
  ///
  /// There is no path from this app to a stored token --
  /// `notification_credential` is callable by no client role -- so a form that
  /// tried to round-trip one would have to send a placeholder and then guess
  /// whether the owner meant it. Blank is therefore silence, not "clear it";
  /// clearing is its own button.
  final String? apiToken;

  /// What goes into `notification_providers.config`.
  final Map<String, dynamic> config;

  bool get isValid => errors.isEmpty;

  /// One line naming what is wrong, for a snackbar above the form. Some of
  /// these inputs are only on screen for some gateways, and a complaint about
  /// a field the owner cannot see reads as a button that does nothing.
  String get summary {
    if (errors.isEmpty) return '';
    return errors.entries
        .map(
          (MapEntry<GatewayField, String> e) =>
              '${gatewayFieldLabel(e.key)}: ${e.value}',
        )
        .join(' · ');
  }
}

/// `optionalText` upstream: trim, and treat blank as absent.
///
/// `nullish`, not `optional`, in the console for a reason that survives the
/// port: a field that is not on screen at all -- the sender ID on a senderless
/// gateway, the campaign id on a gateway that has none -- arrives as null, and
/// refusing the whole form over an input the owner could not see is worse than
/// any validation it might have done.
String? _clean(String? value) {
  final String trimmed = (value ?? '').trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// `^[A-Za-z0-9_-]*$` -- a gateway's own id for a campaign or a route. Digits
/// in practice, but the gateway owns the format, so this only refuses the
/// shapes that could not survive a query string.
final RegExp _idLike = RegExp(r'^[A-Za-z0-9_-]*$');

/// `^[A-Za-z0-9_.-]*$` -- a sender ID as an operator registers it: short, and
/// not free text.
final RegExp _senderIdLike = RegExp(r'^[A-Za-z0-9_.-]*$');

/// Validates one gateway form exactly as the console's schema does.
///
/// [provider] is never invalid on its own here -- it comes off a picker built
/// from `CHOICES`, so there is no free-text path to an unknown value the way
/// there is through a `FormData`.
GatewayFormValidation validateGatewayForm({
  required NotificationProviderKind provider,
  String? senderId,
  String? endpointUrl,
  String? apiToken,
  String? configJson,
  String? campaign,
  String? routeid,
  String? senderNtc,
  String? senderNcell,
}) {
  final Map<GatewayField, String> errors = <GatewayField, String>{};

  final String? cleanSender = _clean(senderId);
  if (cleanSender != null && cleanSender.length > 32) {
    errors[GatewayField.senderId] = 'That is longer than 32 characters.';
  }

  // A gateway carries a token in every request it makes, so its endpoint has
  // to be TLS. The database says the same thing in a CHECK; this is here so
  // the form can refuse it readably instead of surfacing a constraint name.
  final String? cleanEndpoint = _clean(endpointUrl);
  if (cleanEndpoint != null) {
    if (cleanEndpoint.length > 400) {
      errors[GatewayField.endpointUrl] = 'That is longer than 400 characters.';
    } else if (!cleanEndpoint.startsWith('https://')) {
      errors[GatewayField.endpointUrl] =
          'The address must start with https:// -- the gateway token travels in the request';
    }
  }

  final String? cleanToken = _clean(apiToken);
  if (cleanToken != null && cleanToken.length > 500) {
    errors[GatewayField.apiToken] = 'That token is too long.';
  }

  final String? cleanCampaign = _clean(campaign);
  if (cleanCampaign != null) {
    if (cleanCampaign.length > 32) {
      errors[GatewayField.campaign] = 'That is longer than 32 characters.';
    } else if (!_idLike.hasMatch(cleanCampaign)) {
      errors[GatewayField.campaign] =
          'Use only letters, numbers, dashes or underscores';
    }
  }

  final String? cleanRouteId = _clean(routeid);
  if (cleanRouteId != null) {
    if (cleanRouteId.length > 32) {
      errors[GatewayField.routeid] = 'That is longer than 32 characters.';
    } else if (!_idLike.hasMatch(cleanRouteId)) {
      errors[GatewayField.routeid] =
          'Use only letters, numbers, dashes or underscores';
    }
  }

  final String? cleanNtc = _clean(senderNtc);
  if (cleanNtc != null) {
    if (cleanNtc.length > 32) {
      errors[GatewayField.senderNtc] = 'That is longer than 32 characters.';
    } else if (!_senderIdLike.hasMatch(cleanNtc)) {
      errors[GatewayField.senderNtc] =
          'Use only letters, numbers, dots, dashes or underscores';
    }
  }

  final String? cleanNcell = _clean(senderNcell);
  if (cleanNcell != null) {
    if (cleanNcell.length > 32) {
      errors[GatewayField.senderNcell] = 'That is longer than 32 characters.';
    } else if (!_senderIdLike.hasMatch(cleanNcell)) {
      errors[GatewayField.senderNcell] =
          'Use only letters, numbers, dots, dashes or underscores';
    }
  }

  // --- the two refinements ------------------------------------------------
  //
  // Both are the form saying out loud what the gateway would otherwise say by
  // silently sending nothing.

  if (provider == NotificationProviderKind.smspasalSms && cleanSender == null) {
    errors[GatewayField.senderId] =
        'SMSPasal needs a sender ID approved on your account';
  }

  if (provider == NotificationProviderKind.customHttp &&
      cleanEndpoint == null) {
    errors[GatewayField.endpointUrl] =
        'A custom gateway needs an address to call';
  }

  // --- the request template ------------------------------------------------

  final String? cleanConfig = _clean(configJson);
  Map<String, dynamic> parsedConfig = <String, dynamic>{};
  if (cleanConfig != null) {
    Object? decoded;
    bool ok = true;
    try {
      decoded = jsonDecode(cleanConfig);
    } catch (_) {
      ok = false;
    }
    // An object, and specifically not a list or a bare scalar: the request
    // builder reads named keys out of it, so `[1,2]` would parse and then mean
    // nothing.
    if (!ok || decoded is! Map<String, dynamic>) {
      errors[GatewayField.configJson] =
          'The gateway settings must be a JSON object';
    } else {
      parsedConfig = decoded;
    }
  }

  return GatewayFormValidation(
    errors: errors,
    senderId: cleanSender,
    endpointUrl: cleanEndpoint,
    apiToken: cleanToken,
    config: gatewayConfig(
      provider: provider,
      parsedConfigJson: parsedConfig,
      campaign: cleanCampaign,
      routeid: cleanRouteId,
      senderNtc: cleanNtc,
      senderNcell: cleanNcell,
    ),
  );
}

/// What ends up in `notification_providers.config`. Mirrors `providerConfig()`
/// in the console's `actions.ts`.
///
/// A custom gateway describes its whole request there. SMSPasal only carries
/// the account ids, and **a blank one is dropped rather than stored as an empty
/// string**: the request builder omits the parameter entirely when the key is
/// absent, which is what makes the gateway fall back to the account default.
/// Sending `campaign=` is a different request from sending no campaign at all.
///
/// The two sender keys are the NTC/Ncell split. `nepal_mobile_carrier()` reads
/// the operator off the recipient's prefix -- NTC is 984, 985, 986, 974, 975,
/// 976; Ncell is 980, 981, 982, 970 -- and the SMSPasal arm picks
/// `config.sender_ntc` or `config.sender_ncell` accordingly, falling back to
/// the gateway's own `sender_id` when the gym has registered only one. Smart,
/// UTL and Hello are revoked ranges and match neither.
Map<String, dynamic> gatewayConfig({
  required NotificationProviderKind provider,
  Map<String, dynamic> parsedConfigJson = const <String, dynamic>{},
  String? campaign,
  String? routeid,
  String? senderNtc,
  String? senderNcell,
}) {
  final Map<String, dynamic> base =
      provider == NotificationProviderKind.customHttp
      ? Map<String, dynamic>.of(parsedConfigJson)
      : <String, dynamic>{};

  if (provider != NotificationProviderKind.smspasalSms) return base;

  return <String, dynamic>{
    ...base,
    'campaign': ?campaign,
    'routeid': ?routeid,
    'sender_ntc': ?senderNtc,
    'sender_ncell': ?senderNcell,
  };
}
