// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationTemplate {

 String get id; String get orgId; NotificationEvent get event; NotificationChannel get channel;/// `en` or `ne`. A CHECK constraint upstream, not an enum, so it stays a
/// String here too.
 String get locale; String? get subject; String get body; bool get isActive; String? get updatedBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of NotificationTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationTemplateCopyWith<NotificationTemplate> get copyWith => _$NotificationTemplateCopyWithImpl<NotificationTemplate>(this as NotificationTemplate, _$identity);

  /// Serializes this NotificationTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.event, event) || other.event == event)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,event,channel,locale,subject,body,isActive,updatedBy,createdAt,updatedAt);

@override
String toString() {
  return 'NotificationTemplate(id: $id, orgId: $orgId, event: $event, channel: $channel, locale: $locale, subject: $subject, body: $body, isActive: $isActive, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NotificationTemplateCopyWith<$Res>  {
  factory $NotificationTemplateCopyWith(NotificationTemplate value, $Res Function(NotificationTemplate) _then) = _$NotificationTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, NotificationEvent event, NotificationChannel channel, String locale, String? subject, String body, bool isActive, String? updatedBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$NotificationTemplateCopyWithImpl<$Res>
    implements $NotificationTemplateCopyWith<$Res> {
  _$NotificationTemplateCopyWithImpl(this._self, this._then);

  final NotificationTemplate _self;
  final $Res Function(NotificationTemplate) _then;

/// Create a copy of NotificationTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? event = null,Object? channel = null,Object? locale = null,Object? subject = freezed,Object? body = null,Object? isActive = null,Object? updatedBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as NotificationEvent,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationTemplate].
extension NotificationTemplatePatterns on NotificationTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationTemplate value)  $default,){
final _that = this;
switch (_that) {
case _NotificationTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  NotificationEvent event,  NotificationChannel channel,  String locale,  String? subject,  String body,  bool isActive,  String? updatedBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationTemplate() when $default != null:
return $default(_that.id,_that.orgId,_that.event,_that.channel,_that.locale,_that.subject,_that.body,_that.isActive,_that.updatedBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  NotificationEvent event,  NotificationChannel channel,  String locale,  String? subject,  String body,  bool isActive,  String? updatedBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationTemplate():
return $default(_that.id,_that.orgId,_that.event,_that.channel,_that.locale,_that.subject,_that.body,_that.isActive,_that.updatedBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  NotificationEvent event,  NotificationChannel channel,  String locale,  String? subject,  String body,  bool isActive,  String? updatedBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationTemplate() when $default != null:
return $default(_that.id,_that.orgId,_that.event,_that.channel,_that.locale,_that.subject,_that.body,_that.isActive,_that.updatedBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _NotificationTemplate implements NotificationTemplate {
  const _NotificationTemplate({required this.id, required this.orgId, required this.event, required this.channel, required this.locale, this.subject, required this.body, required this.isActive, this.updatedBy, required this.createdAt, required this.updatedAt});
  factory _NotificationTemplate.fromJson(Map<String, dynamic> json) => _$NotificationTemplateFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  NotificationEvent event;
@override final  NotificationChannel channel;
/// `en` or `ne`. A CHECK constraint upstream, not an enum, so it stays a
/// String here too.
@override final  String locale;
@override final  String? subject;
@override final  String body;
@override final  bool isActive;
@override final  String? updatedBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of NotificationTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationTemplateCopyWith<_NotificationTemplate> get copyWith => __$NotificationTemplateCopyWithImpl<_NotificationTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.event, event) || other.event == event)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,event,channel,locale,subject,body,isActive,updatedBy,createdAt,updatedAt);

@override
String toString() {
  return 'NotificationTemplate(id: $id, orgId: $orgId, event: $event, channel: $channel, locale: $locale, subject: $subject, body: $body, isActive: $isActive, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationTemplateCopyWith<$Res> implements $NotificationTemplateCopyWith<$Res> {
  factory _$NotificationTemplateCopyWith(_NotificationTemplate value, $Res Function(_NotificationTemplate) _then) = __$NotificationTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, NotificationEvent event, NotificationChannel channel, String locale, String? subject, String body, bool isActive, String? updatedBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$NotificationTemplateCopyWithImpl<$Res>
    implements _$NotificationTemplateCopyWith<$Res> {
  __$NotificationTemplateCopyWithImpl(this._self, this._then);

  final _NotificationTemplate _self;
  final $Res Function(_NotificationTemplate) _then;

/// Create a copy of NotificationTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? event = null,Object? channel = null,Object? locale = null,Object? subject = freezed,Object? body = null,Object? isActive = null,Object? updatedBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_NotificationTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as NotificationEvent,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
