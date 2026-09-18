// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnnouncementOverview {

 String get id; String get orgId;/// Null means every branch the sender covers, not "no branch". For an owner
/// that is the chain; for anybody else it is their own `branch_ids`,
/// resolved by `announcement_branch_scope` at send time rather than here.
 String? get branchId; String? get branchName; String get title; String get body; NotificationChannel get channel; AnnouncementAudience get audience;/// Null means the database's own default -- every status except `left`.
/// An empty list would mean nobody, which is why the repository never
/// sends one.
 List<MemberStatus>? get memberStatuses;/// Null means every open walk-in, however long ago they came in.
 int? get visitorDays; AnnouncementStatus get status; AnnouncementState get state; DateTime get scheduledFor; DateTime get createdAt; String? get createdBy; String? get createdByName; int get total; int get queued; int get sent; int get failed; int get skipped; int get cancelled; DateTime? get lastSentAt;
/// Create a copy of AnnouncementOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementOverviewCopyWith<AnnouncementOverview> get copyWith => _$AnnouncementOverviewCopyWithImpl<AnnouncementOverview>(this as AnnouncementOverview, _$identity);

  /// Serializes this AnnouncementOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnnouncementOverview&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.audience, audience) || other.audience == audience)&&const DeepCollectionEquality().equals(other.memberStatuses, memberStatuses)&&(identical(other.visitorDays, visitorDays) || other.visitorDays == visitorDays)&&(identical(other.status, status) || other.status == status)&&(identical(other.state, state) || other.state == state)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.total, total) || other.total == total)&&(identical(other.queued, queued) || other.queued == queued)&&(identical(other.sent, sent) || other.sent == sent)&&(identical(other.failed, failed) || other.failed == failed)&&(identical(other.skipped, skipped) || other.skipped == skipped)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled)&&(identical(other.lastSentAt, lastSentAt) || other.lastSentAt == lastSentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,branchId,branchName,title,body,channel,audience,const DeepCollectionEquality().hash(memberStatuses),visitorDays,status,state,scheduledFor,createdAt,createdBy,createdByName,total,queued,sent,failed,skipped,cancelled,lastSentAt]);

@override
String toString() {
  return 'AnnouncementOverview(id: $id, orgId: $orgId, branchId: $branchId, branchName: $branchName, title: $title, body: $body, channel: $channel, audience: $audience, memberStatuses: $memberStatuses, visitorDays: $visitorDays, status: $status, state: $state, scheduledFor: $scheduledFor, createdAt: $createdAt, createdBy: $createdBy, createdByName: $createdByName, total: $total, queued: $queued, sent: $sent, failed: $failed, skipped: $skipped, cancelled: $cancelled, lastSentAt: $lastSentAt)';
}


}

/// @nodoc
abstract mixin class $AnnouncementOverviewCopyWith<$Res>  {
  factory $AnnouncementOverviewCopyWith(AnnouncementOverview value, $Res Function(AnnouncementOverview) _then) = _$AnnouncementOverviewCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String? branchId, String? branchName, String title, String body, NotificationChannel channel, AnnouncementAudience audience, List<MemberStatus>? memberStatuses, int? visitorDays, AnnouncementStatus status, AnnouncementState state, DateTime scheduledFor, DateTime createdAt, String? createdBy, String? createdByName, int total, int queued, int sent, int failed, int skipped, int cancelled, DateTime? lastSentAt
});




}
/// @nodoc
class _$AnnouncementOverviewCopyWithImpl<$Res>
    implements $AnnouncementOverviewCopyWith<$Res> {
  _$AnnouncementOverviewCopyWithImpl(this._self, this._then);

  final AnnouncementOverview _self;
  final $Res Function(AnnouncementOverview) _then;

/// Create a copy of AnnouncementOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? branchId = freezed,Object? branchName = freezed,Object? title = null,Object? body = null,Object? channel = null,Object? audience = null,Object? memberStatuses = freezed,Object? visitorDays = freezed,Object? status = null,Object? state = null,Object? scheduledFor = null,Object? createdAt = null,Object? createdBy = freezed,Object? createdByName = freezed,Object? total = null,Object? queued = null,Object? sent = null,Object? failed = null,Object? skipped = null,Object? cancelled = null,Object? lastSentAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as AnnouncementAudience,memberStatuses: freezed == memberStatuses ? _self.memberStatuses : memberStatuses // ignore: cast_nullable_to_non_nullable
as List<MemberStatus>?,visitorDays: freezed == visitorDays ? _self.visitorDays : visitorDays // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnnouncementStatus,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AnnouncementState,scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,queued: null == queued ? _self.queued : queued // ignore: cast_nullable_to_non_nullable
as int,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as int,cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as int,lastSentAt: freezed == lastSentAt ? _self.lastSentAt : lastSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnnouncementOverview].
extension AnnouncementOverviewPatterns on AnnouncementOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnnouncementOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnnouncementOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnnouncementOverview value)  $default,){
final _that = this;
switch (_that) {
case _AnnouncementOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnnouncementOverview value)?  $default,){
final _that = this;
switch (_that) {
case _AnnouncementOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String? branchId,  String? branchName,  String title,  String body,  NotificationChannel channel,  AnnouncementAudience audience,  List<MemberStatus>? memberStatuses,  int? visitorDays,  AnnouncementStatus status,  AnnouncementState state,  DateTime scheduledFor,  DateTime createdAt,  String? createdBy,  String? createdByName,  int total,  int queued,  int sent,  int failed,  int skipped,  int cancelled,  DateTime? lastSentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnnouncementOverview() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.branchName,_that.title,_that.body,_that.channel,_that.audience,_that.memberStatuses,_that.visitorDays,_that.status,_that.state,_that.scheduledFor,_that.createdAt,_that.createdBy,_that.createdByName,_that.total,_that.queued,_that.sent,_that.failed,_that.skipped,_that.cancelled,_that.lastSentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String? branchId,  String? branchName,  String title,  String body,  NotificationChannel channel,  AnnouncementAudience audience,  List<MemberStatus>? memberStatuses,  int? visitorDays,  AnnouncementStatus status,  AnnouncementState state,  DateTime scheduledFor,  DateTime createdAt,  String? createdBy,  String? createdByName,  int total,  int queued,  int sent,  int failed,  int skipped,  int cancelled,  DateTime? lastSentAt)  $default,) {final _that = this;
switch (_that) {
case _AnnouncementOverview():
return $default(_that.id,_that.orgId,_that.branchId,_that.branchName,_that.title,_that.body,_that.channel,_that.audience,_that.memberStatuses,_that.visitorDays,_that.status,_that.state,_that.scheduledFor,_that.createdAt,_that.createdBy,_that.createdByName,_that.total,_that.queued,_that.sent,_that.failed,_that.skipped,_that.cancelled,_that.lastSentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String? branchId,  String? branchName,  String title,  String body,  NotificationChannel channel,  AnnouncementAudience audience,  List<MemberStatus>? memberStatuses,  int? visitorDays,  AnnouncementStatus status,  AnnouncementState state,  DateTime scheduledFor,  DateTime createdAt,  String? createdBy,  String? createdByName,  int total,  int queued,  int sent,  int failed,  int skipped,  int cancelled,  DateTime? lastSentAt)?  $default,) {final _that = this;
switch (_that) {
case _AnnouncementOverview() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.branchName,_that.title,_that.body,_that.channel,_that.audience,_that.memberStatuses,_that.visitorDays,_that.status,_that.state,_that.scheduledFor,_that.createdAt,_that.createdBy,_that.createdByName,_that.total,_that.queued,_that.sent,_that.failed,_that.skipped,_that.cancelled,_that.lastSentAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AnnouncementOverview extends AnnouncementOverview {
  const _AnnouncementOverview({required this.id, required this.orgId, this.branchId, this.branchName, required this.title, required this.body, required this.channel, required this.audience, final  List<MemberStatus>? memberStatuses, this.visitorDays, required this.status, required this.state, required this.scheduledFor, required this.createdAt, this.createdBy, this.createdByName, required this.total, required this.queued, required this.sent, required this.failed, required this.skipped, required this.cancelled, this.lastSentAt}): _memberStatuses = memberStatuses,super._();
  factory _AnnouncementOverview.fromJson(Map<String, dynamic> json) => _$AnnouncementOverviewFromJson(json);

@override final  String id;
@override final  String orgId;
/// Null means every branch the sender covers, not "no branch". For an owner
/// that is the chain; for anybody else it is their own `branch_ids`,
/// resolved by `announcement_branch_scope` at send time rather than here.
@override final  String? branchId;
@override final  String? branchName;
@override final  String title;
@override final  String body;
@override final  NotificationChannel channel;
@override final  AnnouncementAudience audience;
/// Null means the database's own default -- every status except `left`.
/// An empty list would mean nobody, which is why the repository never
/// sends one.
 final  List<MemberStatus>? _memberStatuses;
/// Null means the database's own default -- every status except `left`.
/// An empty list would mean nobody, which is why the repository never
/// sends one.
@override List<MemberStatus>? get memberStatuses {
  final value = _memberStatuses;
  if (value == null) return null;
  if (_memberStatuses is EqualUnmodifiableListView) return _memberStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Null means every open walk-in, however long ago they came in.
@override final  int? visitorDays;
@override final  AnnouncementStatus status;
@override final  AnnouncementState state;
@override final  DateTime scheduledFor;
@override final  DateTime createdAt;
@override final  String? createdBy;
@override final  String? createdByName;
@override final  int total;
@override final  int queued;
@override final  int sent;
@override final  int failed;
@override final  int skipped;
@override final  int cancelled;
@override final  DateTime? lastSentAt;

/// Create a copy of AnnouncementOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementOverviewCopyWith<_AnnouncementOverview> get copyWith => __$AnnouncementOverviewCopyWithImpl<_AnnouncementOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnnouncementOverview&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.audience, audience) || other.audience == audience)&&const DeepCollectionEquality().equals(other._memberStatuses, _memberStatuses)&&(identical(other.visitorDays, visitorDays) || other.visitorDays == visitorDays)&&(identical(other.status, status) || other.status == status)&&(identical(other.state, state) || other.state == state)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.total, total) || other.total == total)&&(identical(other.queued, queued) || other.queued == queued)&&(identical(other.sent, sent) || other.sent == sent)&&(identical(other.failed, failed) || other.failed == failed)&&(identical(other.skipped, skipped) || other.skipped == skipped)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled)&&(identical(other.lastSentAt, lastSentAt) || other.lastSentAt == lastSentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,branchId,branchName,title,body,channel,audience,const DeepCollectionEquality().hash(_memberStatuses),visitorDays,status,state,scheduledFor,createdAt,createdBy,createdByName,total,queued,sent,failed,skipped,cancelled,lastSentAt]);

@override
String toString() {
  return 'AnnouncementOverview(id: $id, orgId: $orgId, branchId: $branchId, branchName: $branchName, title: $title, body: $body, channel: $channel, audience: $audience, memberStatuses: $memberStatuses, visitorDays: $visitorDays, status: $status, state: $state, scheduledFor: $scheduledFor, createdAt: $createdAt, createdBy: $createdBy, createdByName: $createdByName, total: $total, queued: $queued, sent: $sent, failed: $failed, skipped: $skipped, cancelled: $cancelled, lastSentAt: $lastSentAt)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementOverviewCopyWith<$Res> implements $AnnouncementOverviewCopyWith<$Res> {
  factory _$AnnouncementOverviewCopyWith(_AnnouncementOverview value, $Res Function(_AnnouncementOverview) _then) = __$AnnouncementOverviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String? branchId, String? branchName, String title, String body, NotificationChannel channel, AnnouncementAudience audience, List<MemberStatus>? memberStatuses, int? visitorDays, AnnouncementStatus status, AnnouncementState state, DateTime scheduledFor, DateTime createdAt, String? createdBy, String? createdByName, int total, int queued, int sent, int failed, int skipped, int cancelled, DateTime? lastSentAt
});




}
/// @nodoc
class __$AnnouncementOverviewCopyWithImpl<$Res>
    implements _$AnnouncementOverviewCopyWith<$Res> {
  __$AnnouncementOverviewCopyWithImpl(this._self, this._then);

  final _AnnouncementOverview _self;
  final $Res Function(_AnnouncementOverview) _then;

/// Create a copy of AnnouncementOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? branchId = freezed,Object? branchName = freezed,Object? title = null,Object? body = null,Object? channel = null,Object? audience = null,Object? memberStatuses = freezed,Object? visitorDays = freezed,Object? status = null,Object? state = null,Object? scheduledFor = null,Object? createdAt = null,Object? createdBy = freezed,Object? createdByName = freezed,Object? total = null,Object? queued = null,Object? sent = null,Object? failed = null,Object? skipped = null,Object? cancelled = null,Object? lastSentAt = freezed,}) {
  return _then(_AnnouncementOverview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as AnnouncementAudience,memberStatuses: freezed == memberStatuses ? _self._memberStatuses : memberStatuses // ignore: cast_nullable_to_non_nullable
as List<MemberStatus>?,visitorDays: freezed == visitorDays ? _self.visitorDays : visitorDays // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnnouncementStatus,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AnnouncementState,scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,queued: null == queued ? _self.queued : queued // ignore: cast_nullable_to_non_nullable
as int,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as int,cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as int,lastSentAt: freezed == lastSentAt ? _self.lastSentAt : lastSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
