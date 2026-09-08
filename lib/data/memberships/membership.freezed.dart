// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Membership {

 String get id; String get orgId; String get branchId; String get memberId; String get planId;// Snapshot of the plan as sold at the time of sale.
 String get planName; PlanType get planType;// `date`, not `timestamptz` -- a membership window is calendar days. Left
// on the default converter these decoded to *local* midnight, so once the
// value reached `formatPlainDate` the day drifted for any org east of
// UTC. TASKS.md Discovered 2026-09-05 called this out for exactly these
// columns; see lib/domain/format/plain_date.dart.
@PlainDateConverter() DateTime get startDate;// Null for a session pack sold with no validity window -- the shape
// `adjust_membership_dates` explicitly accepts a null end date for.
@NullablePlainDateConverter() DateTime? get endDate; int? get sessionsTotal; int? get sessionsRemaining;// Money is integer paisa end to end. Never a double, never converted here.
 int get pricePaisa; int get discountPaisa;// The joining fee this sale charged, kept apart from the plan price so a
// renewal that waives it stays legible on the invoice.
 int get signupFeePaisa;// Written by the RPCs (`renew_membership`, `freeze_membership`,
// `cancel_membership`) and by the status derivation trigger, never by the
// app.
 MembershipStatus get status;@NullablePlainDateConverter() DateTime? get frozenOn; int get frozenDays; DateTime? get cancelledAt; String? get cancelReason; String? get previousMembershipId; String? get soldBy; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCopyWith<Membership> get copyWith => _$MembershipCopyWithImpl<Membership>(this as Membership, _$identity);

  /// Serializes this Membership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sessionsTotal, sessionsTotal) || other.sessionsTotal == sessionsTotal)&&(identical(other.sessionsRemaining, sessionsRemaining) || other.sessionsRemaining == sessionsRemaining)&&(identical(other.pricePaisa, pricePaisa) || other.pricePaisa == pricePaisa)&&(identical(other.discountPaisa, discountPaisa) || other.discountPaisa == discountPaisa)&&(identical(other.signupFeePaisa, signupFeePaisa) || other.signupFeePaisa == signupFeePaisa)&&(identical(other.status, status) || other.status == status)&&(identical(other.frozenOn, frozenOn) || other.frozenOn == frozenOn)&&(identical(other.frozenDays, frozenDays) || other.frozenDays == frozenDays)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.previousMembershipId, previousMembershipId) || other.previousMembershipId == previousMembershipId)&&(identical(other.soldBy, soldBy) || other.soldBy == soldBy)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,branchId,memberId,planId,planName,planType,startDate,endDate,sessionsTotal,sessionsRemaining,pricePaisa,discountPaisa,signupFeePaisa,status,frozenOn,frozenDays,cancelledAt,cancelReason,previousMembershipId,soldBy,notes,createdAt,updatedAt]);

@override
String toString() {
  return 'Membership(id: $id, orgId: $orgId, branchId: $branchId, memberId: $memberId, planId: $planId, planName: $planName, planType: $planType, startDate: $startDate, endDate: $endDate, sessionsTotal: $sessionsTotal, sessionsRemaining: $sessionsRemaining, pricePaisa: $pricePaisa, discountPaisa: $discountPaisa, signupFeePaisa: $signupFeePaisa, status: $status, frozenOn: $frozenOn, frozenDays: $frozenDays, cancelledAt: $cancelledAt, cancelReason: $cancelReason, previousMembershipId: $previousMembershipId, soldBy: $soldBy, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MembershipCopyWith<$Res>  {
  factory $MembershipCopyWith(Membership value, $Res Function(Membership) _then) = _$MembershipCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String branchId, String memberId, String planId, String planName, PlanType planType,@PlainDateConverter() DateTime startDate,@NullablePlainDateConverter() DateTime? endDate, int? sessionsTotal, int? sessionsRemaining, int pricePaisa, int discountPaisa, int signupFeePaisa, MembershipStatus status,@NullablePlainDateConverter() DateTime? frozenOn, int frozenDays, DateTime? cancelledAt, String? cancelReason, String? previousMembershipId, String? soldBy, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$MembershipCopyWithImpl<$Res>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._self, this._then);

  final Membership _self;
  final $Res Function(Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? branchId = null,Object? memberId = null,Object? planId = null,Object? planName = null,Object? planType = null,Object? startDate = null,Object? endDate = freezed,Object? sessionsTotal = freezed,Object? sessionsRemaining = freezed,Object? pricePaisa = null,Object? discountPaisa = null,Object? signupFeePaisa = null,Object? status = null,Object? frozenOn = freezed,Object? frozenDays = null,Object? cancelledAt = freezed,Object? cancelReason = freezed,Object? previousMembershipId = freezed,Object? soldBy = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as PlanType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sessionsTotal: freezed == sessionsTotal ? _self.sessionsTotal : sessionsTotal // ignore: cast_nullable_to_non_nullable
as int?,sessionsRemaining: freezed == sessionsRemaining ? _self.sessionsRemaining : sessionsRemaining // ignore: cast_nullable_to_non_nullable
as int?,pricePaisa: null == pricePaisa ? _self.pricePaisa : pricePaisa // ignore: cast_nullable_to_non_nullable
as int,discountPaisa: null == discountPaisa ? _self.discountPaisa : discountPaisa // ignore: cast_nullable_to_non_nullable
as int,signupFeePaisa: null == signupFeePaisa ? _self.signupFeePaisa : signupFeePaisa // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,frozenOn: freezed == frozenOn ? _self.frozenOn : frozenOn // ignore: cast_nullable_to_non_nullable
as DateTime?,frozenDays: null == frozenDays ? _self.frozenDays : frozenDays // ignore: cast_nullable_to_non_nullable
as int,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,previousMembershipId: freezed == previousMembershipId ? _self.previousMembershipId : previousMembershipId // ignore: cast_nullable_to_non_nullable
as String?,soldBy: freezed == soldBy ? _self.soldBy : soldBy // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Membership].
extension MembershipPatterns on Membership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membership value)  $default,){
final _that = this;
switch (_that) {
case _Membership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membership value)?  $default,){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String branchId,  String memberId,  String planId,  String planName,  PlanType planType, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? sessionsTotal,  int? sessionsRemaining,  int pricePaisa,  int discountPaisa,  int signupFeePaisa,  MembershipStatus status, @NullablePlainDateConverter()  DateTime? frozenOn,  int frozenDays,  DateTime? cancelledAt,  String? cancelReason,  String? previousMembershipId,  String? soldBy,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.planId,_that.planName,_that.planType,_that.startDate,_that.endDate,_that.sessionsTotal,_that.sessionsRemaining,_that.pricePaisa,_that.discountPaisa,_that.signupFeePaisa,_that.status,_that.frozenOn,_that.frozenDays,_that.cancelledAt,_that.cancelReason,_that.previousMembershipId,_that.soldBy,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String branchId,  String memberId,  String planId,  String planName,  PlanType planType, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? sessionsTotal,  int? sessionsRemaining,  int pricePaisa,  int discountPaisa,  int signupFeePaisa,  MembershipStatus status, @NullablePlainDateConverter()  DateTime? frozenOn,  int frozenDays,  DateTime? cancelledAt,  String? cancelReason,  String? previousMembershipId,  String? soldBy,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Membership():
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.planId,_that.planName,_that.planType,_that.startDate,_that.endDate,_that.sessionsTotal,_that.sessionsRemaining,_that.pricePaisa,_that.discountPaisa,_that.signupFeePaisa,_that.status,_that.frozenOn,_that.frozenDays,_that.cancelledAt,_that.cancelReason,_that.previousMembershipId,_that.soldBy,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String branchId,  String memberId,  String planId,  String planName,  PlanType planType, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? sessionsTotal,  int? sessionsRemaining,  int pricePaisa,  int discountPaisa,  int signupFeePaisa,  MembershipStatus status, @NullablePlainDateConverter()  DateTime? frozenOn,  int frozenDays,  DateTime? cancelledAt,  String? cancelReason,  String? previousMembershipId,  String? soldBy,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.planId,_that.planName,_that.planType,_that.startDate,_that.endDate,_that.sessionsTotal,_that.sessionsRemaining,_that.pricePaisa,_that.discountPaisa,_that.signupFeePaisa,_that.status,_that.frozenOn,_that.frozenDays,_that.cancelledAt,_that.cancelReason,_that.previousMembershipId,_that.soldBy,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Membership implements Membership {
  const _Membership({required this.id, required this.orgId, required this.branchId, required this.memberId, required this.planId, required this.planName, required this.planType, @PlainDateConverter() required this.startDate, @NullablePlainDateConverter() this.endDate, this.sessionsTotal, this.sessionsRemaining, required this.pricePaisa, required this.discountPaisa, required this.signupFeePaisa, required this.status, @NullablePlainDateConverter() this.frozenOn, required this.frozenDays, this.cancelledAt, this.cancelReason, this.previousMembershipId, this.soldBy, this.notes, required this.createdAt, required this.updatedAt});
  factory _Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String branchId;
@override final  String memberId;
@override final  String planId;
// Snapshot of the plan as sold at the time of sale.
@override final  String planName;
@override final  PlanType planType;
// `date`, not `timestamptz` -- a membership window is calendar days. Left
// on the default converter these decoded to *local* midnight, so once the
// value reached `formatPlainDate` the day drifted for any org east of
// UTC. TASKS.md Discovered 2026-09-05 called this out for exactly these
// columns; see lib/domain/format/plain_date.dart.
@override@PlainDateConverter() final  DateTime startDate;
// Null for a session pack sold with no validity window -- the shape
// `adjust_membership_dates` explicitly accepts a null end date for.
@override@NullablePlainDateConverter() final  DateTime? endDate;
@override final  int? sessionsTotal;
@override final  int? sessionsRemaining;
// Money is integer paisa end to end. Never a double, never converted here.
@override final  int pricePaisa;
@override final  int discountPaisa;
// The joining fee this sale charged, kept apart from the plan price so a
// renewal that waives it stays legible on the invoice.
@override final  int signupFeePaisa;
// Written by the RPCs (`renew_membership`, `freeze_membership`,
// `cancel_membership`) and by the status derivation trigger, never by the
// app.
@override final  MembershipStatus status;
@override@NullablePlainDateConverter() final  DateTime? frozenOn;
@override final  int frozenDays;
@override final  DateTime? cancelledAt;
@override final  String? cancelReason;
@override final  String? previousMembershipId;
@override final  String? soldBy;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCopyWith<_Membership> get copyWith => __$MembershipCopyWithImpl<_Membership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sessionsTotal, sessionsTotal) || other.sessionsTotal == sessionsTotal)&&(identical(other.sessionsRemaining, sessionsRemaining) || other.sessionsRemaining == sessionsRemaining)&&(identical(other.pricePaisa, pricePaisa) || other.pricePaisa == pricePaisa)&&(identical(other.discountPaisa, discountPaisa) || other.discountPaisa == discountPaisa)&&(identical(other.signupFeePaisa, signupFeePaisa) || other.signupFeePaisa == signupFeePaisa)&&(identical(other.status, status) || other.status == status)&&(identical(other.frozenOn, frozenOn) || other.frozenOn == frozenOn)&&(identical(other.frozenDays, frozenDays) || other.frozenDays == frozenDays)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.previousMembershipId, previousMembershipId) || other.previousMembershipId == previousMembershipId)&&(identical(other.soldBy, soldBy) || other.soldBy == soldBy)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orgId,branchId,memberId,planId,planName,planType,startDate,endDate,sessionsTotal,sessionsRemaining,pricePaisa,discountPaisa,signupFeePaisa,status,frozenOn,frozenDays,cancelledAt,cancelReason,previousMembershipId,soldBy,notes,createdAt,updatedAt]);

@override
String toString() {
  return 'Membership(id: $id, orgId: $orgId, branchId: $branchId, memberId: $memberId, planId: $planId, planName: $planName, planType: $planType, startDate: $startDate, endDate: $endDate, sessionsTotal: $sessionsTotal, sessionsRemaining: $sessionsRemaining, pricePaisa: $pricePaisa, discountPaisa: $discountPaisa, signupFeePaisa: $signupFeePaisa, status: $status, frozenOn: $frozenOn, frozenDays: $frozenDays, cancelledAt: $cancelledAt, cancelReason: $cancelReason, previousMembershipId: $previousMembershipId, soldBy: $soldBy, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MembershipCopyWith<$Res> implements $MembershipCopyWith<$Res> {
  factory _$MembershipCopyWith(_Membership value, $Res Function(_Membership) _then) = __$MembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String branchId, String memberId, String planId, String planName, PlanType planType,@PlainDateConverter() DateTime startDate,@NullablePlainDateConverter() DateTime? endDate, int? sessionsTotal, int? sessionsRemaining, int pricePaisa, int discountPaisa, int signupFeePaisa, MembershipStatus status,@NullablePlainDateConverter() DateTime? frozenOn, int frozenDays, DateTime? cancelledAt, String? cancelReason, String? previousMembershipId, String? soldBy, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$MembershipCopyWithImpl<$Res>
    implements _$MembershipCopyWith<$Res> {
  __$MembershipCopyWithImpl(this._self, this._then);

  final _Membership _self;
  final $Res Function(_Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? branchId = null,Object? memberId = null,Object? planId = null,Object? planName = null,Object? planType = null,Object? startDate = null,Object? endDate = freezed,Object? sessionsTotal = freezed,Object? sessionsRemaining = freezed,Object? pricePaisa = null,Object? discountPaisa = null,Object? signupFeePaisa = null,Object? status = null,Object? frozenOn = freezed,Object? frozenDays = null,Object? cancelledAt = freezed,Object? cancelReason = freezed,Object? previousMembershipId = freezed,Object? soldBy = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Membership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as PlanType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sessionsTotal: freezed == sessionsTotal ? _self.sessionsTotal : sessionsTotal // ignore: cast_nullable_to_non_nullable
as int?,sessionsRemaining: freezed == sessionsRemaining ? _self.sessionsRemaining : sessionsRemaining // ignore: cast_nullable_to_non_nullable
as int?,pricePaisa: null == pricePaisa ? _self.pricePaisa : pricePaisa // ignore: cast_nullable_to_non_nullable
as int,discountPaisa: null == discountPaisa ? _self.discountPaisa : discountPaisa // ignore: cast_nullable_to_non_nullable
as int,signupFeePaisa: null == signupFeePaisa ? _self.signupFeePaisa : signupFeePaisa // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,frozenOn: freezed == frozenOn ? _self.frozenOn : frozenOn // ignore: cast_nullable_to_non_nullable
as DateTime?,frozenDays: null == frozenDays ? _self.frozenDays : frozenDays // ignore: cast_nullable_to_non_nullable
as int,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,previousMembershipId: freezed == previousMembershipId ? _self.previousMembershipId : previousMembershipId // ignore: cast_nullable_to_non_nullable
as String?,soldBy: freezed == soldBy ? _self.soldBy : soldBy // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
