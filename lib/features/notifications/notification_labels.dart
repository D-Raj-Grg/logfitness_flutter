// The words the app uses for a notification's status, reason and channel.
//
// Dart twin of `logfitness_saas/lib/notifications/labels.ts` and of the short
// forms in `components/notifications/notifications-table.tsx`. The wording is
// copied, not paraphrased: a manager reading the console and a desk reading the
// phone are discussing the same row, and "Not sent" and "Skipped" are not the
// same sentence to the person being asked whether a member was told.
//
// Kept out of the widgets that use them for the same reason the console kept
// them out of `notification-filters.tsx` -- three screens read them.
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

/// The long form, for a filter sheet.
String notificationStatusLabel(NotificationStatus status) => switch (status) {
  NotificationStatus.queued => 'Waiting to go',
  NotificationStatus.sending => 'Going out now',
  NotificationStatus.sent => 'Delivered to the gateway',
  NotificationStatus.failed => 'Failed',
  NotificationStatus.skipped => 'Not sent',
  NotificationStatus.cancelled => 'Cancelled',
};

/// The short form, for a badge or a summary chip.
String notificationStatusShort(NotificationStatus status) => switch (status) {
  NotificationStatus.queued => 'Waiting',
  NotificationStatus.sending => 'Going out',
  NotificationStatus.sent => 'Delivered',
  NotificationStatus.failed => 'Failed',
  NotificationStatus.skipped => 'Not sent',
  NotificationStatus.cancelled => 'Cancelled',
};

/// The long form of a reason.
String notificationEventLabel(NotificationEvent event) => switch (event) {
  NotificationEvent.renewalReminder => 'Renewal reminder',
  NotificationEvent.duesReminder => 'Dues reminder',
  NotificationEvent.birthdayGreeting => 'Birthday greeting',
  NotificationEvent.staffInvite => 'Staff invitation',
  NotificationEvent.testMessage => 'Test message',
  NotificationEvent.customMessage => 'Sent by hand',
  NotificationEvent.visitorWelcome => 'Visitor welcome',
  NotificationEvent.visitorFollowUp => 'Visitor follow-up',
};

/// The short form, for a row where the recipient and the time follow it.
String notificationEventShort(NotificationEvent event) => switch (event) {
  NotificationEvent.renewalReminder => 'Renewal',
  NotificationEvent.duesReminder => 'Dues',
  NotificationEvent.birthdayGreeting => 'Birthday',
  NotificationEvent.staffInvite => 'Staff invite',
  NotificationEvent.testMessage => 'Test',
  NotificationEvent.customMessage => 'By hand',
  NotificationEvent.visitorWelcome => 'Visitor welcome',
  NotificationEvent.visitorFollowUp => 'Visitor follow-up',
};

String notificationChannelLabel(NotificationChannel channel) =>
    switch (channel) {
      NotificationChannel.sms => 'SMS',
      NotificationChannel.viber => 'Viber',
      NotificationChannel.email => 'Email',
    };

/// What each gateway is called on a settings screen.
String notificationGatewayLabel(NotificationProviderKind provider) =>
    switch (provider) {
      NotificationProviderKind.sparrowSms => 'Sparrow SMS',
      NotificationProviderKind.aakashSms => 'Aakash SMS',
      NotificationProviderKind.smspasalSms => 'SMSPasal',
      NotificationProviderKind.viberBusiness => 'Viber Business',
      NotificationProviderKind.resendEmail => 'Resend',
      NotificationProviderKind.customHttp => 'Another gateway',
      NotificationProviderKind.logOnly => 'Log only',
    };

/// What the desk may send to a member by hand.
///
/// `staff_invite` and `test_message` are absent and the database refuses them
/// too: one is not addressed to a member and the other is an owner's gateway
/// check.
const List<NotificationEvent> kManualMemberEvents = <NotificationEvent>[
  NotificationEvent.duesReminder,
  NotificationEvent.renewalReminder,
  NotificationEvent.birthdayGreeting,
  NotificationEvent.customMessage,
];

/// What the desk may send to a walk-in.
///
/// Narrower on purpose: the product holds no membership and no balance for a
/// visitor, so a renewal or a dues reminder has nothing to put in the sentence,
/// and `send_visitor_notification` refuses both.
const List<NotificationEvent> kManualVisitorEvents = <NotificationEvent>[
  NotificationEvent.visitorWelcome,
  NotificationEvent.visitorFollowUp,
  NotificationEvent.customMessage,
];

/// The reasons an owner may reword.
const List<NotificationEvent> kEditableTemplateEvents = <NotificationEvent>[
  NotificationEvent.renewalReminder,
  NotificationEvent.duesReminder,
  NotificationEvent.birthdayGreeting,
  NotificationEvent.visitorWelcome,
  NotificationEvent.visitorFollowUp,
];

/// The picker's wording for a manual send to a member. `custom_message` reads
/// as "Something else" here rather than "Sent by hand": in the log it describes
/// what happened, on the form it is a choice being offered.
String manualMemberEventLabel(NotificationEvent event) => switch (event) {
  NotificationEvent.customMessage => 'Something else',
  _ => notificationEventLabel(event),
};

/// The picker's wording for a manual send to a walk-in.
String manualVisitorEventLabel(NotificationEvent event) => switch (event) {
  NotificationEvent.visitorWelcome => 'Welcome / thanks for visiting',
  NotificationEvent.visitorFollowUp => 'Follow-up',
  NotificationEvent.customMessage => 'Something else',
  _ => notificationEventLabel(event),
};

/// The "no filter" row of each of the console's label maps
/// (`lib/notifications/labels.ts`, the `all:` entries). They are words, not
/// "Any" or "All": "Every message" says what the unfiltered list *is*, where
/// "All" reads as a button.
const String kEveryMessageLabel = 'Every message';
const String kEveryReasonLabel = 'Every reason';
const String kEveryChannelLabel = 'Every channel';
