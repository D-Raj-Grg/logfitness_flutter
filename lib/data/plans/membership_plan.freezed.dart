// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MembershipPlan {

 String get id; String get orgId; String get name; String? get description; PlanType get planType; int? get durationDays; int? get sessionCount;// Money is integer paisa end to end. Never a double, never converted here.
 int get pricePaisa; int get signupFeePaisa; List<String> get branchIds; bool get isActive; int get sortOrder; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of MembershipPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipPlanCopyWith<MembershipPlan> get copyWith => _$MembershipPlanCopyWithImpl<MembershipPlan>(this as MembershipPlan, _$identity);

  /// Serializes this MembershipPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.pricePaisa, pricePaisa) || other.pricePaisa == pricePaisa)&&(identical(other.signupFeePaisa, signupFeePaisa) || other.signupFeePaisa == signupFeePaisa)&&const DeepCollectionEquality().equals(other.branchIds, branchIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,name,description,planType,durationDays,sessionCount,pricePaisa,signupFeePaisa,const DeepCollectionEquality().hash(branchIds),isActive,sortOrder,createdAt,updatedAt);

@override
String toString() {
  return 'MembershipPlan(id: $id, orgId: $orgId, name: $name, description: $description, planType: $planType, durationDays: $durationDays, sessionCount: $sessionCount, pricePaisa: $pricePaisa, signupFeePaisa: $signupFeePaisa, branchIds: $branchIds, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MembershipPlanCopyWith<$Res>  {
  factory $MembershipPlanCopyWith(MembershipPlan value, $Res Function(MembershipPlan) _then) = _$MembershipPlanCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String name, String? description, PlanType planType, int? durationDays, int? sessionCount, int pricePaisa, int signupFeePaisa, List<String> branchIds, bool isActive, int sortOrder, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$MembershipPlanCopyWithImpl<$Res>
    implements $MembershipPlanCopyWith<$Res> {
  _$MembershipPlanCopyWithImpl(this._self, this._then);

  final MembershipPlan _self;
  final $Res Function(MembershipPlan) _then;

/// Create a copy of MembershipPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? name = null,Object? description = freezed,Object? planType = null,Object? durationDays = freezed,Object? sessionCount = freezed,Object? pricePaisa = null,Object? signupFeePaisa = null,Object? branchIds = null,Object? isActive = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as PlanType,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,sessionCount: freezed == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int?,pricePaisa: null == pricePaisa ? _self.pricePaisa : pricePaisa // ignore: cast_nullable_to_non_nullable
as int,signupFeePaisa: null == signupFeePaisa ? _self.signupFeePaisa : signupFeePaisa // ignore: cast_nullable_to_non_nullable
as int,branchIds: null == branchIds ? _self.branchIds : branchIds // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipPlan].
extension MembershipPlanPatterns on MembershipPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipPlan value)  $default,){
final _that = this;
switch (_that) {
case _MembershipPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipPlan value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String name,  String? description,  PlanType planType,  int? durationDays,  int? sessionCount,  int pricePaisa,  int signupFeePaisa,  List<String> branchIds,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipPlan() when $default != null:
return $default(_that.id,_that.orgId,_that.name,_that.description,_that.planType,_that.durationDays,_that.sessionCount,_that.pricePaisa,_that.signupFeePaisa,_that.branchIds,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String name,  String? description,  PlanType planType,  int? durationDays,  int? sessionCount,  int pricePaisa,  int signupFeePaisa,  List<String> branchIds,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MembershipPlan():
return $default(_that.id,_that.orgId,_that.name,_that.description,_that.planType,_that.durationDays,_that.sessionCount,_that.pricePaisa,_that.signupFeePaisa,_that.branchIds,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String name,  String? description,  PlanType planType,  int? durationDays,  int? sessionCount,  int pricePaisa,  int signupFeePaisa,  List<String> branchIds,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MembershipPlan() when $default != null:
return $default(_that.id,_that.orgId,_that.name,_that.description,_that.planType,_that.durationDays,_that.sessionCount,_that.pricePaisa,_that.signupFeePaisa,_that.branchIds,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MembershipPlan implements MembershipPlan {
  const _MembershipPlan({required this.id, required this.orgId, required this.name, this.description, required this.planType, this.durationDays, this.sessionCount, required this.pricePaisa, required this.signupFeePaisa, required final  List<String> branchIds, required this.isActive, required this.sortOrder, required this.createdAt, required this.updatedAt}): _branchIds = branchIds;
  factory _MembershipPlan.fromJson(Map<String, dynamic> json) => _$MembershipPlanFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String name;
@override final  String? description;
@override final  PlanType planType;
@override final  int? durationDays;
@override final  int? sessionCount;
// Money is integer paisa end to end. Never a double, never converted here.
@override final  int pricePaisa;
@override final  int signupFeePaisa;
 final  List<String> _branchIds;
@override List<String> get branchIds {
  if (_branchIds is EqualUnmodifiableListView) return _branchIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branchIds);
}

@override final  bool isActive;
@override final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of MembershipPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipPlanCopyWith<_MembershipPlan> get copyWith => __$MembershipPlanCopyWithImpl<_MembershipPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.pricePaisa, pricePaisa) || other.pricePaisa == pricePaisa)&&(identical(other.signupFeePaisa, signupFeePaisa) || other.signupFeePaisa == signupFeePaisa)&&const DeepCollectionEquality().equals(other._branchIds, _branchIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,name,description,planType,durationDays,sessionCount,pricePaisa,signupFeePaisa,const DeepCollectionEquality().hash(_branchIds),isActive,sortOrder,createdAt,updatedAt);

@override
String toString() {
  return 'MembershipPlan(id: $id, orgId: $orgId, name: $name, description: $description, planType: $planType, durationDays: $durationDays, sessionCount: $sessionCount, pricePaisa: $pricePaisa, signupFeePaisa: $signupFeePaisa, branchIds: $branchIds, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MembershipPlanCopyWith<$Res> implements $MembershipPlanCopyWith<$Res> {
  factory _$MembershipPlanCopyWith(_MembershipPlan value, $Res Function(_MembershipPlan) _then) = __$MembershipPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String name, String? description, PlanType planType, int? durationDays, int? sessionCount, int pricePaisa, int signupFeePaisa, List<String> branchIds, bool isActive, int sortOrder, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$MembershipPlanCopyWithImpl<$Res>
    implements _$MembershipPlanCopyWith<$Res> {
  __$MembershipPlanCopyWithImpl(this._self, this._then);

  final _MembershipPlan _self;
  final $Res Function(_MembershipPlan) _then;

/// Create a copy of MembershipPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? name = null,Object? description = freezed,Object? planType = null,Object? durationDays = freezed,Object? sessionCount = freezed,Object? pricePaisa = null,Object? signupFeePaisa = null,Object? branchIds = null,Object? isActive = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MembershipPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as PlanType,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,sessionCount: freezed == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int?,pricePaisa: null == pricePaisa ? _self.pricePaisa : pricePaisa // ignore: cast_nullable_to_non_nullable
as int,signupFeePaisa: null == signupFeePaisa ? _self.signupFeePaisa : signupFeePaisa // ignore: cast_nullable_to_non_nullable
as int,branchIds: null == branchIds ? _self._branchIds : branchIds // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
