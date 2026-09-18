// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationProvider {

 String get id; String get orgId; NotificationChannel get channel; NotificationProviderKind get provider;/// The sender ID as an operator registered it. Null for a gateway whose
/// sender is fixed on the account -- Aakash is the one that is.
 String? get senderId; String? get endpointUrl;/// Free-form per-gateway settings: SMSPasal's `campaign`, `routeid`,
/// `sender_ntc` and `sender_ncell`; a custom gateway's `method`,
/// `headers`, `body` and `params`.
 Map<String, dynamic> get config; bool get isActive;/// The Vault key's *name* (`notif:<provider id>`), never its value.
 String? get secretName; String? get createdBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of NotificationProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationProviderCopyWith<NotificationProvider> get copyWith => _$NotificationProviderCopyWithImpl<NotificationProvider>(this as NotificationProvider, _$identity);

  /// Serializes this NotificationProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationProvider&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.endpointUrl, endpointUrl) || other.endpointUrl == endpointUrl)&&const DeepCollectionEquality().equals(other.config, config)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.secretName, secretName) || other.secretName == secretName)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,channel,provider,senderId,endpointUrl,const DeepCollectionEquality().hash(config),isActive,secretName,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'NotificationProvider(id: $id, orgId: $orgId, channel: $channel, provider: $provider, senderId: $senderId, endpointUrl: $endpointUrl, config: $config, isActive: $isActive, secretName: $secretName, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NotificationProviderCopyWith<$Res>  {
  factory $NotificationProviderCopyWith(NotificationProvider value, $Res Function(NotificationProvider) _then) = _$NotificationProviderCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, NotificationChannel channel, NotificationProviderKind provider, String? senderId, String? endpointUrl, Map<String, dynamic> config, bool isActive, String? secretName, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$NotificationProviderCopyWithImpl<$Res>
    implements $NotificationProviderCopyWith<$Res> {
  _$NotificationProviderCopyWithImpl(this._self, this._then);

  final NotificationProvider _self;
  final $Res Function(NotificationProvider) _then;

/// Create a copy of NotificationProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? channel = null,Object? provider = null,Object? senderId = freezed,Object? endpointUrl = freezed,Object? config = null,Object? isActive = null,Object? secretName = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as NotificationProviderKind,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,endpointUrl: freezed == endpointUrl ? _self.endpointUrl : endpointUrl // ignore: cast_nullable_to_non_nullable
as String?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,secretName: freezed == secretName ? _self.secretName : secretName // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationProvider].
extension NotificationProviderPatterns on NotificationProvider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationProvider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationProvider value)  $default,){
final _that = this;
switch (_that) {
case _NotificationProvider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationProvider value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationProvider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  NotificationChannel channel,  NotificationProviderKind provider,  String? senderId,  String? endpointUrl,  Map<String, dynamic> config,  bool isActive,  String? secretName,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationProvider() when $default != null:
return $default(_that.id,_that.orgId,_that.channel,_that.provider,_that.senderId,_that.endpointUrl,_that.config,_that.isActive,_that.secretName,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  NotificationChannel channel,  NotificationProviderKind provider,  String? senderId,  String? endpointUrl,  Map<String, dynamic> config,  bool isActive,  String? secretName,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationProvider():
return $default(_that.id,_that.orgId,_that.channel,_that.provider,_that.senderId,_that.endpointUrl,_that.config,_that.isActive,_that.secretName,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  NotificationChannel channel,  NotificationProviderKind provider,  String? senderId,  String? endpointUrl,  Map<String, dynamic> config,  bool isActive,  String? secretName,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationProvider() when $default != null:
return $default(_that.id,_that.orgId,_that.channel,_that.provider,_that.senderId,_that.endpointUrl,_that.config,_that.isActive,_that.secretName,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _NotificationProvider extends NotificationProvider {
  const _NotificationProvider({required this.id, required this.orgId, required this.channel, required this.provider, this.senderId, this.endpointUrl, final  Map<String, dynamic> config = const <String, dynamic>{}, required this.isActive, this.secretName, this.createdBy, required this.createdAt, required this.updatedAt}): _config = config,super._();
  factory _NotificationProvider.fromJson(Map<String, dynamic> json) => _$NotificationProviderFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  NotificationChannel channel;
@override final  NotificationProviderKind provider;
/// The sender ID as an operator registered it. Null for a gateway whose
/// sender is fixed on the account -- Aakash is the one that is.
@override final  String? senderId;
@override final  String? endpointUrl;
/// Free-form per-gateway settings: SMSPasal's `campaign`, `routeid`,
/// `sender_ntc` and `sender_ncell`; a custom gateway's `method`,
/// `headers`, `body` and `params`.
 final  Map<String, dynamic> _config;
/// Free-form per-gateway settings: SMSPasal's `campaign`, `routeid`,
/// `sender_ntc` and `sender_ncell`; a custom gateway's `method`,
/// `headers`, `body` and `params`.
@override@JsonKey() Map<String, dynamic> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}

@override final  bool isActive;
/// The Vault key's *name* (`notif:<provider id>`), never its value.
@override final  String? secretName;
@override final  String? createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of NotificationProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationProviderCopyWith<_NotificationProvider> get copyWith => __$NotificationProviderCopyWithImpl<_NotificationProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationProviderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationProvider&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.endpointUrl, endpointUrl) || other.endpointUrl == endpointUrl)&&const DeepCollectionEquality().equals(other._config, _config)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.secretName, secretName) || other.secretName == secretName)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,channel,provider,senderId,endpointUrl,const DeepCollectionEquality().hash(_config),isActive,secretName,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'NotificationProvider(id: $id, orgId: $orgId, channel: $channel, provider: $provider, senderId: $senderId, endpointUrl: $endpointUrl, config: $config, isActive: $isActive, secretName: $secretName, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationProviderCopyWith<$Res> implements $NotificationProviderCopyWith<$Res> {
  factory _$NotificationProviderCopyWith(_NotificationProvider value, $Res Function(_NotificationProvider) _then) = __$NotificationProviderCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, NotificationChannel channel, NotificationProviderKind provider, String? senderId, String? endpointUrl, Map<String, dynamic> config, bool isActive, String? secretName, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$NotificationProviderCopyWithImpl<$Res>
    implements _$NotificationProviderCopyWith<$Res> {
  __$NotificationProviderCopyWithImpl(this._self, this._then);

  final _NotificationProvider _self;
  final $Res Function(_NotificationProvider) _then;

/// Create a copy of NotificationProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? channel = null,Object? provider = null,Object? senderId = freezed,Object? endpointUrl = freezed,Object? config = null,Object? isActive = null,Object? secretName = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_NotificationProvider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as NotificationProviderKind,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,endpointUrl: freezed == endpointUrl ? _self.endpointUrl : endpointUrl // ignore: cast_nullable_to_non_nullable
as String?,config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,secretName: freezed == secretName ? _self.secretName : secretName // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
