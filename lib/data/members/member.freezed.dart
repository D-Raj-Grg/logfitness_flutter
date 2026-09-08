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

 String get id; String get orgId; String get homeBranchId; String? get authUserId; String get memberCode; String get fullName; String get phone; String? get email;// `date`, not `timestamptz` -- see plain_date.dart.
@NullablePlainDateConverter() DateTime? get dateOfBirth; MemberGender? get gender; String? get address; String? get photoPath; String? get emergencyContactName; String? get emergencyContactPhone; String? get notes;// Trigger-derived in Postgres (see the `members_left_on_requires_left_status`
// constraint and the status trigger upstream). The app reads this field
// and never writes it.
 MemberStatus get status;@PlainDateConverter() DateTime get joinedOn;@NullablePlainDateConverter() DateTime? get leftOn; String? get leftReason;// Member-app invitation. Set by `invite_member` / `link_member_account`;
// the app reads these to say whether an invite is outstanding.
 String? get invitedBy; DateTime? get invitedAt; DateTime? get acceptedAt;// Archive. A member with `archived_at` set is hidden from the working
// list -- a staff search that ignores this column shows people the desk
// has deliberately put away.
 DateTime? get archivedAt; String? get archivedReason; String? get archivedBy;// Consent. Every notification enqueue job checks this before sending.
 bool get notificationsOptOut; String? get createdBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.authUserId, authUserId) || other.authUserId == authUserId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.address, address) || other.address == address)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedOn, joinedOn) || other.joinedOn == joinedOn)&&(identical(other.leftOn, leftOn) || other.leftOn == leftOn)&&(identical(other.leftReason, leftReason) || other.leftReason == leftReason)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedReason, archivedReason) || other.archivedReason == archivedReason)&&(identical(other.archivedBy, archivedBy) || other.archivedBy == archivedBy)&&(identical(other.notificationsOptOut, notificationsOptOut) || other.notificationsOptOut == notificationsOptOut)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,homeBranchId,authUserId,memberCode,fullName,phone,email,dateOfBirth,gender,address,photoPath,emergencyContactName,emergencyContactPhone,notes,status,joinedOn,leftOn,leftReason,invitedBy,invitedAt,acceptedAt,archivedAt,archivedReason,archivedBy,notificationsOptOut,createdBy,createdAt,updatedAt]);

@override
String toString() {
  return 'Member(id: $id, orgId: $orgId, homeBranchId: $homeBranchId, authUserId: $authUserId, memberCode: $memberCode, fullName: $fullName, phone: $phone, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, address: $address, photoPath: $photoPath, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, notes: $notes, status: $status, joinedOn: $joinedOn, leftOn: $leftOn, leftReason: $leftReason, invitedBy: $invitedBy, invitedAt: $invitedAt, acceptedAt: $acceptedAt, archivedAt: $archivedAt, archivedReason: $archivedReason, archivedBy: $archivedBy, notificationsOptOut: $notificationsOptOut, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String homeBranchId, String? authUserId, String memberCode, String fullName, String phone, String? email,@NullablePlainDateConverter() DateTime? dateOfBirth, MemberGender? gender, String? address, String? photoPath, String? emergencyContactName, String? emergencyContactPhone, String? notes, MemberStatus status,@PlainDateConverter() DateTime joinedOn,@NullablePlainDateConverter() DateTime? leftOn, String? leftReason, String? invitedBy, DateTime? invitedAt, DateTime? acceptedAt, DateTime? archivedAt, String? archivedReason, String? archivedBy, bool notificationsOptOut, String? createdBy, DateTime createdAt, DateTime updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? homeBranchId = null,Object? authUserId = freezed,Object? memberCode = null,Object? fullName = null,Object? phone = null,Object? email = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? address = freezed,Object? photoPath = freezed,Object? emergencyContactName = freezed,Object? emergencyContactPhone = freezed,Object? notes = freezed,Object? status = null,Object? joinedOn = null,Object? leftOn = freezed,Object? leftReason = freezed,Object? invitedBy = freezed,Object? invitedAt = freezed,Object? acceptedAt = freezed,Object? archivedAt = freezed,Object? archivedReason = freezed,Object? archivedBy = freezed,Object? notificationsOptOut = null,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
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
as String?,invitedBy: freezed == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String?,invitedAt: freezed == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedReason: freezed == archivedReason ? _self.archivedReason : archivedReason // ignore: cast_nullable_to_non_nullable
as String?,archivedBy: freezed == archivedBy ? _self.archivedBy : archivedBy // ignore: cast_nullable_to_non_nullable
as String?,notificationsOptOut: null == notificationsOptOut ? _self.notificationsOptOut : notificationsOptOut // ignore: cast_nullable_to_non_nullable
as bool,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String homeBranchId,  String? authUserId,  String memberCode,  String fullName,  String phone,  String? email, @NullablePlainDateConverter()  DateTime? dateOfBirth,  MemberGender? gender,  String? address,  String? photoPath,  String? emergencyContactName,  String? emergencyContactPhone,  String? notes,  MemberStatus status, @PlainDateConverter()  DateTime joinedOn, @NullablePlainDateConverter()  DateTime? leftOn,  String? leftReason,  String? invitedBy,  DateTime? invitedAt,  DateTime? acceptedAt,  DateTime? archivedAt,  String? archivedReason,  String? archivedBy,  bool notificationsOptOut,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.authUserId,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.address,_that.photoPath,_that.emergencyContactName,_that.emergencyContactPhone,_that.notes,_that.status,_that.joinedOn,_that.leftOn,_that.leftReason,_that.invitedBy,_that.invitedAt,_that.acceptedAt,_that.archivedAt,_that.archivedReason,_that.archivedBy,_that.notificationsOptOut,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String homeBranchId,  String? authUserId,  String memberCode,  String fullName,  String phone,  String? email, @NullablePlainDateConverter()  DateTime? dateOfBirth,  MemberGender? gender,  String? address,  String? photoPath,  String? emergencyContactName,  String? emergencyContactPhone,  String? notes,  MemberStatus status, @PlainDateConverter()  DateTime joinedOn, @NullablePlainDateConverter()  DateTime? leftOn,  String? leftReason,  String? invitedBy,  DateTime? invitedAt,  DateTime? acceptedAt,  DateTime? archivedAt,  String? archivedReason,  String? archivedBy,  bool notificationsOptOut,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.authUserId,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.address,_that.photoPath,_that.emergencyContactName,_that.emergencyContactPhone,_that.notes,_that.status,_that.joinedOn,_that.leftOn,_that.leftReason,_that.invitedBy,_that.invitedAt,_that.acceptedAt,_that.archivedAt,_that.archivedReason,_that.archivedBy,_that.notificationsOptOut,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String homeBranchId,  String? authUserId,  String memberCode,  String fullName,  String phone,  String? email, @NullablePlainDateConverter()  DateTime? dateOfBirth,  MemberGender? gender,  String? address,  String? photoPath,  String? emergencyContactName,  String? emergencyContactPhone,  String? notes,  MemberStatus status, @PlainDateConverter()  DateTime joinedOn, @NullablePlainDateConverter()  DateTime? leftOn,  String? leftReason,  String? invitedBy,  DateTime? invitedAt,  DateTime? acceptedAt,  DateTime? archivedAt,  String? archivedReason,  String? archivedBy,  bool notificationsOptOut,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.authUserId,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.address,_that.photoPath,_that.emergencyContactName,_that.emergencyContactPhone,_that.notes,_that.status,_that.joinedOn,_that.leftOn,_that.leftReason,_that.invitedBy,_that.invitedAt,_that.acceptedAt,_that.archivedAt,_that.archivedReason,_that.archivedBy,_that.notificationsOptOut,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Member extends Member {
  const _Member({required this.id, required this.orgId, required this.homeBranchId, this.authUserId, required this.memberCode, required this.fullName, required this.phone, this.email, @NullablePlainDateConverter() this.dateOfBirth, this.gender, this.address, this.photoPath, this.emergencyContactName, this.emergencyContactPhone, this.notes, required this.status, @PlainDateConverter() required this.joinedOn, @NullablePlainDateConverter() this.leftOn, this.leftReason, this.invitedBy, this.invitedAt, this.acceptedAt, this.archivedAt, this.archivedReason, this.archivedBy, this.notificationsOptOut = false, this.createdBy, required this.createdAt, required this.updatedAt}): super._();
  factory _Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String homeBranchId;
@override final  String? authUserId;
@override final  String memberCode;
@override final  String fullName;
@override final  String phone;
@override final  String? email;
// `date`, not `timestamptz` -- see plain_date.dart.
@override@NullablePlainDateConverter() final  DateTime? dateOfBirth;
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
@override@PlainDateConverter() final  DateTime joinedOn;
@override@NullablePlainDateConverter() final  DateTime? leftOn;
@override final  String? leftReason;
// Member-app invitation. Set by `invite_member` / `link_member_account`;
// the app reads these to say whether an invite is outstanding.
@override final  String? invitedBy;
@override final  DateTime? invitedAt;
@override final  DateTime? acceptedAt;
// Archive. A member with `archived_at` set is hidden from the working
// list -- a staff search that ignores this column shows people the desk
// has deliberately put away.
@override final  DateTime? archivedAt;
@override final  String? archivedReason;
@override final  String? archivedBy;
// Consent. Every notification enqueue job checks this before sending.
@override@JsonKey() final  bool notificationsOptOut;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.authUserId, authUserId) || other.authUserId == authUserId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.address, address) || other.address == address)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedOn, joinedOn) || other.joinedOn == joinedOn)&&(identical(other.leftOn, leftOn) || other.leftOn == leftOn)&&(identical(other.leftReason, leftReason) || other.leftReason == leftReason)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedReason, archivedReason) || other.archivedReason == archivedReason)&&(identical(other.archivedBy, archivedBy) || other.archivedBy == archivedBy)&&(identical(other.notificationsOptOut, notificationsOptOut) || other.notificationsOptOut == notificationsOptOut)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,homeBranchId,authUserId,memberCode,fullName,phone,email,dateOfBirth,gender,address,photoPath,emergencyContactName,emergencyContactPhone,notes,status,joinedOn,leftOn,leftReason,invitedBy,invitedAt,acceptedAt,archivedAt,archivedReason,archivedBy,notificationsOptOut,createdBy,createdAt,updatedAt]);

@override
String toString() {
  return 'Member(id: $id, orgId: $orgId, homeBranchId: $homeBranchId, authUserId: $authUserId, memberCode: $memberCode, fullName: $fullName, phone: $phone, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, address: $address, photoPath: $photoPath, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, notes: $notes, status: $status, joinedOn: $joinedOn, leftOn: $leftOn, leftReason: $leftReason, invitedBy: $invitedBy, invitedAt: $invitedAt, acceptedAt: $acceptedAt, archivedAt: $archivedAt, archivedReason: $archivedReason, archivedBy: $archivedBy, notificationsOptOut: $notificationsOptOut, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String homeBranchId, String? authUserId, String memberCode, String fullName, String phone, String? email,@NullablePlainDateConverter() DateTime? dateOfBirth, MemberGender? gender, String? address, String? photoPath, String? emergencyContactName, String? emergencyContactPhone, String? notes, MemberStatus status,@PlainDateConverter() DateTime joinedOn,@NullablePlainDateConverter() DateTime? leftOn, String? leftReason, String? invitedBy, DateTime? invitedAt, DateTime? acceptedAt, DateTime? archivedAt, String? archivedReason, String? archivedBy, bool notificationsOptOut, String? createdBy, DateTime createdAt, DateTime updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? homeBranchId = null,Object? authUserId = freezed,Object? memberCode = null,Object? fullName = null,Object? phone = null,Object? email = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? address = freezed,Object? photoPath = freezed,Object? emergencyContactName = freezed,Object? emergencyContactPhone = freezed,Object? notes = freezed,Object? status = null,Object? joinedOn = null,Object? leftOn = freezed,Object? leftReason = freezed,Object? invitedBy = freezed,Object? invitedAt = freezed,Object? acceptedAt = freezed,Object? archivedAt = freezed,Object? archivedReason = freezed,Object? archivedBy = freezed,Object? notificationsOptOut = null,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
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
as String?,invitedBy: freezed == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String?,invitedAt: freezed == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedReason: freezed == archivedReason ? _self.archivedReason : archivedReason // ignore: cast_nullable_to_non_nullable
as String?,archivedBy: freezed == archivedBy ? _self.archivedBy : archivedBy // ignore: cast_nullable_to_non_nullable
as String?,notificationsOptOut: null == notificationsOptOut ? _self.notificationsOptOut : notificationsOptOut // ignore: cast_nullable_to_non_nullable
as bool,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
