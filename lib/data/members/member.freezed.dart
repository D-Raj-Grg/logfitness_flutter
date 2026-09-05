// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Member {

 String get id; String get orgId; String get homeBranchId; String? get authUserId; String get memberCode; String get fullName; String get phone; String? get email; DateTime? get dateOfBirth; MemberGender? get gender; String? get address; String? get photoPath; String? get emergencyContactName; String? get emergencyContactPhone; String? get notes;// Trigger-derived in Postgres (see the `members_left_on_requires_left_status`
// constraint and the status trigger upstream). The app reads this field
// and never writes it.
 MemberStatus get status; DateTime get joinedOn; DateTime? get leftOn; String? get leftReason; String? get createdBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.authUserId, authUserId) || other.authUserId == authUserId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.address, address) || other.address == address)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedOn, joinedOn) || other.joinedOn == joinedOn)&&(identical(other.leftOn, leftOn) || other.leftOn == leftOn)&&(identical(other.leftReason, leftReason) || other.leftReason == leftReason)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,homeBranchId,authUserId,memberCode,fullName,phone,email,dateOfBirth,gender,address,photoPath,emergencyContactName,emergencyContactPhone,notes,status,joinedOn,leftOn,leftReason,createdBy,createdAt,updatedAt]);

@override
String toString() {
  return 'Member(id: $id, orgId: $orgId, homeBranchId: $homeBranchId, authUserId: $authUserId, memberCode: $memberCode, fullName: $fullName, phone: $phone, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, address: $address, photoPath: $photoPath, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, notes: $notes, status: $status, joinedOn: $joinedOn, leftOn: $leftOn, leftReason: $leftReason, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String homeBranchId, String? authUserId, String memberCode, String fullName, String phone, String? email, DateTime? dateOfBirth, MemberGender? gender, String? address, String? photoPath, String? emergencyContactName, String? emergencyContactPhone, String? notes, MemberStatus status, DateTime joinedOn, DateTime? leftOn, String? leftReason, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$MemberCopyWithImpl<$Res>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? homeBranchId = null,Object? authUserId = freezed,Object? memberCode = null,Object? fullName = null,Object? phone = null,Object? email = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? address = freezed,Object? photoPath = freezed,Object? emergencyContactName = freezed,Object? emergencyContactPhone = freezed,Object? notes = freezed,Object? status = null,Object? joinedOn = null,Object? leftOn = freezed,Object? leftReason = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,authUserId: freezed == authUserId ? _self.authUserId : authUserId // ignore: cast_nullable_to_non_nullable
as String?,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as MemberGender?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactName: freezed == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactPhone: freezed == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,joinedOn: null == joinedOn ? _self.joinedOn : joinedOn // ignore: cast_nullable_to_non_nullable
as DateTime,leftOn: freezed == leftOn ? _self.leftOn : leftOn // ignore: cast_nullable_to_non_nullable
as DateTime?,leftReason: freezed == leftReason ? _self.leftReason : leftReason // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Member value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Member value)  $default,){
final _that = this;
switch (_that) {
case _Member():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Member value)?  $default,){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String homeBranchId,  String? authUserId,  String memberCode,  String fullName,  String phone,  String? email,  DateTime? dateOfBirth,  MemberGender? gender,  String? address,  String? photoPath,  String? emergencyContactName,  String? emergencyContactPhone,  String? notes,  MemberStatus status,  DateTime joinedOn,  DateTime? leftOn,  String? leftReason,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.authUserId,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.address,_that.photoPath,_that.emergencyContactName,_that.emergencyContactPhone,_that.notes,_that.status,_that.joinedOn,_that.leftOn,_that.leftReason,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String homeBranchId,  String? authUserId,  String memberCode,  String fullName,  String phone,  String? email,  DateTime? dateOfBirth,  MemberGender? gender,  String? address,  String? photoPath,  String? emergencyContactName,  String? emergencyContactPhone,  String? notes,  MemberStatus status,  DateTime joinedOn,  DateTime? leftOn,  String? leftReason,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.authUserId,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.address,_that.photoPath,_that.emergencyContactName,_that.emergencyContactPhone,_that.notes,_that.status,_that.joinedOn,_that.leftOn,_that.leftReason,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String homeBranchId,  String? authUserId,  String memberCode,  String fullName,  String phone,  String? email,  DateTime? dateOfBirth,  MemberGender? gender,  String? address,  String? photoPath,  String? emergencyContactName,  String? emergencyContactPhone,  String? notes,  MemberStatus status,  DateTime joinedOn,  DateTime? leftOn,  String? leftReason,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.authUserId,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.address,_that.photoPath,_that.emergencyContactName,_that.emergencyContactPhone,_that.notes,_that.status,_that.joinedOn,_that.leftOn,_that.leftReason,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Member implements Member {
  const _Member({required this.id, required this.orgId, required this.homeBranchId, this.authUserId, required this.memberCode, required this.fullName, required this.phone, this.email, this.dateOfBirth, this.gender, this.address, this.photoPath, this.emergencyContactName, this.emergencyContactPhone, this.notes, required this.status, required this.joinedOn, this.leftOn, this.leftReason, this.createdBy, required this.createdAt, required this.updatedAt});
  factory _Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String homeBranchId;
@override final  String? authUserId;
@override final  String memberCode;
@override final  String fullName;
@override final  String phone;
@override final  String? email;
@override final  DateTime? dateOfBirth;
@override final  MemberGender? gender;
@override final  String? address;
@override final  String? photoPath;
@override final  String? emergencyContactName;
@override final  String? emergencyContactPhone;
@override final  String? notes;
// Trigger-derived in Postgres (see the `members_left_on_requires_left_status`
// constraint and the status trigger upstream). The app reads this field
// and never writes it.
@override final  MemberStatus status;
@override final  DateTime joinedOn;
@override final  DateTime? leftOn;
@override final  String? leftReason;
@override final  String? createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCopyWith<_Member> get copyWith => __$MemberCopyWithImpl<_Member>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.authUserId, authUserId) || other.authUserId == authUserId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.address, address) || other.address == address)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedOn, joinedOn) || other.joinedOn == joinedOn)&&(identical(other.leftOn, leftOn) || other.leftOn == leftOn)&&(identical(other.leftReason, leftReason) || other.leftReason == leftReason)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,homeBranchId,authUserId,memberCode,fullName,phone,email,dateOfBirth,gender,address,photoPath,emergencyContactName,emergencyContactPhone,notes,status,joinedOn,leftOn,leftReason,createdBy,createdAt,updatedAt]);

@override
String toString() {
  return 'Member(id: $id, orgId: $orgId, homeBranchId: $homeBranchId, authUserId: $authUserId, memberCode: $memberCode, fullName: $fullName, phone: $phone, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, address: $address, photoPath: $photoPath, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, notes: $notes, status: $status, joinedOn: $joinedOn, leftOn: $leftOn, leftReason: $leftReason, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String homeBranchId, String? authUserId, String memberCode, String fullName, String phone, String? email, DateTime? dateOfBirth, MemberGender? gender, String? address, String? photoPath, String? emergencyContactName, String? emergencyContactPhone, String? notes, MemberStatus status, DateTime joinedOn, DateTime? leftOn, String? leftReason, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$MemberCopyWithImpl<$Res>
    implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? homeBranchId = null,Object? authUserId = freezed,Object? memberCode = null,Object? fullName = null,Object? phone = null,Object? email = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? address = freezed,Object? photoPath = freezed,Object? emergencyContactName = freezed,Object? emergencyContactPhone = freezed,Object? notes = freezed,Object? status = null,Object? joinedOn = null,Object? leftOn = freezed,Object? leftReason = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Member(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,authUserId: freezed == authUserId ? _self.authUserId : authUserId // ignore: cast_nullable_to_non_nullable
as String?,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as MemberGender?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactName: freezed == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactPhone: freezed == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,joinedOn: null == joinedOn ? _self.joinedOn : joinedOn // ignore: cast_nullable_to_non_nullable
as DateTime,leftOn: freezed == leftOn ? _self.leftOn : leftOn // ignore: cast_nullable_to_non_nullable
as DateTime?,leftReason: freezed == leftReason ? _self.leftReason : leftReason // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
