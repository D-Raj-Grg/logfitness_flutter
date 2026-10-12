// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unassigned_card_scan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnassignedCardScan {

 String get id; String get orgId; String? get branchId; String? get deviceId; String get cardUid; DateTime? get firstSeenAt; DateTime get lastSeenAt; int get scanCount;@JsonKey(readValue: _readDeviceName) String? get deviceName;
/// Create a copy of UnassignedCardScan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnassignedCardScanCopyWith<UnassignedCardScan> get copyWith => _$UnassignedCardScanCopyWithImpl<UnassignedCardScan>(this as UnassignedCardScan, _$identity);

  /// Serializes this UnassignedCardScan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnassignedCardScan&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.cardUid, cardUid) || other.cardUid == cardUid)&&(identical(other.firstSeenAt, firstSeenAt) || other.firstSeenAt == firstSeenAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.scanCount, scanCount) || other.scanCount == scanCount)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,branchId,deviceId,cardUid,firstSeenAt,lastSeenAt,scanCount,deviceName);

@override
String toString() {
  return 'UnassignedCardScan(id: $id, orgId: $orgId, branchId: $branchId, deviceId: $deviceId, cardUid: $cardUid, firstSeenAt: $firstSeenAt, lastSeenAt: $lastSeenAt, scanCount: $scanCount, deviceName: $deviceName)';
}


}

/// @nodoc
abstract mixin class $UnassignedCardScanCopyWith<$Res>  {
  factory $UnassignedCardScanCopyWith(UnassignedCardScan value, $Res Function(UnassignedCardScan) _then) = _$UnassignedCardScanCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String? branchId, String? deviceId, String cardUid, DateTime? firstSeenAt, DateTime lastSeenAt, int scanCount,@JsonKey(readValue: _readDeviceName) String? deviceName
});




}
/// @nodoc
class _$UnassignedCardScanCopyWithImpl<$Res>
    implements $UnassignedCardScanCopyWith<$Res> {
  _$UnassignedCardScanCopyWithImpl(this._self, this._then);

  final UnassignedCardScan _self;
  final $Res Function(UnassignedCardScan) _then;

/// Create a copy of UnassignedCardScan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? branchId = freezed,Object? deviceId = freezed,Object? cardUid = null,Object? firstSeenAt = freezed,Object? lastSeenAt = null,Object? scanCount = null,Object? deviceName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,cardUid: null == cardUid ? _self.cardUid : cardUid // ignore: cast_nullable_to_non_nullable
as String,firstSeenAt: freezed == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,scanCount: null == scanCount ? _self.scanCount : scanCount // ignore: cast_nullable_to_non_nullable
as int,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UnassignedCardScan].
extension UnassignedCardScanPatterns on UnassignedCardScan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnassignedCardScan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnassignedCardScan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnassignedCardScan value)  $default,){
final _that = this;
switch (_that) {
case _UnassignedCardScan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnassignedCardScan value)?  $default,){
final _that = this;
switch (_that) {
case _UnassignedCardScan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String? branchId,  String? deviceId,  String cardUid,  DateTime? firstSeenAt,  DateTime lastSeenAt,  int scanCount, @JsonKey(readValue: _readDeviceName)  String? deviceName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnassignedCardScan() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.deviceId,_that.cardUid,_that.firstSeenAt,_that.lastSeenAt,_that.scanCount,_that.deviceName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String? branchId,  String? deviceId,  String cardUid,  DateTime? firstSeenAt,  DateTime lastSeenAt,  int scanCount, @JsonKey(readValue: _readDeviceName)  String? deviceName)  $default,) {final _that = this;
switch (_that) {
case _UnassignedCardScan():
return $default(_that.id,_that.orgId,_that.branchId,_that.deviceId,_that.cardUid,_that.firstSeenAt,_that.lastSeenAt,_that.scanCount,_that.deviceName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String? branchId,  String? deviceId,  String cardUid,  DateTime? firstSeenAt,  DateTime lastSeenAt,  int scanCount, @JsonKey(readValue: _readDeviceName)  String? deviceName)?  $default,) {final _that = this;
switch (_that) {
case _UnassignedCardScan() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.deviceId,_that.cardUid,_that.firstSeenAt,_that.lastSeenAt,_that.scanCount,_that.deviceName);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UnassignedCardScan implements UnassignedCardScan {
  const _UnassignedCardScan({required this.id, required this.orgId, this.branchId, this.deviceId, required this.cardUid, this.firstSeenAt, required this.lastSeenAt, this.scanCount = 1, @JsonKey(readValue: _readDeviceName) this.deviceName});
  factory _UnassignedCardScan.fromJson(Map<String, dynamic> json) => _$UnassignedCardScanFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String? branchId;
@override final  String? deviceId;
@override final  String cardUid;
@override final  DateTime? firstSeenAt;
@override final  DateTime lastSeenAt;
@override@JsonKey() final  int scanCount;
@override@JsonKey(readValue: _readDeviceName) final  String? deviceName;

/// Create a copy of UnassignedCardScan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnassignedCardScanCopyWith<_UnassignedCardScan> get copyWith => __$UnassignedCardScanCopyWithImpl<_UnassignedCardScan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnassignedCardScanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnassignedCardScan&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.cardUid, cardUid) || other.cardUid == cardUid)&&(identical(other.firstSeenAt, firstSeenAt) || other.firstSeenAt == firstSeenAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.scanCount, scanCount) || other.scanCount == scanCount)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,branchId,deviceId,cardUid,firstSeenAt,lastSeenAt,scanCount,deviceName);

@override
String toString() {
  return 'UnassignedCardScan(id: $id, orgId: $orgId, branchId: $branchId, deviceId: $deviceId, cardUid: $cardUid, firstSeenAt: $firstSeenAt, lastSeenAt: $lastSeenAt, scanCount: $scanCount, deviceName: $deviceName)';
}


}

/// @nodoc
abstract mixin class _$UnassignedCardScanCopyWith<$Res> implements $UnassignedCardScanCopyWith<$Res> {
  factory _$UnassignedCardScanCopyWith(_UnassignedCardScan value, $Res Function(_UnassignedCardScan) _then) = __$UnassignedCardScanCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String? branchId, String? deviceId, String cardUid, DateTime? firstSeenAt, DateTime lastSeenAt, int scanCount,@JsonKey(readValue: _readDeviceName) String? deviceName
});




}
/// @nodoc
class __$UnassignedCardScanCopyWithImpl<$Res>
    implements _$UnassignedCardScanCopyWith<$Res> {
  __$UnassignedCardScanCopyWithImpl(this._self, this._then);

  final _UnassignedCardScan _self;
  final $Res Function(_UnassignedCardScan) _then;

/// Create a copy of UnassignedCardScan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? branchId = freezed,Object? deviceId = freezed,Object? cardUid = null,Object? firstSeenAt = freezed,Object? lastSeenAt = null,Object? scanCount = null,Object? deviceName = freezed,}) {
  return _then(_UnassignedCardScan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,cardUid: null == cardUid ? _self.cardUid : cardUid // ignore: cast_nullable_to_non_nullable
as String,firstSeenAt: freezed == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,scanCount: null == scanCount ? _self.scanCount : scanCount // ignore: cast_nullable_to_non_nullable
as int,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
