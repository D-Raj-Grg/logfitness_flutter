// One channel's gateway: which provider carries the gym's messages, what it
// sends as, and the token it sends with.
//
// Port of `logfitness_saas/components/notifications/provider-form.tsx`. The
// hint under the picker, the field labels and the two refinement messages are
// copied rather than rewritten -- an owner who set the gym up on a laptop and
// is now fixing it on a phone is reading about the same account.
//
// The rules this screen is built around, in the order they bite:
//
//  1. **The token is write-only.** `notification_credential` is revoked from
//     every client role, so there is no path from this app to a stored token.
//     The form shows "A token is stored" and never a value, and a blank token
//     box means "leave the stored one alone" -- see [GatewayFormValidation].
//  2. **Everything here is owner-only in RLS.** The entry point is gated on
//     `StaffCapability.configureNotifications`, and a `42501` that arrives
//     anyway is rendered, never swallowed.
//  3. **Validation is pure and lives elsewhere** (`gateway_validator.dart`),
//     so the cases that matter are pinned by a unit test instead of being
//     reachable only by driving a form.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/settings/notifications/gateway_balance_controller.dart';
import 'package:logfitness_flutter/features/settings/notifications/gateway_validator.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_actions.dart';

/// One entry in the gateway picker.
class GatewayChoice {
  const GatewayChoice({
    required this.value,
    required this.label,
    required this.hint,
  });

  final NotificationProviderKind value;
  final String label;

  /// Shown under the picker. Says what the account is and what it will ask
  /// for, because the owner is usually holding a different browser tab open on
  /// the gateway's own dashboard while they read it.
  final String hint;
}

/// Which gateways make sense on which channel. `CHOICES` upstream, verbatim.
///
/// **`log_only` is deliberately absent**, mirroring the console's own omission
/// (`lib/validation/notifications.ts`). It exists in the database so the
/// pipeline can be exercised with no gateway account, and it is what the sender
/// falls back to; offering it here would let an owner switch messages off in a
/// way that looks exactly like switching them on.
const Map<NotificationChannel, List<GatewayChoice>>
kGatewayChoices = <NotificationChannel, List<GatewayChoice>>{
  NotificationChannel.sms: <GatewayChoice>[
    GatewayChoice(
      value: NotificationProviderKind.sparrowSms,
      label: 'Sparrow SMS',
      hint:
          'sparrowsms.com. Needs a token and the sender ID registered on your account.',
    ),
    GatewayChoice(
      value: NotificationProviderKind.aakashSms,
      label: 'Aakash SMS',
      hint:
          'aakashsms.com. The sender ID is fixed on the account, so leave it blank.',
    ),
    GatewayChoice(
      value: NotificationProviderKind.smspasalSms,
      label: 'SMSPasal',
      hint:
          'smspasal.com. Needs the API key from Developer API and a sender ID approved on your account.',
    ),
    GatewayChoice(
      value: NotificationProviderKind.customHttp,
      label: 'Another gateway',
      hint:
          'Any provider with an HTTP API. You supply the address and the parameter names.',
    ),
  ],
  NotificationChannel.viber: <GatewayChoice>[
    GatewayChoice(
      value: NotificationProviderKind.viberBusiness,
      label: 'Viber Business',
      hint: 'Needs a Public Account auth token from Viber.',
    ),
    GatewayChoice(
      value: NotificationProviderKind.customHttp,
      label: 'A Viber reseller',
      hint: 'Most Nepali Viber routes are resold behind an SMS-style HTTP API.',
    ),
  ],
  NotificationChannel.email: <GatewayChoice>[
    GatewayChoice(
      value: NotificationProviderKind.resendEmail,
      label: 'Resend',
      hint: 'resend.com. The sender must be a verified address.',
    ),
    GatewayChoice(
      value: NotificationProviderKind.customHttp,
      label: 'Another provider',
      hint: 'Any provider with an HTTP API.',
    ),
  ],
};

/// Gateways whose sender identity is fixed on the account, so there is nothing
/// to type. `SENDERLESS` upstream. Aakash is the one: its send takes no `from`
/// at all (docs/notifications.md §1).
const Set<NotificationProviderKind> kSenderlessGateways =
    <NotificationProviderKind>{NotificationProviderKind.aakashSms};

class GatewayForm extends ConsumerStatefulWidget {
  const GatewayForm({
    required this.channel,
    required this.gateway,
    required this.hasToken,
    super.key,
  });

  final NotificationChannel channel;

  /// The row this channel would actually send through, or null when the
  /// channel has never been set up.
  final NotificationProvider? gateway;

  /// Whether a token is stored. **Never the token**: it cannot be read back.
  final bool hasToken;

  @override
  ConsumerState<GatewayForm> createState() => _GatewayFormState();
}

class _GatewayFormState extends ConsumerState<GatewayForm> {
  late final TextEditingController _senderId;
  late final TextEditingController _endpointUrl;
  late final TextEditingController _configJson;
  late final TextEditingController _campaign;
  late final TextEditingController _routeId;
  late final TextEditingController _senderNtc;
  late final TextEditingController _senderNcell;
  final TextEditingController _apiToken = TextEditingController();
  final TextEditingController _testTo = TextEditingController();

  late NotificationProviderKind _kind;
  late bool _isActive;
  bool _replacingToken = false;
  Map<GatewayField, String> _errors = const <GatewayField, String>{};

  List<GatewayChoice> get _choices =>
      kGatewayChoices[widget.channel] ?? const <GatewayChoice>[];

  GatewayChoice get _choice => _choices.firstWhere(
    (GatewayChoice option) => option.value == _kind,
    orElse: () => _choices.first,
  );

  @override
  void initState() {
    super.initState();
    final NotificationProvider? row = widget.gateway;

    _kind = row == null
        ? _choices.first.value
        // A row can hold a gateway this picker does not offer -- `log_only`,
        // or one set from the console before a choice was removed. Falling
        // back to the first option rather than crashing keeps the screen
        // usable, and saving is what actually changes the row.
        : (_choices.any((GatewayChoice o) => o.value == row.provider)
              ? row.provider
              : _choices.first.value);
    _isActive = row?.isActive ?? true;

    _senderId = TextEditingController(text: row?.senderId ?? '');
    _endpointUrl = TextEditingController(text: row?.endpointUrl ?? '');
    _configJson = TextEditingController(
      text: (row == null || row.config.isEmpty)
          ? ''
          : const JsonEncoder.withIndent('  ').convert(row.config),
    );
    // `config` is free-form jsonb, so the SMSPasal ids are read out of it
    // defensively rather than trusted to be strings -- `configString` returns
    // null for anything that is not usable text.
    _campaign = TextEditingController(
      text: row?.configString('campaign') ?? '',
    );
    _routeId = TextEditingController(text: row?.configString('routeid') ?? '');
    _senderNtc = TextEditingController(
      text: row?.configString('sender_ntc') ?? '',
    );
    _senderNcell = TextEditingController(
      text: row?.configString('sender_ncell') ?? '',
    );
  }

  @override
  void dispose() {
    _senderId.dispose();
    _endpointUrl.dispose();
    _configJson.dispose();
    _campaign.dispose();
    _routeId.dispose();
    _senderNtc.dispose();
    _senderNcell.dispose();
    _apiToken.dispose();
    _testTo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NotificationProvider? row = widget.gateway;
    final bool saving = ref.watch(notificationSettingsActionsProvider);
    final bool senderless = kSenderlessGateways.contains(_kind);
    final bool custom = _kind == NotificationProviderKind.customHttp;
    final bool smspasal = _kind == NotificationProviderKind.smspasalSms;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<NotificationProviderKind>(
              key: ValueKey<String>('gateway-picker-${widget.channel.wire}'),
              initialValue: _kind,
              decoration: const InputDecoration(labelText: 'Gateway'),
              items: <DropdownMenuItem<NotificationProviderKind>>[
                for (final GatewayChoice option in _choices)
                  DropdownMenuItem<NotificationProviderKind>(
                    value: option.value,
                    child: Text(option.label),
                  ),
              ],
              onChanged: (NotificationProviderKind? value) {
                if (value == null) return;
                setState(() => _kind = value);
              },
            ),
            const SizedBox(height: Brand.spaceSm),
            Text(
              _choice.hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            if (!senderless) ...<Widget>[
              const SizedBox(height: Brand.spaceMd),
              TextField(
                controller: _senderId,
                decoration: InputDecoration(
                  labelText: widget.channel == NotificationChannel.email
                      ? 'From address'
                      : 'Sender ID',
                  hintText: widget.channel == NotificationChannel.email
                      ? 'desk@yourgym.com'
                      : 'YOURGYM',
                  errorText: _errors[GatewayField.senderId],
                ),
              ),
            ],

            if (custom) ...<Widget>[
              const SizedBox(height: Brand.spaceMd),
              TextField(
                controller: _endpointUrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'https://gateway.example.com/send',
                  errorText: _errors[GatewayField.endpointUrl],
                ),
              ),
              const SizedBox(height: Brand.spaceMd),
              TextField(
                controller: _configJson,
                minLines: 4,
                maxLines: 8,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Request',
                  hintText:
                      '{"method":"GET","params":{"token":"{{token}}","to":"{{to}}","text":"{{text}}"}}',
                  errorText: _errors[GatewayField.configJson],
                ),
              ),
              const SizedBox(height: Brand.spaceXs),
              Text(
                'Use {{token}}, {{to}}, {{text}} and {{sender}} where your gateway wants them.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            if (smspasal) ...<Widget>[
              const SizedBox(height: Brand.spaceMd),
              TextField(
                controller: _campaign,
                decoration: InputDecoration(
                  labelText: 'Campaign ID (optional)',
                  hintText: '9768',
                  errorText: _errors[GatewayField.campaign],
                ),
              ),
              const SizedBox(height: Brand.spaceMd),
              TextField(
                controller: _routeId,
                decoration: InputDecoration(
                  labelText: 'Route ID (optional)',
                  hintText: '10259',
                  errorText: _errors[GatewayField.routeid],
                ),
              ),
              const SizedBox(height: Brand.spaceXs),
              Text(
                'Both are on the Developer API page of your SMSPasal account. '
                'Leave them blank to use whatever that account already defaults to.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Brand.spaceMd),
              TextField(
                controller: _senderNtc,
                decoration: InputDecoration(
                  labelText: 'NTC sender ID (optional)',
                  hintText: 'same as above',
                  errorText: _errors[GatewayField.senderNtc],
                ),
              ),
              const SizedBox(height: Brand.spaceMd),
              TextField(
                controller: _senderNcell,
                decoration: InputDecoration(
                  labelText: 'Ncell sender ID (optional)',
                  hintText: 'same as above',
                  errorText: _errors[GatewayField.senderNcell],
                ),
              ),
              const SizedBox(height: Brand.spaceXs),
              // The split is decided per recipient, in the database:
              // `nepal_mobile_carrier()` reads the operator off the number's
              // prefix and the SMSPasal arm picks `config.sender_ntc` or
              // `config.sender_ncell`, falling back to the gateway's own
              // sender when the gym has registered only one.
              Text(
                'Operators register sender IDs separately, so a gateway can send as one '
                'word on NTC (984, 985, 986, 974, 975, 976) and another on Ncell (980, '
                '981, 982, 970). Fill these in only if your gateway gave you two; blank '
                'means every number gets the sender ID above.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: Brand.spaceMd),
            _tokenField(theme, row),

            const SizedBox(height: Brand.spaceSm),
            CheckboxListTile(
              key: const ValueKey<String>('gateway-active'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _isActive,
              title: const Text('Send on this channel'),
              onChanged: (bool? value) =>
                  setState(() => _isActive = value ?? false),
            ),

            const SizedBox(height: Brand.spaceSm),
            FilledButton(
              key: const ValueKey<String>('gateway-save'),
              onPressed: saving ? null : () => unawaited(_save()),
              child: Text(row == null ? 'Connect gateway' : 'Save gateway'),
            ),

            if (row != null) ...<Widget>[
              const SizedBox(height: Brand.spaceMd),
              const Divider(),
              _testSend(theme, saving),
              if (kBalanceCapableGateways.contains(row.provider) &&
                  widget.hasToken) ...<Widget>[
                const SizedBox(height: Brand.spaceMd),
                _BalanceStrip(gatewayId: row.id),
              ],
              const SizedBox(height: Brand.spaceSm),
              Wrap(
                spacing: Brand.spaceSm,
                children: <Widget>[
                  if (widget.hasToken)
                    TextButton(
                      key: const ValueKey<String>('gateway-forget-token'),
                      onPressed: saving
                          ? null
                          : () => unawaited(
                              _report(
                                ref
                                    .read(
                                      notificationSettingsActionsProvider
                                          .notifier,
                                    )
                                    .forgetToken(row.id),
                              ),
                            ),
                      child: const Text('Clear the token'),
                    ),
                  TextButton(
                    key: const ValueKey<String>('gateway-remove'),
                    onPressed: saving
                        ? null
                        : () => unawaited(
                            _report(
                              ref
                                  .read(
                                    notificationSettingsActionsProvider
                                        .notifier,
                                  )
                                  .removeGateway(row.id),
                            ),
                          ),
                    child: const Text('Remove this gateway'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// A saved token is never echoed back -- nothing can read it, not even this
  /// screen. What an empty box cannot say is "there is one and it is in use",
  /// so a sentence stands in for it.
  Widget _tokenField(ThemeData theme, NotificationProvider? row) {
    if (widget.hasToken && !_replacingToken) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.lock_outline,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Brand.spaceSm),
              const Expanded(child: Text('A token is stored')),
              TextButton(
                key: const ValueKey<String>('gateway-replace-token'),
                onPressed: () => setState(() => _replacingToken = true),
                child: const Text('Replace'),
              ),
            ],
          ),
          Text(
            'Stored encrypted. It cannot be read back here, only replaced or cleared.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          key: const ValueKey<String>('gateway-token'),
          controller: _apiToken,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'API token',
            hintText: widget.hasToken
                ? 'Paste the new token, then save'
                : 'Paste the token from your gateway account',
            errorText: _errors[GatewayField.apiToken],
          ),
        ),
        const SizedBox(height: Brand.spaceXs),
        Text(
          widget.hasToken
              ? 'Leave this blank to keep the token already stored.'
              : 'Stored encrypted the moment you save. It cannot be read back afterwards.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// One real message to one number the owner chooses.
  ///
  /// Every gateway accepts a plausible-looking request; only a handset lighting
  /// up says whether the token, the sender ID and the route are actually right.
  Widget _testSend(ThemeData theme, bool saving) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          key: const ValueKey<String>('gateway-test-to'),
          controller: _testTo,
          keyboardType: widget.channel == NotificationChannel.email
              ? TextInputType.emailAddress
              : TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Send a test to',
            hintText: widget.channel == NotificationChannel.email
                ? 'you@yourgym.com'
                : '98XXXXXXXX',
          ),
        ),
        const SizedBox(height: Brand.spaceSm),
        OutlinedButton(
          key: const ValueKey<String>('gateway-send-test'),
          onPressed: saving
              ? null
              : () => unawaited(
                  _report(
                    ref
                        .read(notificationSettingsActionsProvider.notifier)
                        .sendTest(channel: widget.channel, to: _testTo.text),
                  ),
                ),
          child: const Text('Send test'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final GatewayFormValidation validation = validateGatewayForm(
      provider: _kind,
      // A field the gateway does not have is not read at all, so a stale value
      // left in a controller by a picker change cannot be saved behind the
      // owner's back.
      senderId: kSenderlessGateways.contains(_kind) ? null : _senderId.text,
      endpointUrl: _kind == NotificationProviderKind.customHttp
          ? _endpointUrl.text
          : null,
      apiToken: _apiToken.text,
      configJson: _kind == NotificationProviderKind.customHttp
          ? _configJson.text
          : null,
      campaign: _kind == NotificationProviderKind.smspasalSms
          ? _campaign.text
          : null,
      routeid: _kind == NotificationProviderKind.smspasalSms
          ? _routeId.text
          : null,
      senderNtc: _kind == NotificationProviderKind.smspasalSms
          ? _senderNtc.text
          : null,
      senderNcell: _kind == NotificationProviderKind.smspasalSms
          ? _senderNcell.text
          : null,
    );

    setState(() => _errors = validation.errors);
    if (!validation.isValid) {
      // Per-field text *and* a summary. Some of these inputs are only on
      // screen for some gateways, and a complaint about a field the owner
      // cannot see reads as a button that does nothing.
      showFailureSnackBar(
        context,
        AppFailure(FailureKind.invalid, validation.summary),
      );
      return;
    }

    await _report(
      ref
          .read(notificationSettingsActionsProvider.notifier)
          .saveGateway(
            gatewayId: widget.gateway?.id,
            channel: widget.channel,
            provider: _kind,
            senderId: validation.senderId,
            endpointUrl: validation.endpointUrl,
            config: validation.config,
            isActive: _isActive,
            apiToken: validation.apiToken,
          ),
    );
  }

  /// Says what happened, whichever way it went. Never a silent catch: a gate
  /// in `staff_capabilities.dart` plus a swallowed refusal is the 2026-09-07
  /// console bug that file's header exists to prevent.
  Future<void> _report(Future<SettingsActionResult> pending) async {
    final SettingsActionResult result = await pending;
    if (!mounted) return;

    switch (result) {
      case SettingsActionSucceeded(:final String message):
        _apiToken.clear();
        setState(() => _replacingToken = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                '${notificationChannelLabel(widget.channel)}: $message',
              ),
            ),
          );
      case SettingsActionFailed(:final AppFailure failure):
        showFailureSnackBar(context, failure);
    }
  }
}

/// Remaining credits, asked for on demand rather than on every page load: it is
/// a live call to the gateway, made from inside the database, and the answer
/// arrives out of band.
class _BalanceStrip extends ConsumerWidget {
  const _BalanceStrip({required this.gatewayId});

  final String gatewayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final GatewayBalanceState state = ref.watch(
      gatewayBalanceCheckProvider(gatewayId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OutlinedButton(
          key: const ValueKey<String>('gateway-check-balance'),
          // Disabled while a request is out. The RPC throttles to one live
          // request per gateway per twenty seconds, so a second tap inside
          // that window only re-reads the first request's answer.
          onPressed: state.checking
              ? null
              : () => unawaited(
                  ref
                      .read(gatewayBalanceCheckProvider(gatewayId).notifier)
                      .check(),
                ),
          child: Text(state.checking ? 'Checking…' : 'Check balance'),
        ),
        if (state.routes != null && state.routes!.isNotEmpty) ...<Widget>[
          const SizedBox(height: Brand.spaceSm),
          Wrap(
            spacing: Brand.spaceSm,
            runSpacing: Brand.spaceXs,
            children: <Widget>[
              for (final GatewayBalanceRoute route in state.routes!)
                Chip(
                  key: ValueKey<String>('balance-route-${route.routeIdText}'),
                  label: Text('${route.route}: ${route.balanceText} SMS'),
                ),
            ],
          ),
        ],
        if (state.error != null) ...<Widget>[
          const SizedBox(height: Brand.spaceXs),
          // A refusal, including the throttle's, as a sentence. Rendering it
          // as a spinner would be a screen that never finishes.
          Text(
            state.error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (state.answeredWithNothing) ...<Widget>[
          const SizedBox(height: Brand.spaceXs),
          Text(
            'The gateway reported no routes on this account.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
