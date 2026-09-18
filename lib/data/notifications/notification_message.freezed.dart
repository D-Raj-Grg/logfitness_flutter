// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationMessage {

 String get id; String get orgId;/// Null means the message was raised for the whole org rather than for a
/// branch -- and an org-wide message belongs to everyone who can see the
/// org, not to nobody. Every branch filter has to say so explicitly.
 String? get branchId; String? get memberId; String? get staffId; String? get visitorId;/// The broadcast this row belongs to, or null for everything else --
/// including an announcement *test*, which is a real outbox row that
/// belongs to no announcement because nothing has been announced yet.
 String? get announcementId; NotificationChannel get channel; NotificationEvent get event;/// Resolved at send time from the org's active gateway, so a row that has
/// not gone out yet carries none.
 NotificationProviderKind? get provider; String get toAddress; String? get subject; String get body; NotificationStatus get status; int get attempts; DateTime get scheduledFor; DateTime get nextAttemptAt; int? get providerStatus; String? get providerMessageId; String? get lastError; DateTime? get sentAt; String get dedupeKey;/// The staff member who pressed Send. Null for anything a nightly sweep
/// raised, which is how the log tells the two apart.
 String? get createdBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of NotificationMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationMessageCopyWith<NotificationMessage> get copyWith => _$NotificationMessageCopyWithImpl<NotificationMessage>(this as NotificationMessage, _$identity);

  /// Serializes this NotificationMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.visitorId, visitorId) || other.visitorId == visitorId)&&(identical(other.announcementId, announcementId) || other.announcementId == announcementId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.event, event) || other.event == event)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.toAddress, toAddress) || other.toAddress == toAddress)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.nextAttemptAt, nextAttemptAt) || other.nextAttemptAt == nextAttemptAt)&&(identical(other.providerStatus, providerStatus) || other.providerStatus == providerStatus)&&(identical(other.providerMessageId, providerMessageId) || other.providerMessageId == providerMessageId)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.dedupeKey, dedupeKey) || other.dedupeKey == dedupeKey)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,branchId,memberId,staffId,visitorId,announcementId,channel,event,provider,toAddress,subject,body,status,attempts,scheduledFor,nextAttemptAt,providerStatus,providerMessageId,lastError,sentAt,dedupeKey,createdBy,createdAt,updatedAt]);

@override
String toString() {
  return 'NotificationMessage(id: $id, orgId: $orgId, branchId: $branchId, memberId: $memberId, staffId: $staffId, visitorId: $visitorId, announcementId: $announcementId, channel: $channel, event: $event, provider: $provider, toAddress: $toAddress, subject: $subject, body: $body, status: $status, attempts: $attempts, scheduledFor: $scheduledFor, nextAttemptAt: $nextAttemptAt, providerStatus: $providerStatus, providerMessageId: $providerMessageId, lastError: $lastError, sentAt: $sentAt, dedupeKey: $dedupeKey, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NotificationMessageCopyWith<$Res>  {
  factory $NotificationMessageCopyWith(NotificationMessage value, $Res Function(NotificationMessage) _then) = _$NotificationMessageCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String? branchId, String? memberId, String? staffId, String? visitorId, String? announcementId, NotificationChannel channel, NotificationEvent event, NotificationProviderKind? provider, String toAddress, String? subject, String body, NotificationStatus status, int attempts, DateTime scheduledFor, DateTime nextAttemptAt, int? providerStatus, String? providerMessageId, String? lastError, DateTime? sentAt, String dedupeKey, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$NotificationMessageCopyWithImpl<$Res>
    implements $NotificationMessageCopyWith<$Res> {
  _$NotificationMessageCopyWithImpl(this._self, this._then);

  final NotificationMessage _self;
  final $Res Function(NotificationMessage) _then;

/// Create a copy of NotificationMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? branchId = freezed,Object? memberId = freezed,Object? staffId = freezed,Object? visitorId = freezed,Object? announcementId = freezed,Object? channel = null,Object? event = null,Object? provider = freezed,Object? toAddress = null,Object? subject = freezed,Object? body = null,Object? status = null,Object? attempts = null,Object? scheduledFor = null,Object? nextAttemptAt = null,Object? providerStatus = freezed,Object? providerMessageId = freezed,Object? lastError = freezed,Object? sentAt = freezed,Object? dedupeKey = null,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,staffId: freezed == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String?,visitorId: freezed == visitorId ? _self.visitorId : visitorId // ignore: cast_nullable_to_non_nullable
as String?,announcementId: freezed == announcementId ? _self.announcementId : announcementId // ignore: cast_nullable_to_non_nullable
as String?,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as NotificationEvent,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as NotificationProviderKind?,toAddress: null == toAddress ? _self.toAddress : toAddress // ignore: cast_nullable_to_non_nullable
as String,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationStatus,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime,nextAttemptAt: null == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime,providerStatus: freezed == providerStatus ? _self.providerStatus : providerStatus // ignore: cast_nullable_to_non_nullable
as int?,providerMessageId: freezed == providerMessageId ? _self.providerMessageId : providerMessageId // ignore: cast_nullable_to_non_nullable
as String?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dedupeKey: null == dedupeKey ? _self.dedupeKey : dedupeKey // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationMessage].
extension NotificationMessagePatterns on NotificationMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationMessage value)  $default,){
final _that = this;
switch (_that) {
case _NotificationMessage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationMessage value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String? branchId,  String? memberId,  String? staffId,  String? visitorId,  String? announcementId,  NotificationChannel channel,  NotificationEvent event,  NotificationProviderKind? provider,  String toAddress,  String? subject,  String body,  NotificationStatus status,  int attempts,  DateTime scheduledFor,  DateTime nextAttemptAt,  int? providerStatus,  String? providerMessageId,  String? lastError,  DateTime? sentAt,  String dedupeKey,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationMessage() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.staffId,_that.visitorId,_that.announcementId,_that.channel,_that.event,_that.provider,_that.toAddress,_that.subject,_that.body,_that.status,_that.attempts,_that.scheduledFor,_that.nextAttemptAt,_that.providerStatus,_that.providerMessageId,_that.lastError,_that.sentAt,_that.dedupeKey,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String? branchId,  String? memberId,  String? staffId,  String? visitorId,  String? announcementId,  NotificationChannel channel,  NotificationEvent event,  NotificationProviderKind? provider,  String toAddress,  String? subject,  String body,  NotificationStatus status,  int attempts,  DateTime scheduledFor,  DateTime nextAttemptAt,  int? providerStatus,  String? providerMessageId,  String? lastError,  DateTime? sentAt,  String dedupeKey,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationMessage():
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.staffId,_that.visitorId,_that.announcementId,_that.channel,_that.event,_that.provider,_that.toAddress,_that.subject,_that.body,_that.status,_that.attempts,_that.scheduledFor,_that.nextAttemptAt,_that.providerStatus,_that.providerMessageId,_that.lastError,_that.sentAt,_that.dedupeKey,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String? branchId,  String? memberId,  String? staffId,  String? visitorId,  String? announcementId,  NotificationChannel channel,  NotificationEvent event,  NotificationProviderKind? provider,  String toAddress,  String? subject,  String body,  NotificationStatus status,  int attempts,  DateTime scheduledFor,  DateTime nextAttemptAt,  int? providerStatus,  String? providerMessageId,  String? lastError,  DateTime? sentAt,  String dedupeKey,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationMessage() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.staffId,_that.visitorId,_that.announcementId,_that.channel,_that.event,_that.provider,_that.toAddress,_that.subject,_that.body,_that.status,_that.attempts,_that.scheduledFor,_that.nextAttemptAt,_that.providerStatus,_that.providerMessageId,_that.lastError,_that.sentAt,_that.dedupeKey,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _NotificationMessage extends NotificationMessage {
  const _NotificationMessage({required this.id, required this.orgId, this.branchId, this.memberId, this.staffId, this.visitorId, this.announcementId, required this.channel, required this.event, this.provider, required this.toAddress, this.subject, required this.body, required this.status, required this.attempts, required this.scheduledFor, required this.nextAttemptAt, this.providerStatus, this.providerMessageId, this.lastError, this.sentAt, required this.dedupeKey, this.createdBy, required this.createdAt, required this.updatedAt}): super._();
  factory _NotificationMessage.fromJson(Map<String, dynamic> json) => _$NotificationMessageFromJson(json);

@override final  String id;
@override final  String orgId;
/// Null means the message was raised for the whole org rather than for a
/// branch -- and an org-wide message belongs to everyone who can see the
/// org, not to nobody. Every branch filter has to say so explicitly.
@override final  String? branchId;
@override final  String? memberId;
@override final  String? staffId;
@override final  String? visitorId;
/// The broadcast this row belongs to, or null for everything else --
/// including an announcement *test*, which is a real outbox row that
/// belongs to no announcement because nothing has been announced yet.
@override final  String? announcementId;
@override final  NotificationChannel channel;
@override final  NotificationEvent event;
/// Resolved at send time from the org's active gateway, so a row that has
/// not gone out yet carries none.
@override final  NotificationProviderKind? provider;
@override final  String toAddress;
@override final  String? subject;
@override final  String body;
@override final  NotificationStatus status;
@override final  int attempts;
@override final  DateTime scheduledFor;
@override final  DateTime nextAttemptAt;
@override final  int? providerStatus;
@override final  String? providerMessageId;
@override final  String? lastError;
@override final  DateTime? sentAt;
@override final  String dedupeKey;
/// The staff member who pressed Send. Null for anything a nightly sweep
/// raised, which is how the log tells the two apart.
@override final  String? createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of NotificationMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationMessageCopyWith<_NotificationMessage> get copyWith => __$NotificationMessageCopyWithImpl<_NotificationMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.visitorId, visitorId) || other.visitorId == visitorId)&&(identical(other.announcementId, announcementId) || other.announcementId == announcementId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.event, event) || other.event == event)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.toAddress, toAddress) || other.toAddress == toAddress)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.nextAttemptAt, nextAttemptAt) || other.nextAttemptAt == nextAttemptAt)&&(identical(other.providerStatus, providerStatus) || other.providerStatus == providerStatus)&&(identical(other.providerMessageId, providerMessageId) || other.providerMessageId == providerMessageId)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.dedupeKey, dedupeKey) || other.dedupeKey == dedupeKey)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,branchId,memberId,staffId,visitorId,announcementId,channel,event,provider,toAddress,subject,body,status,attempts,scheduledFor,nextAttemptAt,providerStatus,providerMessageId,lastError,sentAt,dedupeKey,createdBy,createdAt,updatedAt]);

@override
String toString() {
  return 'NotificationMessage(id: $id, orgId: $orgId, branchId: $branchId, memberId: $memberId, staffId: $staffId, visitorId: $visitorId, announcementId: $announcementId, channel: $channel, event: $event, provider: $provider, toAddress: $toAddress, subject: $subject, body: $body, status: $status, attempts: $attempts, scheduledFor: $scheduledFor, nextAttemptAt: $nextAttemptAt, providerStatus: $providerStatus, providerMessageId: $providerMessageId, lastError: $lastError, sentAt: $sentAt, dedupeKey: $dedupeKey, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationMessageCopyWith<$Res> implements $NotificationMessageCopyWith<$Res> {
  factory _$NotificationMessageCopyWith(_NotificationMessage value, $Res Function(_NotificationMessage) _then) = __$NotificationMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String? branchId, String? memberId, String? staffId, String? visitorId, String? announcementId, NotificationChannel channel, NotificationEvent event, NotificationProviderKind? provider, String toAddress, String? subject, String body, NotificationStatus status, int attempts, DateTime scheduledFor, DateTime nextAttemptAt, int? providerStatus, String? providerMessageId, String? lastError, DateTime? sentAt, String dedupeKey, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$NotificationMessageCopyWithImpl<$Res>
    implements _$NotificationMessageCopyWith<$Res> {
  __$NotificationMessageCopyWithImpl(this._self, this._then);

  final _NotificationMessage _self;
  final $Res Function(_NotificationMessage) _then;

/// Create a copy of NotificationMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? branchId = freezed,Object? memberId = freezed,Object? staffId = freezed,Object? visitorId = freezed,Object? announcementId = freezed,Object? channel = null,Object? event = null,Object? provider = freezed,Object? toAddress = null,Object? subject = freezed,Object? body = null,Object? status = null,Object? attempts = null,Object? scheduledFor = null,Object? nextAttemptAt = null,Object? providerStatus = freezed,Object? providerMessageId = freezed,Object? lastError = freezed,Object? sentAt = freezed,Object? dedupeKey = null,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_NotificationMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,staffId: freezed == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String?,visitorId: freezed == visitorId ? _self.visitorId : visitorId // ignore: cast_nullable_to_non_nullable
as String?,announcementId: freezed == announcementId ? _self.announcementId : announcementId // ignore: cast_nullable_to_non_nullable
as String?,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as NotificationEvent,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as NotificationProviderKind?,toAddress: null == toAddress ? _self.toAddress : toAddress // ignore: cast_nullable_to_non_nullable
as String,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationStatus,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime,nextAttemptAt: null == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime,providerStatus: freezed == providerStatus ? _self.providerStatus : providerStatus // ignore: cast_nullable_to_non_nullable
as int?,providerMessageId: freezed == providerMessageId ? _self.providerMessageId : providerMessageId // ignore: cast_nullable_to_non_nullable
as String?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dedupeKey: null == dedupeKey ? _self.dedupeKey : dedupeKey // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
