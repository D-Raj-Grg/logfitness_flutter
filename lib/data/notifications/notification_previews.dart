// What `member_notification_preview` and `visitor_notification_preview`
// answer: what this person would be told, and every reason they would not be.
//
// Plain classes rather than freezed models: these are RPC result rows, read
// once and never written back, so there is nothing for `toJson` or `copyWith`
// to do.
//
// The wording comes back from Postgres rather than being assembled here, so the
// text the desk reads before pressing Send is the text the 02:30 sweep would
// have sent.

/// One member's preview.
class MemberMessagePreview {
  const MemberMessagePreview({
    required this.toAddress,
    required this.subject,
    required this.body,
    required this.optOut,
    required this.reachable,
    required this.hasGateway,
  });

  factory MemberMessagePreview.fromJson(Map<String, dynamic> json) {
    return MemberMessagePreview(
      toAddress: json['to_address'] as String?,
      subject: json['subject'] as String?,
      body: json['body'] as String?,
      optOut: json['opt_out'] == true,
      reachable: json['reachable'] == true,
      hasGateway: json['has_gateway'] == true,
    );
  }

  final String? toAddress;
  final String? subject;
  final String? body;

  /// `members.notifications_opt_out`. Reported here and **refused** by
  /// `send_member_notification`: consent is not something a button overrides.
  final bool optOut;

  /// Whether `normalise_msisdn` could make a deliverable number of what is on
  /// file.
  final bool reachable;

  /// Whether the org has an active gateway on this channel at all.
  final bool hasGateway;

  /// Whether pressing Send could possibly do anything.
  bool get canSend => !optOut && reachable && hasGateway;
}

/// One walk-in's preview. The member preview's twin, minus `optOut`: a visitor
/// has no standing instruction to honour, because they have no history with the
/// gym yet. The desk takes them out of the follow-up sweep by marking them
/// "not joining".
class VisitorMessagePreview {
  const VisitorMessagePreview({
    required this.toAddress,
    required this.subject,
    required this.body,
    required this.reachable,
    required this.hasGateway,
  });

  factory VisitorMessagePreview.fromJson(Map<String, dynamic> json) {
    return VisitorMessagePreview(
      toAddress: json['to_address'] as String?,
      subject: json['subject'] as String?,
      body: json['body'] as String?,
      reachable: json['reachable'] == true,
      hasGateway: json['has_gateway'] == true,
    );
  }

  final String? toAddress;
  final String? subject;
  final String? body;
  final bool reachable;
  final bool hasGateway;

  bool get canSend => reachable && hasGateway;
}
