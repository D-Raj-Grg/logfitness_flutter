// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceDetail {

 String get id; String get memberId; String get orgId; String? get branchId; String? get branchName; String? get memberCode; String? get fullName; String? get phone; String? get photoPath;// The gym's own calendar day, not the device's.
@NullablePlainDateConverter() DateTime? get attendedOn; DateTime? get checkedInAt; DateTime? get checkedOutAt; String? get checkedInBy; String? get checkedInByName; String? get membershipId; MembershipStatus? get membershipStatusAtCheckin; int? get duePaisaAtCheckin; int? get daysToExpiryAtCheckin; AttendanceMethod? get method; bool get isOverride; String? get overrideReason; String? get notes;
/// Create a copy of AttendanceDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceDetailCopyWith<AttendanceDetail> get copyWith => _$AttendanceDetailCopyWithImpl<AttendanceDetail>(this as AttendanceDetail, _$identity);

  /// Serializes this AttendanceDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.attendedOn, attendedOn) || other.attendedOn == attendedOn)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.checkedOutAt, checkedOutAt) || other.checkedOutAt == checkedOutAt)&&(identical(other.checkedInBy, checkedInBy) || other.checkedInBy == checkedInBy)&&(identical(other.checkedInByName, checkedInByName) || other.checkedInByName == checkedInByName)&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.membershipStatusAtCheckin, membershipStatusAtCheckin) || other.membershipStatusAtCheckin == membershipStatusAtCheckin)&&(identical(other.duePaisaAtCheckin, duePaisaAtCheckin) || other.duePaisaAtCheckin == duePaisaAtCheckin)&&(identical(other.daysToExpiryAtCheckin, daysToExpiryAtCheckin) || other.daysToExpiryAtCheckin == daysToExpiryAtCheckin)&&(identical(other.method, method) || other.method == method)&&(identical(other.isOverride, isOverride) || other.isOverride == isOverride)&&(identical(other.overrideReason, overrideReason) || other.overrideReason == overrideReason)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,memberId,orgId,branchId,branchName,memberCode,fullName,phone,photoPath,attendedOn,checkedInAt,checkedOutAt,checkedInBy,checkedInByName,membershipId,membershipStatusAtCheckin,duePaisaAtCheckin,daysToExpiryAtCheckin,method,isOverride,overrideReason,notes]);

@override
String toString() {
  return 'AttendanceDetail(id: $id, memberId: $memberId, orgId: $orgId, branchId: $branchId, branchName: $branchName, memberCode: $memberCode, fullName: $fullName, phone: $phone, photoPath: $photoPath, attendedOn: $attendedOn, checkedInAt: $checkedInAt, checkedOutAt: $checkedOutAt, checkedInBy: $checkedInBy, checkedInByName: $checkedInByName, membershipId: $membershipId, membershipStatusAtCheckin: $membershipStatusAtCheckin, duePaisaAtCheckin: $duePaisaAtCheckin, daysToExpiryAtCheckin: $daysToExpiryAtCheckin, method: $method, isOverride: $isOverride, overrideReason: $overrideReason, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $AttendanceDetailCopyWith<$Res>  {
  factory $AttendanceDetailCopyWith(AttendanceDetail value, $Res Function(AttendanceDetail) _then) = _$AttendanceDetailCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String orgId, String? branchId, String? branchName, String? memberCode, String? fullName, String? phone, String? photoPath,@NullablePlainDateConverter() DateTime? attendedOn, DateTime? checkedInAt, DateTime? checkedOutAt, String? checkedInBy, String? checkedInByName, String? membershipId, MembershipStatus? membershipStatusAtCheckin, int? duePaisaAtCheckin, int? daysToExpiryAtCheckin, AttendanceMethod? method, bool isOverride, String? overrideReason, String? notes
});




}
/// @nodoc
class _$AttendanceDetailCopyWithImpl<$Res>
    implements $AttendanceDetailCopyWith<$Res> {
  _$AttendanceDetailCopyWithImpl(this._self, this._then);

  final AttendanceDetail _self;
  final $Res Function(AttendanceDetail) _then;

/// Create a copy of AttendanceDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? orgId = null,Object? branchId = freezed,Object? branchName = freezed,Object? memberCode = freezed,Object? fullName = freezed,Object? phone = freezed,Object? photoPath = freezed,Object? attendedOn = freezed,Object? checkedInAt = freezed,Object? checkedOutAt = freezed,Object? checkedInBy = freezed,Object? checkedInByName = freezed,Object? membershipId = freezed,Object? membershipStatusAtCheckin = freezed,Object? duePaisaAtCheckin = freezed,Object? daysToExpiryAtCheckin = freezed,Object? method = freezed,Object? isOverride = null,Object? overrideReason = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,attendedOn: freezed == attendedOn ? _self.attendedOn : attendedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedOutAt: freezed == checkedOutAt ? _self.checkedOutAt : checkedOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedInBy: freezed == checkedInBy ? _self.checkedInBy : checkedInBy // ignore: cast_nullable_to_non_nullable
as String?,checkedInByName: freezed == checkedInByName ? _self.checkedInByName : checkedInByName // ignore: cast_nullable_to_non_nullable
as String?,membershipId: freezed == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String?,membershipStatusAtCheckin: freezed == membershipStatusAtCheckin ? _self.membershipStatusAtCheckin : membershipStatusAtCheckin // ignore: cast_nullable_to_non_nullable
as MembershipStatus?,duePaisaAtCheckin: freezed == duePaisaAtCheckin ? _self.duePaisaAtCheckin : duePaisaAtCheckin // ignore: cast_nullable_to_non_nullable
as int?,daysToExpiryAtCheckin: freezed == daysToExpiryAtCheckin ? _self.daysToExpiryAtCheckin : daysToExpiryAtCheckin // ignore: cast_nullable_to_non_nullable
as int?,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as AttendanceMethod?,isOverride: null == isOverride ? _self.isOverride : isOverride // ignore: cast_nullable_to_non_nullable
as bool,overrideReason: freezed == overrideReason ? _self.overrideReason : overrideReason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceDetail].
extension AttendanceDetailPatterns on AttendanceDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceDetail value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String orgId,  String? branchId,  String? branchName,  String? memberCode,  String? fullName,  String? phone,  String? photoPath, @NullablePlainDateConverter()  DateTime? attendedOn,  DateTime? checkedInAt,  DateTime? checkedOutAt,  String? checkedInBy,  String? checkedInByName,  String? membershipId,  MembershipStatus? membershipStatusAtCheckin,  int? duePaisaAtCheckin,  int? daysToExpiryAtCheckin,  AttendanceMethod? method,  bool isOverride,  String? overrideReason,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceDetail() when $default != null:
return $default(_that.id,_that.memberId,_that.orgId,_that.branchId,_that.branchName,_that.memberCode,_that.fullName,_that.phone,_that.photoPath,_that.attendedOn,_that.checkedInAt,_that.checkedOutAt,_that.checkedInBy,_that.checkedInByName,_that.membershipId,_that.membershipStatusAtCheckin,_that.duePaisaAtCheckin,_that.daysToExpiryAtCheckin,_that.method,_that.isOverride,_that.overrideReason,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String orgId,  String? branchId,  String? branchName,  String? memberCode,  String? fullName,  String? phone,  String? photoPath, @NullablePlainDateConverter()  DateTime? attendedOn,  DateTime? checkedInAt,  DateTime? checkedOutAt,  String? checkedInBy,  String? checkedInByName,  String? membershipId,  MembershipStatus? membershipStatusAtCheckin,  int? duePaisaAtCheckin,  int? daysToExpiryAtCheckin,  AttendanceMethod? method,  bool isOverride,  String? overrideReason,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _AttendanceDetail():
return $default(_that.id,_that.memberId,_that.orgId,_that.branchId,_that.branchName,_that.memberCode,_that.fullName,_that.phone,_that.photoPath,_that.attendedOn,_that.checkedInAt,_that.checkedOutAt,_that.checkedInBy,_that.checkedInByName,_that.membershipId,_that.membershipStatusAtCheckin,_that.duePaisaAtCheckin,_that.daysToExpiryAtCheckin,_that.method,_that.isOverride,_that.overrideReason,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String orgId,  String? branchId,  String? branchName,  String? memberCode,  String? fullName,  String? phone,  String? photoPath, @NullablePlainDateConverter()  DateTime? attendedOn,  DateTime? checkedInAt,  DateTime? checkedOutAt,  String? checkedInBy,  String? checkedInByName,  String? membershipId,  MembershipStatus? membershipStatusAtCheckin,  int? duePaisaAtCheckin,  int? daysToExpiryAtCheckin,  AttendanceMethod? method,  bool isOverride,  String? overrideReason,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceDetail() when $default != null:
return $default(_that.id,_that.memberId,_that.orgId,_that.branchId,_that.branchName,_that.memberCode,_that.fullName,_that.phone,_that.photoPath,_that.attendedOn,_that.checkedInAt,_that.checkedOutAt,_that.checkedInBy,_that.checkedInByName,_that.membershipId,_that.membershipStatusAtCheckin,_that.duePaisaAtCheckin,_that.daysToExpiryAtCheckin,_that.method,_that.isOverride,_that.overrideReason,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AttendanceDetail extends AttendanceDetail {
  const _AttendanceDetail({required this.id, required this.memberId, required this.orgId, this.branchId, this.branchName, this.memberCode, this.fullName, this.phone, this.photoPath, @NullablePlainDateConverter() this.attendedOn, this.checkedInAt, this.checkedOutAt, this.checkedInBy, this.checkedInByName, this.membershipId, this.membershipStatusAtCheckin, this.duePaisaAtCheckin, this.daysToExpiryAtCheckin, this.method, this.isOverride = false, this.overrideReason, this.notes}): super._();
  factory _AttendanceDetail.fromJson(Map<String, dynamic> json) => _$AttendanceDetailFromJson(json);

@override final  String id;
@override final  String memberId;
@override final  String orgId;
@override final  String? branchId;
@override final  String? branchName;
@override final  String? memberCode;
@override final  String? fullName;
@override final  String? phone;
@override final  String? photoPath;
// The gym's own calendar day, not the device's.
@override@NullablePlainDateConverter() final  DateTime? attendedOn;
@override final  DateTime? checkedInAt;
@override final  DateTime? checkedOutAt;
@override final  String? checkedInBy;
@override final  String? checkedInByName;
@override final  String? membershipId;
@override final  MembershipStatus? membershipStatusAtCheckin;
@override final  int? duePaisaAtCheckin;
@override final  int? daysToExpiryAtCheckin;
@override final  AttendanceMethod? method;
@override@JsonKey() final  bool isOverride;
@override final  String? overrideReason;
@override final  String? notes;

/// Create a copy of AttendanceDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceDetailCopyWith<_AttendanceDetail> get copyWith => __$AttendanceDetailCopyWithImpl<_AttendanceDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.attendedOn, attendedOn) || other.attendedOn == attendedOn)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.checkedOutAt, checkedOutAt) || other.checkedOutAt == checkedOutAt)&&(identical(other.checkedInBy, checkedInBy) || other.checkedInBy == checkedInBy)&&(identical(other.checkedInByName, checkedInByName) || other.checkedInByName == checkedInByName)&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.membershipStatusAtCheckin, membershipStatusAtCheckin) || other.membershipStatusAtCheckin == membershipStatusAtCheckin)&&(identical(other.duePaisaAtCheckin, duePaisaAtCheckin) || other.duePaisaAtCheckin == duePaisaAtCheckin)&&(identical(other.daysToExpiryAtCheckin, daysToExpiryAtCheckin) || other.daysToExpiryAtCheckin == daysToExpiryAtCheckin)&&(identical(other.method, method) || other.method == method)&&(identical(other.isOverride, isOverride) || other.isOverride == isOverride)&&(identical(other.overrideReason, overrideReason) || other.overrideReason == overrideReason)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,memberId,orgId,branchId,branchName,memberCode,fullName,phone,photoPath,attendedOn,checkedInAt,checkedOutAt,checkedInBy,checkedInByName,membershipId,membershipStatusAtCheckin,duePaisaAtCheckin,daysToExpiryAtCheckin,method,isOverride,overrideReason,notes]);

@override
String toString() {
  return 'AttendanceDetail(id: $id, memberId: $memberId, orgId: $orgId, branchId: $branchId, branchName: $branchName, memberCode: $memberCode, fullName: $fullName, phone: $phone, photoPath: $photoPath, attendedOn: $attendedOn, checkedInAt: $checkedInAt, checkedOutAt: $checkedOutAt, checkedInBy: $checkedInBy, checkedInByName: $checkedInByName, membershipId: $membershipId, membershipStatusAtCheckin: $membershipStatusAtCheckin, duePaisaAtCheckin: $duePaisaAtCheckin, daysToExpiryAtCheckin: $daysToExpiryAtCheckin, method: $method, isOverride: $isOverride, overrideReason: $overrideReason, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$AttendanceDetailCopyWith<$Res> implements $AttendanceDetailCopyWith<$Res> {
  factory _$AttendanceDetailCopyWith(_AttendanceDetail value, $Res Function(_AttendanceDetail) _then) = __$AttendanceDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String orgId, String? branchId, String? branchName, String? memberCode, String? fullName, String? phone, String? photoPath,@NullablePlainDateConverter() DateTime? attendedOn, DateTime? checkedInAt, DateTime? checkedOutAt, String? checkedInBy, String? checkedInByName, String? membershipId, MembershipStatus? membershipStatusAtCheckin, int? duePaisaAtCheckin, int? daysToExpiryAtCheckin, AttendanceMethod? method, bool isOverride, String? overrideReason, String? notes
});




}
/// @nodoc
class __$AttendanceDetailCopyWithImpl<$Res>
    implements _$AttendanceDetailCopyWith<$Res> {
  __$AttendanceDetailCopyWithImpl(this._self, this._then);

  final _AttendanceDetail _self;
  final $Res Function(_AttendanceDetail) _then;

/// Create a copy of AttendanceDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? orgId = null,Object? branchId = freezed,Object? branchName = freezed,Object? memberCode = freezed,Object? fullName = freezed,Object? phone = freezed,Object? photoPath = freezed,Object? attendedOn = freezed,Object? checkedInAt = freezed,Object? checkedOutAt = freezed,Object? checkedInBy = freezed,Object? checkedInByName = freezed,Object? membershipId = freezed,Object? membershipStatusAtCheckin = freezed,Object? duePaisaAtCheckin = freezed,Object? daysToExpiryAtCheckin = freezed,Object? method = freezed,Object? isOverride = null,Object? overrideReason = freezed,Object? notes = freezed,}) {
  return _then(_AttendanceDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,attendedOn: freezed == attendedOn ? _self.attendedOn : attendedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedOutAt: freezed == checkedOutAt ? _self.checkedOutAt : checkedOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedInBy: freezed == checkedInBy ? _self.checkedInBy : checkedInBy // ignore: cast_nullable_to_non_nullable
as String?,checkedInByName: freezed == checkedInByName ? _self.checkedInByName : checkedInByName // ignore: cast_nullable_to_non_nullable
as String?,membershipId: freezed == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String?,membershipStatusAtCheckin: freezed == membershipStatusAtCheckin ? _self.membershipStatusAtCheckin : membershipStatusAtCheckin // ignore: cast_nullable_to_non_nullable
as MembershipStatus?,duePaisaAtCheckin: freezed == duePaisaAtCheckin ? _self.duePaisaAtCheckin : duePaisaAtCheckin // ignore: cast_nullable_to_non_nullable
as int?,daysToExpiryAtCheckin: freezed == daysToExpiryAtCheckin ? _self.daysToExpiryAtCheckin : daysToExpiryAtCheckin // ignore: cast_nullable_to_non_nullable
as int?,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as AttendanceMethod?,isOverride: null == isOverride ? _self.isOverride : isOverride // ignore: cast_nullable_to_non_nullable
as bool,overrideReason: freezed == overrideReason ? _self.overrideReason : overrideReason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
