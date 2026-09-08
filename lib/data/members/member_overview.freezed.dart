// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberOverview {

// Postgres cannot prove a view column non-null, so the generated console
// types make every one of these nullable and then narrow the ones the
// view structurally guarantees. The same narrowing is applied here: `id`
// through `joined_on` come from `members` joined to `branches`, so a row
// that reached the client has them.
 String get id; String get orgId; String get homeBranchId; String get homeBranchName; String get memberCode; String get fullName; String get phone; String? get email; String? get photoPath;// Trigger-derived. Read, never written -- CLAUDE.md.
 MemberStatus get status;@PlainDateConverter() DateTime get joinedOn;@NullablePlainDateConverter() DateTime? get leftOn;// The lateral pick of the one membership that matters right now: active,
// upcoming or frozen, latest expiry first. All null for a member who has
// never been sold to.
 String? get currentMembershipId; String? get currentPlanId; String? get currentPlanName; PlanType? get currentPlanType; MembershipStatus? get membershipStatus;@NullablePlainDateConverter() DateTime? get membershipStartDate;@NullablePlainDateConverter() DateTime? get membershipEndDate; int? get sessionsRemaining;// `end_date - org_today(org_id)`. Negative once expired, null for a
// session pack with no window. Computed against the *org's* today, which
// is why the client must never recompute it from the device clock.
 int? get daysToExpiry;@JsonKey(fromJson: paisaFromJson) int get duePaisa;@NullablePlainDateConverter() DateTime? get oldestDueOn;// Distinguishes "never sold a plan" from "had one, it lapsed" -- the two
// read identically off the current-membership columns alone.
 bool get hasMembershipHistory; DateTime? get archivedAt;
/// Create a copy of MemberOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberOverviewCopyWith<MemberOverview> get copyWith => _$MemberOverviewCopyWithImpl<MemberOverview>(this as MemberOverview, _$identity);

  /// Serializes this MemberOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberOverview&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.homeBranchName, homeBranchName) || other.homeBranchName == homeBranchName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedOn, joinedOn) || other.joinedOn == joinedOn)&&(identical(other.leftOn, leftOn) || other.leftOn == leftOn)&&(identical(other.currentMembershipId, currentMembershipId) || other.currentMembershipId == currentMembershipId)&&(identical(other.currentPlanId, currentPlanId) || other.currentPlanId == currentPlanId)&&(identical(other.currentPlanName, currentPlanName) || other.currentPlanName == currentPlanName)&&(identical(other.currentPlanType, currentPlanType) || other.currentPlanType == currentPlanType)&&(identical(other.membershipStatus, membershipStatus) || other.membershipStatus == membershipStatus)&&(identical(other.membershipStartDate, membershipStartDate) || other.membershipStartDate == membershipStartDate)&&(identical(other.membershipEndDate, membershipEndDate) || other.membershipEndDate == membershipEndDate)&&(identical(other.sessionsRemaining, sessionsRemaining) || other.sessionsRemaining == sessionsRemaining)&&(identical(other.daysToExpiry, daysToExpiry) || other.daysToExpiry == daysToExpiry)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.oldestDueOn, oldestDueOn) || other.oldestDueOn == oldestDueOn)&&(identical(other.hasMembershipHistory, hasMembershipHistory) || other.hasMembershipHistory == hasMembershipHistory)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,homeBranchId,homeBranchName,memberCode,fullName,phone,email,photoPath,status,joinedOn,leftOn,currentMembershipId,currentPlanId,currentPlanName,currentPlanType,membershipStatus,membershipStartDate,membershipEndDate,sessionsRemaining,daysToExpiry,duePaisa,oldestDueOn,hasMembershipHistory,archivedAt]);

@override
String toString() {
  return 'MemberOverview(id: $id, orgId: $orgId, homeBranchId: $homeBranchId, homeBranchName: $homeBranchName, memberCode: $memberCode, fullName: $fullName, phone: $phone, email: $email, photoPath: $photoPath, status: $status, joinedOn: $joinedOn, leftOn: $leftOn, currentMembershipId: $currentMembershipId, currentPlanId: $currentPlanId, currentPlanName: $currentPlanName, currentPlanType: $currentPlanType, membershipStatus: $membershipStatus, membershipStartDate: $membershipStartDate, membershipEndDate: $membershipEndDate, sessionsRemaining: $sessionsRemaining, daysToExpiry: $daysToExpiry, duePaisa: $duePaisa, oldestDueOn: $oldestDueOn, hasMembershipHistory: $hasMembershipHistory, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class $MemberOverviewCopyWith<$Res>  {
  factory $MemberOverviewCopyWith(MemberOverview value, $Res Function(MemberOverview) _then) = _$MemberOverviewCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String homeBranchId, String homeBranchName, String memberCode, String fullName, String phone, String? email, String? photoPath, MemberStatus status,@PlainDateConverter() DateTime joinedOn,@NullablePlainDateConverter() DateTime? leftOn, String? currentMembershipId, String? currentPlanId, String? currentPlanName, PlanType? currentPlanType, MembershipStatus? membershipStatus,@NullablePlainDateConverter() DateTime? membershipStartDate,@NullablePlainDateConverter() DateTime? membershipEndDate, int? sessionsRemaining, int? daysToExpiry,@JsonKey(fromJson: paisaFromJson) int duePaisa,@NullablePlainDateConverter() DateTime? oldestDueOn, bool hasMembershipHistory, DateTime? archivedAt
});




}
/// @nodoc
class _$MemberOverviewCopyWithImpl<$Res>
    implements $MemberOverviewCopyWith<$Res> {
  _$MemberOverviewCopyWithImpl(this._self, this._then);

  final MemberOverview _self;
  final $Res Function(MemberOverview) _then;

/// Create a copy of MemberOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? homeBranchId = null,Object? homeBranchName = null,Object? memberCode = null,Object? fullName = null,Object? phone = null,Object? email = freezed,Object? photoPath = freezed,Object? status = null,Object? joinedOn = null,Object? leftOn = freezed,Object? currentMembershipId = freezed,Object? currentPlanId = freezed,Object? currentPlanName = freezed,Object? currentPlanType = freezed,Object? membershipStatus = freezed,Object? membershipStartDate = freezed,Object? membershipEndDate = freezed,Object? sessionsRemaining = freezed,Object? daysToExpiry = freezed,Object? duePaisa = null,Object? oldestDueOn = freezed,Object? hasMembershipHistory = null,Object? archivedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,homeBranchName: null == homeBranchName ? _self.homeBranchName : homeBranchName // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,joinedOn: null == joinedOn ? _self.joinedOn : joinedOn // ignore: cast_nullable_to_non_nullable
as DateTime,leftOn: freezed == leftOn ? _self.leftOn : leftOn // ignore: cast_nullable_to_non_nullable
as DateTime?,currentMembershipId: freezed == currentMembershipId ? _self.currentMembershipId : currentMembershipId // ignore: cast_nullable_to_non_nullable
as String?,currentPlanId: freezed == currentPlanId ? _self.currentPlanId : currentPlanId // ignore: cast_nullable_to_non_nullable
as String?,currentPlanName: freezed == currentPlanName ? _self.currentPlanName : currentPlanName // ignore: cast_nullable_to_non_nullable
as String?,currentPlanType: freezed == currentPlanType ? _self.currentPlanType : currentPlanType // ignore: cast_nullable_to_non_nullable
as PlanType?,membershipStatus: freezed == membershipStatus ? _self.membershipStatus : membershipStatus // ignore: cast_nullable_to_non_nullable
as MembershipStatus?,membershipStartDate: freezed == membershipStartDate ? _self.membershipStartDate : membershipStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,membershipEndDate: freezed == membershipEndDate ? _self.membershipEndDate : membershipEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sessionsRemaining: freezed == sessionsRemaining ? _self.sessionsRemaining : sessionsRemaining // ignore: cast_nullable_to_non_nullable
as int?,daysToExpiry: freezed == daysToExpiry ? _self.daysToExpiry : daysToExpiry // ignore: cast_nullable_to_non_nullable
as int?,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,oldestDueOn: freezed == oldestDueOn ? _self.oldestDueOn : oldestDueOn // ignore: cast_nullable_to_non_nullable
as DateTime?,hasMembershipHistory: null == hasMembershipHistory ? _self.hasMembershipHistory : hasMembershipHistory // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberOverview].
extension MemberOverviewPatterns on MemberOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberOverview value)  $default,){
final _that = this;
switch (_that) {
case _MemberOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberOverview value)?  $default,){
final _that = this;
switch (_that) {
case _MemberOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String homeBranchId,  String homeBranchName,  String memberCode,  String fullName,  String phone,  String? email,  String? photoPath,  MemberStatus status, @PlainDateConverter()  DateTime joinedOn, @NullablePlainDateConverter()  DateTime? leftOn,  String? currentMembershipId,  String? currentPlanId,  String? currentPlanName,  PlanType? currentPlanType,  MembershipStatus? membershipStatus, @NullablePlainDateConverter()  DateTime? membershipStartDate, @NullablePlainDateConverter()  DateTime? membershipEndDate,  int? sessionsRemaining,  int? daysToExpiry, @JsonKey(fromJson: paisaFromJson)  int duePaisa, @NullablePlainDateConverter()  DateTime? oldestDueOn,  bool hasMembershipHistory,  DateTime? archivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberOverview() when $default != null:
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.homeBranchName,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.photoPath,_that.status,_that.joinedOn,_that.leftOn,_that.currentMembershipId,_that.currentPlanId,_that.currentPlanName,_that.currentPlanType,_that.membershipStatus,_that.membershipStartDate,_that.membershipEndDate,_that.sessionsRemaining,_that.daysToExpiry,_that.duePaisa,_that.oldestDueOn,_that.hasMembershipHistory,_that.archivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String homeBranchId,  String homeBranchName,  String memberCode,  String fullName,  String phone,  String? email,  String? photoPath,  MemberStatus status, @PlainDateConverter()  DateTime joinedOn, @NullablePlainDateConverter()  DateTime? leftOn,  String? currentMembershipId,  String? currentPlanId,  String? currentPlanName,  PlanType? currentPlanType,  MembershipStatus? membershipStatus, @NullablePlainDateConverter()  DateTime? membershipStartDate, @NullablePlainDateConverter()  DateTime? membershipEndDate,  int? sessionsRemaining,  int? daysToExpiry, @JsonKey(fromJson: paisaFromJson)  int duePaisa, @NullablePlainDateConverter()  DateTime? oldestDueOn,  bool hasMembershipHistory,  DateTime? archivedAt)  $default,) {final _that = this;
switch (_that) {
case _MemberOverview():
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.homeBranchName,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.photoPath,_that.status,_that.joinedOn,_that.leftOn,_that.currentMembershipId,_that.currentPlanId,_that.currentPlanName,_that.currentPlanType,_that.membershipStatus,_that.membershipStartDate,_that.membershipEndDate,_that.sessionsRemaining,_that.daysToExpiry,_that.duePaisa,_that.oldestDueOn,_that.hasMembershipHistory,_that.archivedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String homeBranchId,  String homeBranchName,  String memberCode,  String fullName,  String phone,  String? email,  String? photoPath,  MemberStatus status, @PlainDateConverter()  DateTime joinedOn, @NullablePlainDateConverter()  DateTime? leftOn,  String? currentMembershipId,  String? currentPlanId,  String? currentPlanName,  PlanType? currentPlanType,  MembershipStatus? membershipStatus, @NullablePlainDateConverter()  DateTime? membershipStartDate, @NullablePlainDateConverter()  DateTime? membershipEndDate,  int? sessionsRemaining,  int? daysToExpiry, @JsonKey(fromJson: paisaFromJson)  int duePaisa, @NullablePlainDateConverter()  DateTime? oldestDueOn,  bool hasMembershipHistory,  DateTime? archivedAt)?  $default,) {final _that = this;
switch (_that) {
case _MemberOverview() when $default != null:
return $default(_that.id,_that.orgId,_that.homeBranchId,_that.homeBranchName,_that.memberCode,_that.fullName,_that.phone,_that.email,_that.photoPath,_that.status,_that.joinedOn,_that.leftOn,_that.currentMembershipId,_that.currentPlanId,_that.currentPlanName,_that.currentPlanType,_that.membershipStatus,_that.membershipStartDate,_that.membershipEndDate,_that.sessionsRemaining,_that.daysToExpiry,_that.duePaisa,_that.oldestDueOn,_that.hasMembershipHistory,_that.archivedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MemberOverview extends MemberOverview {
  const _MemberOverview({required this.id, required this.orgId, required this.homeBranchId, required this.homeBranchName, required this.memberCode, required this.fullName, required this.phone, this.email, this.photoPath, required this.status, @PlainDateConverter() required this.joinedOn, @NullablePlainDateConverter() this.leftOn, this.currentMembershipId, this.currentPlanId, this.currentPlanName, this.currentPlanType, this.membershipStatus, @NullablePlainDateConverter() this.membershipStartDate, @NullablePlainDateConverter() this.membershipEndDate, this.sessionsRemaining, this.daysToExpiry, @JsonKey(fromJson: paisaFromJson) required this.duePaisa, @NullablePlainDateConverter() this.oldestDueOn, required this.hasMembershipHistory, this.archivedAt}): super._();
  factory _MemberOverview.fromJson(Map<String, dynamic> json) => _$MemberOverviewFromJson(json);

// Postgres cannot prove a view column non-null, so the generated console
// types make every one of these nullable and then narrow the ones the
// view structurally guarantees. The same narrowing is applied here: `id`
// through `joined_on` come from `members` joined to `branches`, so a row
// that reached the client has them.
@override final  String id;
@override final  String orgId;
@override final  String homeBranchId;
@override final  String homeBranchName;
@override final  String memberCode;
@override final  String fullName;
@override final  String phone;
@override final  String? email;
@override final  String? photoPath;
// Trigger-derived. Read, never written -- CLAUDE.md.
@override final  MemberStatus status;
@override@PlainDateConverter() final  DateTime joinedOn;
@override@NullablePlainDateConverter() final  DateTime? leftOn;
// The lateral pick of the one membership that matters right now: active,
// upcoming or frozen, latest expiry first. All null for a member who has
// never been sold to.
@override final  String? currentMembershipId;
@override final  String? currentPlanId;
@override final  String? currentPlanName;
@override final  PlanType? currentPlanType;
@override final  MembershipStatus? membershipStatus;
@override@NullablePlainDateConverter() final  DateTime? membershipStartDate;
@override@NullablePlainDateConverter() final  DateTime? membershipEndDate;
@override final  int? sessionsRemaining;
// `end_date - org_today(org_id)`. Negative once expired, null for a
// session pack with no window. Computed against the *org's* today, which
// is why the client must never recompute it from the device clock.
@override final  int? daysToExpiry;
@override@JsonKey(fromJson: paisaFromJson) final  int duePaisa;
@override@NullablePlainDateConverter() final  DateTime? oldestDueOn;
// Distinguishes "never sold a plan" from "had one, it lapsed" -- the two
// read identically off the current-membership columns alone.
@override final  bool hasMembershipHistory;
@override final  DateTime? archivedAt;

/// Create a copy of MemberOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberOverviewCopyWith<_MemberOverview> get copyWith => __$MemberOverviewCopyWithImpl<_MemberOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberOverview&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.homeBranchName, homeBranchName) || other.homeBranchName == homeBranchName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedOn, joinedOn) || other.joinedOn == joinedOn)&&(identical(other.leftOn, leftOn) || other.leftOn == leftOn)&&(identical(other.currentMembershipId, currentMembershipId) || other.currentMembershipId == currentMembershipId)&&(identical(other.currentPlanId, currentPlanId) || other.currentPlanId == currentPlanId)&&(identical(other.currentPlanName, currentPlanName) || other.currentPlanName == currentPlanName)&&(identical(other.currentPlanType, currentPlanType) || other.currentPlanType == currentPlanType)&&(identical(other.membershipStatus, membershipStatus) || other.membershipStatus == membershipStatus)&&(identical(other.membershipStartDate, membershipStartDate) || other.membershipStartDate == membershipStartDate)&&(identical(other.membershipEndDate, membershipEndDate) || other.membershipEndDate == membershipEndDate)&&(identical(other.sessionsRemaining, sessionsRemaining) || other.sessionsRemaining == sessionsRemaining)&&(identical(other.daysToExpiry, daysToExpiry) || other.daysToExpiry == daysToExpiry)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.oldestDueOn, oldestDueOn) || other.oldestDueOn == oldestDueOn)&&(identical(other.hasMembershipHistory, hasMembershipHistory) || other.hasMembershipHistory == hasMembershipHistory)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,homeBranchId,homeBranchName,memberCode,fullName,phone,email,photoPath,status,joinedOn,leftOn,currentMembershipId,currentPlanId,currentPlanName,currentPlanType,membershipStatus,membershipStartDate,membershipEndDate,sessionsRemaining,daysToExpiry,duePaisa,oldestDueOn,hasMembershipHistory,archivedAt]);

@override
String toString() {
  return 'MemberOverview(id: $id, orgId: $orgId, homeBranchId: $homeBranchId, homeBranchName: $homeBranchName, memberCode: $memberCode, fullName: $fullName, phone: $phone, email: $email, photoPath: $photoPath, status: $status, joinedOn: $joinedOn, leftOn: $leftOn, currentMembershipId: $currentMembershipId, currentPlanId: $currentPlanId, currentPlanName: $currentPlanName, currentPlanType: $currentPlanType, membershipStatus: $membershipStatus, membershipStartDate: $membershipStartDate, membershipEndDate: $membershipEndDate, sessionsRemaining: $sessionsRemaining, daysToExpiry: $daysToExpiry, duePaisa: $duePaisa, oldestDueOn: $oldestDueOn, hasMembershipHistory: $hasMembershipHistory, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class _$MemberOverviewCopyWith<$Res> implements $MemberOverviewCopyWith<$Res> {
  factory _$MemberOverviewCopyWith(_MemberOverview value, $Res Function(_MemberOverview) _then) = __$MemberOverviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String homeBranchId, String homeBranchName, String memberCode, String fullName, String phone, String? email, String? photoPath, MemberStatus status,@PlainDateConverter() DateTime joinedOn,@NullablePlainDateConverter() DateTime? leftOn, String? currentMembershipId, String? currentPlanId, String? currentPlanName, PlanType? currentPlanType, MembershipStatus? membershipStatus,@NullablePlainDateConverter() DateTime? membershipStartDate,@NullablePlainDateConverter() DateTime? membershipEndDate, int? sessionsRemaining, int? daysToExpiry,@JsonKey(fromJson: paisaFromJson) int duePaisa,@NullablePlainDateConverter() DateTime? oldestDueOn, bool hasMembershipHistory, DateTime? archivedAt
});




}
/// @nodoc
class __$MemberOverviewCopyWithImpl<$Res>
    implements _$MemberOverviewCopyWith<$Res> {
  __$MemberOverviewCopyWithImpl(this._self, this._then);

  final _MemberOverview _self;
  final $Res Function(_MemberOverview) _then;

/// Create a copy of MemberOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? homeBranchId = null,Object? homeBranchName = null,Object? memberCode = null,Object? fullName = null,Object? phone = null,Object? email = freezed,Object? photoPath = freezed,Object? status = null,Object? joinedOn = null,Object? leftOn = freezed,Object? currentMembershipId = freezed,Object? currentPlanId = freezed,Object? currentPlanName = freezed,Object? currentPlanType = freezed,Object? membershipStatus = freezed,Object? membershipStartDate = freezed,Object? membershipEndDate = freezed,Object? sessionsRemaining = freezed,Object? daysToExpiry = freezed,Object? duePaisa = null,Object? oldestDueOn = freezed,Object? hasMembershipHistory = null,Object? archivedAt = freezed,}) {
  return _then(_MemberOverview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,homeBranchName: null == homeBranchName ? _self.homeBranchName : homeBranchName // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,joinedOn: null == joinedOn ? _self.joinedOn : joinedOn // ignore: cast_nullable_to_non_nullable
as DateTime,leftOn: freezed == leftOn ? _self.leftOn : leftOn // ignore: cast_nullable_to_non_nullable
as DateTime?,currentMembershipId: freezed == currentMembershipId ? _self.currentMembershipId : currentMembershipId // ignore: cast_nullable_to_non_nullable
as String?,currentPlanId: freezed == currentPlanId ? _self.currentPlanId : currentPlanId // ignore: cast_nullable_to_non_nullable
as String?,currentPlanName: freezed == currentPlanName ? _self.currentPlanName : currentPlanName // ignore: cast_nullable_to_non_nullable
as String?,currentPlanType: freezed == currentPlanType ? _self.currentPlanType : currentPlanType // ignore: cast_nullable_to_non_nullable
as PlanType?,membershipStatus: freezed == membershipStatus ? _self.membershipStatus : membershipStatus // ignore: cast_nullable_to_non_nullable
as MembershipStatus?,membershipStartDate: freezed == membershipStartDate ? _self.membershipStartDate : membershipStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,membershipEndDate: freezed == membershipEndDate ? _self.membershipEndDate : membershipEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sessionsRemaining: freezed == sessionsRemaining ? _self.sessionsRemaining : sessionsRemaining // ignore: cast_nullable_to_non_nullable
as int?,daysToExpiry: freezed == daysToExpiry ? _self.daysToExpiry : daysToExpiry // ignore: cast_nullable_to_non_nullable
as int?,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,oldestDueOn: freezed == oldestDueOn ? _self.oldestDueOn : oldestDueOn // ignore: cast_nullable_to_non_nullable
as DateTime?,hasMembershipHistory: null == hasMembershipHistory ? _self.hasMembershipHistory : hasMembershipHistory // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
