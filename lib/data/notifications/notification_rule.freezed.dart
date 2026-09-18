// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationRule {

 String get id; String get orgId; NotificationEvent get event; NotificationChannel get channel; bool get enabled;/// Renewal: days before `end_date`. Dues: how old the debt must be.
/// Birthday: 0. Visitor follow-up: days since the visit.
 int get offsetDays;/// Paisa, integer. Dues only: below this, nobody is chased.
 int get minAmountPaisa;/// Dues only: how long before the same member is chased again.
 int get repeatAfterDays;/// A Postgres `time`, carried as text end to end.
///
/// A `time` has no date and no zone. Parsing it into a `DateTime` invents
/// both, and the org's timezone is not the phone's -- the sweep runs at
/// 02:30 in Kathmandu whatever the device thinks the hour is. Same reason
/// `plain_date.dart` keeps a `date` off an instant.
 String get sendAtLocal; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of NotificationRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationRuleCopyWith<NotificationRule> get copyWith => _$NotificationRuleCopyWithImpl<NotificationRule>(this as NotificationRule, _$identity);

  /// Serializes this NotificationRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationRule&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.event, event) || other.event == event)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.offsetDays, offsetDays) || other.offsetDays == offsetDays)&&(identical(other.minAmountPaisa, minAmountPaisa) || other.minAmountPaisa == minAmountPaisa)&&(identical(other.repeatAfterDays, repeatAfterDays) || other.repeatAfterDays == repeatAfterDays)&&(identical(other.sendAtLocal, sendAtLocal) || other.sendAtLocal == sendAtLocal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,event,channel,enabled,offsetDays,minAmountPaisa,repeatAfterDays,sendAtLocal,createdAt,updatedAt);

@override
String toString() {
  return 'NotificationRule(id: $id, orgId: $orgId, event: $event, channel: $channel, enabled: $enabled, offsetDays: $offsetDays, minAmountPaisa: $minAmountPaisa, repeatAfterDays: $repeatAfterDays, sendAtLocal: $sendAtLocal, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NotificationRuleCopyWith<$Res>  {
  factory $NotificationRuleCopyWith(NotificationRule value, $Res Function(NotificationRule) _then) = _$NotificationRuleCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, NotificationEvent event, NotificationChannel channel, bool enabled, int offsetDays, int minAmountPaisa, int repeatAfterDays, String sendAtLocal, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$NotificationRuleCopyWithImpl<$Res>
    implements $NotificationRuleCopyWith<$Res> {
  _$NotificationRuleCopyWithImpl(this._self, this._then);

  final NotificationRule _self;
  final $Res Function(NotificationRule) _then;

/// Create a copy of NotificationRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? event = null,Object? channel = null,Object? enabled = null,Object? offsetDays = null,Object? minAmountPaisa = null,Object? repeatAfterDays = null,Object? sendAtLocal = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as NotificationEvent,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,offsetDays: null == offsetDays ? _self.offsetDays : offsetDays // ignore: cast_nullable_to_non_nullable
as int,minAmountPaisa: null == minAmountPaisa ? _self.minAmountPaisa : minAmountPaisa // ignore: cast_nullable_to_non_nullable
as int,repeatAfterDays: null == repeatAfterDays ? _self.repeatAfterDays : repeatAfterDays // ignore: cast_nullable_to_non_nullable
as int,sendAtLocal: null == sendAtLocal ? _self.sendAtLocal : sendAtLocal // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationRule].
extension NotificationRulePatterns on NotificationRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationRule value)  $default,){
final _that = this;
switch (_that) {
case _NotificationRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationRule value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  NotificationEvent event,  NotificationChannel channel,  bool enabled,  int offsetDays,  int minAmountPaisa,  int repeatAfterDays,  String sendAtLocal,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationRule() when $default != null:
return $default(_that.id,_that.orgId,_that.event,_that.channel,_that.enabled,_that.offsetDays,_that.minAmountPaisa,_that.repeatAfterDays,_that.sendAtLocal,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  NotificationEvent event,  NotificationChannel channel,  bool enabled,  int offsetDays,  int minAmountPaisa,  int repeatAfterDays,  String sendAtLocal,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationRule():
return $default(_that.id,_that.orgId,_that.event,_that.channel,_that.enabled,_that.offsetDays,_that.minAmountPaisa,_that.repeatAfterDays,_that.sendAtLocal,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  NotificationEvent event,  NotificationChannel channel,  bool enabled,  int offsetDays,  int minAmountPaisa,  int repeatAfterDays,  String sendAtLocal,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationRule() when $default != null:
return $default(_that.id,_that.orgId,_that.event,_that.channel,_that.enabled,_that.offsetDays,_that.minAmountPaisa,_that.repeatAfterDays,_that.sendAtLocal,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _NotificationRule extends NotificationRule {
  const _NotificationRule({required this.id, required this.orgId, required this.event, required this.channel, required this.enabled, required this.offsetDays, required this.minAmountPaisa, required this.repeatAfterDays, required this.sendAtLocal, required this.createdAt, required this.updatedAt}): super._();
  factory _NotificationRule.fromJson(Map<String, dynamic> json) => _$NotificationRuleFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  NotificationEvent event;
@override final  NotificationChannel channel;
@override final  bool enabled;
/// Renewal: days before `end_date`. Dues: how old the debt must be.
/// Birthday: 0. Visitor follow-up: days since the visit.
@override final  int offsetDays;
/// Paisa, integer. Dues only: below this, nobody is chased.
@override final  int minAmountPaisa;
/// Dues only: how long before the same member is chased again.
@override final  int repeatAfterDays;
/// A Postgres `time`, carried as text end to end.
///
/// A `time` has no date and no zone. Parsing it into a `DateTime` invents
/// both, and the org's timezone is not the phone's -- the sweep runs at
/// 02:30 in Kathmandu whatever the device thinks the hour is. Same reason
/// `plain_date.dart` keeps a `date` off an instant.
@override final  String sendAtLocal;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of NotificationRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationRuleCopyWith<_NotificationRule> get copyWith => __$NotificationRuleCopyWithImpl<_NotificationRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationRule&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.event, event) || other.event == event)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.offsetDays, offsetDays) || other.offsetDays == offsetDays)&&(identical(other.minAmountPaisa, minAmountPaisa) || other.minAmountPaisa == minAmountPaisa)&&(identical(other.repeatAfterDays, repeatAfterDays) || other.repeatAfterDays == repeatAfterDays)&&(identical(other.sendAtLocal, sendAtLocal) || other.sendAtLocal == sendAtLocal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,event,channel,enabled,offsetDays,minAmountPaisa,repeatAfterDays,sendAtLocal,createdAt,updatedAt);

@override
String toString() {
  return 'NotificationRule(id: $id, orgId: $orgId, event: $event, channel: $channel, enabled: $enabled, offsetDays: $offsetDays, minAmountPaisa: $minAmountPaisa, repeatAfterDays: $repeatAfterDays, sendAtLocal: $sendAtLocal, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationRuleCopyWith<$Res> implements $NotificationRuleCopyWith<$Res> {
  factory _$NotificationRuleCopyWith(_NotificationRule value, $Res Function(_NotificationRule) _then) = __$NotificationRuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, NotificationEvent event, NotificationChannel channel, bool enabled, int offsetDays, int minAmountPaisa, int repeatAfterDays, String sendAtLocal, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$NotificationRuleCopyWithImpl<$Res>
    implements _$NotificationRuleCopyWith<$Res> {
  __$NotificationRuleCopyWithImpl(this._self, this._then);

  final _NotificationRule _self;
  final $Res Function(_NotificationRule) _then;

/// Create a copy of NotificationRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? event = null,Object? channel = null,Object? enabled = null,Object? offsetDays = null,Object? minAmountPaisa = null,Object? repeatAfterDays = null,Object? sendAtLocal = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_NotificationRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as NotificationEvent,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,offsetDays: null == offsetDays ? _self.offsetDays : offsetDays // ignore: cast_nullable_to_non_nullable
as int,minAmountPaisa: null == minAmountPaisa ? _self.minAmountPaisa : minAmountPaisa // ignore: cast_nullable_to_non_nullable
as int,repeatAfterDays: null == repeatAfterDays ? _self.repeatAfterDays : repeatAfterDays // ignore: cast_nullable_to_non_nullable
as int,sendAtLocal: null == sendAtLocal ? _self.sendAtLocal : sendAtLocal // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
