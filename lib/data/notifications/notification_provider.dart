// Mirrors `public.notification_providers` -- one active gateway per channel per
// org. See `logfitness_saas/supabase/migrations/20260909140100_notification_credentials.sql`
// and `docs/notifications.md` §3.
//
// The row holds a Vault *reference*, never a token. `notification_credential`
// is revoked from every client role, so there is no path from this app to the
// secret itself: the only three operations are "is one stored"
// (`notification_has_credential`), "store this one" and "forget it".
//
// The four `balance*` columns are deliberately absent. The balance is read
// through `read_notification_gateway_balance`, which is the only thing that
// knows whether a request is still in flight; carrying a stale copy on the row
// as well would give the screen two answers and no rule for choosing.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'notification_provider.freezed.dart';
part 'notification_provider.g.dart';

@freezed
abstract class NotificationProvider with _$NotificationProvider {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory NotificationProvider({
    required String id,
    required String orgId,
    required NotificationChannel channel,
    required NotificationProviderKind provider,

    /// The sender ID as an operator registered it. Null for a gateway whose
    /// sender is fixed on the account -- Aakash is the one that is.
    String? senderId,
    String? endpointUrl,

    /// Free-form per-gateway settings: SMSPasal's `campaign`, `routeid`,
    /// `sender_ntc` and `sender_ncell`; a custom gateway's `method`,
    /// `headers`, `body` and `params`.
    @Default(<String, dynamic>{}) Map<String, dynamic> config,
    required bool isActive,

    /// The Vault key's *name* (`notif:<provider id>`), never its value.
    String? secretName,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationProvider;

  const NotificationProvider._();

  factory NotificationProvider.fromJson(Map<String, dynamic> json) =>
      _$NotificationProviderFromJson(json);

  String? configString(String key) {
    final Object? value = config[key];
    if (value == null) return null;
    final String text = '$value'.trim();
    return text.isEmpty ? null : text;
  }
}

/// One route's remaining credits, exactly as the gateway names them.
///
/// SMSPasal documents these as strings and answers with numbers, so both are
/// accepted rather than trusting either. The keys are SCREAMING, which defeats
/// `build.yaml`'s `field_rename: snake`, so this one is decoded by hand.
class GatewayBalanceRoute {
  const GatewayBalanceRoute({
    required this.routeId,
    required this.route,
    required this.balance,
  });

  factory GatewayBalanceRoute.fromJson(Map<String, dynamic> json) {
    return GatewayBalanceRoute(
      routeId: json['ROUTE_ID'] as Object?,
      route: (json['ROUTE'] as Object?)?.toString() ?? '',
      balance: json['BALANCE'] as Object?,
    );
  }

  final Object? routeId;
  final String route;
  final Object? balance;

  String get routeIdText => routeId == null ? '' : '$routeId';
  String get balanceText => balance == null ? '' : '$balance';
}

/// What `read_notification_gateway_balance` answers.
///
/// [pending] means the request is still out: the API key lives in Vault, so the
/// call is made from inside the database by pg_net and the reply is collected a
/// moment later. The screen polls this until it stops being pending.
class GatewayBalance {
  const GatewayBalance({
    required this.pending,
    this.routes,
    this.error,
    this.checkedAt,
  });

  factory GatewayBalance.fromJson(Map<String, dynamic> json) {
    final Object? rawRoutes = json['routes'];
    return GatewayBalance(
      pending: json['pending'] == true,
      routes: rawRoutes is List
          ? rawRoutes
                .whereType<Map<String, dynamic>>()
                .map(GatewayBalanceRoute.fromJson)
                .toList(growable: false)
          : null,
      error: json['error'] as String?,
      checkedAt: json['checked_at'] == null
          ? null
          : DateTime.parse(json['checked_at'] as String),
    );
  }

  final bool pending;
  final List<GatewayBalanceRoute>? routes;
  final String? error;
  final DateTime? checkedAt;

  bool get hasAnswer => !pending && (routes != null || error != null);
}
