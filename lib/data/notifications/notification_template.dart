// Mirrors `public.notification_templates` -- the gym's own wording, per event,
// channel and locale. An absent row means the built-in is used; that fallback
// lives in Postgres (`notification_default_template`), not here, which is what
// keeps a preview honest.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'notification_template.freezed.dart';
part 'notification_template.g.dart';

@freezed
abstract class NotificationTemplate with _$NotificationTemplate {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory NotificationTemplate({
    required String id,
    required String orgId,
    required NotificationEvent event,
    required NotificationChannel channel,

    /// `en` or `ne`. A CHECK constraint upstream, not an enum, so it stays a
    /// String here too.
    required String locale,
    String? subject,
    required String body,
    required bool isActive,
    String? updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationTemplate;

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
      _$NotificationTemplateFromJson(json);
}

/// What `notification_template_preview` answers: the org's own wording when it
/// has edited one, and the built-in otherwise.
///
/// [templateId] is null exactly when the org has not edited this event, which
/// is what decides whether "reset to the built-in wording" is offered.
class NotificationTemplatePreview {
  const NotificationTemplatePreview({
    required this.templateId,
    required this.subject,
    required this.body,
  });

  factory NotificationTemplatePreview.fromJson(Map<String, dynamic> json) {
    return NotificationTemplatePreview(
      templateId: json['template_id'] as String?,
      subject: json['subject'] as String?,
      body: (json['body'] as String?) ?? '',
    );
  }

  final String? templateId;
  final String? subject;
  final String body;

  bool get isOrgOwned => templateId != null;
}
