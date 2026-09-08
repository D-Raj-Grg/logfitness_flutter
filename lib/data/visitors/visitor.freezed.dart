// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visitor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Visitor {

 String get id; String get orgId;// The branch they walked into. Not nullable upstream: a walk-in happens
// somewhere, and it is what scopes who may write the row.
 String get branchId; VisitorKind get kind; String get fullName; String get phone;// `date`. Filled by the `set_visitor_defaults` trigger from the org's own
// today, and left editable so the desk can log yesterday's walk-in this
// morning.
@PlainDateConverter() DateTime get visitedOn; String? get note; String? get interestedPlanId; VisitorStatus get status; String? get convertedMemberId; DateTime? get convertedAt; String? get createdBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitorCopyWith<Visitor> get copyWith => _$VisitorCopyWithImpl<Visitor>(this as Visitor, _$identity);

  /// Serializes this Visitor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Visitor&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.visitedOn, visitedOn) || other.visitedOn == visitedOn)&&(identical(other.note, note) || other.note == note)&&(identical(other.interestedPlanId, interestedPlanId) || other.interestedPlanId == interestedPlanId)&&(identical(other.status, status) || other.status == status)&&(identical(other.convertedMemberId, convertedMemberId) || other.convertedMemberId == convertedMemberId)&&(identical(other.convertedAt, convertedAt) || other.convertedAt == convertedAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,branchId,kind,fullName,phone,visitedOn,note,interestedPlanId,status,convertedMemberId,convertedAt,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'Visitor(id: $id, orgId: $orgId, branchId: $branchId, kind: $kind, fullName: $fullName, phone: $phone, visitedOn: $visitedOn, note: $note, interestedPlanId: $interestedPlanId, status: $status, convertedMemberId: $convertedMemberId, convertedAt: $convertedAt, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $VisitorCopyWith<$Res>  {
  factory $VisitorCopyWith(Visitor value, $Res Function(Visitor) _then) = _$VisitorCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String branchId, VisitorKind kind, String fullName, String phone,@PlainDateConverter() DateTime visitedOn, String? note, String? interestedPlanId, VisitorStatus status, String? convertedMemberId, DateTime? convertedAt, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$VisitorCopyWithImpl<$Res>
    implements $VisitorCopyWith<$Res> {
  _$VisitorCopyWithImpl(this._self, this._then);

  final Visitor _self;
  final $Res Function(Visitor) _then;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? branchId = null,Object? kind = null,Object? fullName = null,Object? phone = null,Object? visitedOn = null,Object? note = freezed,Object? interestedPlanId = freezed,Object? status = null,Object? convertedMemberId = freezed,Object? convertedAt = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as VisitorKind,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,visitedOn: null == visitedOn ? _self.visitedOn : visitedOn // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,interestedPlanId: freezed == interestedPlanId ? _self.interestedPlanId : interestedPlanId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VisitorStatus,convertedMemberId: freezed == convertedMemberId ? _self.convertedMemberId : convertedMemberId // ignore: cast_nullable_to_non_nullable
as String?,convertedAt: freezed == convertedAt ? _self.convertedAt : convertedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Visitor].
extension VisitorPatterns on Visitor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Visitor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Visitor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Visitor value)  $default,){
final _that = this;
switch (_that) {
case _Visitor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Visitor value)?  $default,){
final _that = this;
switch (_that) {
case _Visitor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String branchId,  VisitorKind kind,  String fullName,  String phone, @PlainDateConverter()  DateTime visitedOn,  String? note,  String? interestedPlanId,  VisitorStatus status,  String? convertedMemberId,  DateTime? convertedAt,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Visitor() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.kind,_that.fullName,_that.phone,_that.visitedOn,_that.note,_that.interestedPlanId,_that.status,_that.convertedMemberId,_that.convertedAt,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String branchId,  VisitorKind kind,  String fullName,  String phone, @PlainDateConverter()  DateTime visitedOn,  String? note,  String? interestedPlanId,  VisitorStatus status,  String? convertedMemberId,  DateTime? convertedAt,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Visitor():
return $default(_that.id,_that.orgId,_that.branchId,_that.kind,_that.fullName,_that.phone,_that.visitedOn,_that.note,_that.interestedPlanId,_that.status,_that.convertedMemberId,_that.convertedAt,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String branchId,  VisitorKind kind,  String fullName,  String phone, @PlainDateConverter()  DateTime visitedOn,  String? note,  String? interestedPlanId,  VisitorStatus status,  String? convertedMemberId,  DateTime? convertedAt,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Visitor() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.kind,_that.fullName,_that.phone,_that.visitedOn,_that.note,_that.interestedPlanId,_that.status,_that.convertedMemberId,_that.convertedAt,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Visitor extends Visitor {
  const _Visitor({required this.id, required this.orgId, required this.branchId, required this.kind, required this.fullName, required this.phone, @PlainDateConverter() required this.visitedOn, this.note, this.interestedPlanId, required this.status, this.convertedMemberId, this.convertedAt, this.createdBy, required this.createdAt, required this.updatedAt}): super._();
  factory _Visitor.fromJson(Map<String, dynamic> json) => _$VisitorFromJson(json);

@override final  String id;
@override final  String orgId;
// The branch they walked into. Not nullable upstream: a walk-in happens
// somewhere, and it is what scopes who may write the row.
@override final  String branchId;
@override final  VisitorKind kind;
@override final  String fullName;
@override final  String phone;
// `date`. Filled by the `set_visitor_defaults` trigger from the org's own
// today, and left editable so the desk can log yesterday's walk-in this
// morning.
@override@PlainDateConverter() final  DateTime visitedOn;
@override final  String? note;
@override final  String? interestedPlanId;
@override final  VisitorStatus status;
@override final  String? convertedMemberId;
@override final  DateTime? convertedAt;
@override final  String? createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitorCopyWith<_Visitor> get copyWith => __$VisitorCopyWithImpl<_Visitor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisitorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Visitor&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.visitedOn, visitedOn) || other.visitedOn == visitedOn)&&(identical(other.note, note) || other.note == note)&&(identical(other.interestedPlanId, interestedPlanId) || other.interestedPlanId == interestedPlanId)&&(identical(other.status, status) || other.status == status)&&(identical(other.convertedMemberId, convertedMemberId) || other.convertedMemberId == convertedMemberId)&&(identical(other.convertedAt, convertedAt) || other.convertedAt == convertedAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,branchId,kind,fullName,phone,visitedOn,note,interestedPlanId,status,convertedMemberId,convertedAt,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'Visitor(id: $id, orgId: $orgId, branchId: $branchId, kind: $kind, fullName: $fullName, phone: $phone, visitedOn: $visitedOn, note: $note, interestedPlanId: $interestedPlanId, status: $status, convertedMemberId: $convertedMemberId, convertedAt: $convertedAt, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VisitorCopyWith<$Res> implements $VisitorCopyWith<$Res> {
  factory _$VisitorCopyWith(_Visitor value, $Res Function(_Visitor) _then) = __$VisitorCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String branchId, VisitorKind kind, String fullName, String phone,@PlainDateConverter() DateTime visitedOn, String? note, String? interestedPlanId, VisitorStatus status, String? convertedMemberId, DateTime? convertedAt, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$VisitorCopyWithImpl<$Res>
    implements _$VisitorCopyWith<$Res> {
  __$VisitorCopyWithImpl(this._self, this._then);

  final _Visitor _self;
  final $Res Function(_Visitor) _then;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? branchId = null,Object? kind = null,Object? fullName = null,Object? phone = null,Object? visitedOn = null,Object? note = freezed,Object? interestedPlanId = freezed,Object? status = null,Object? convertedMemberId = freezed,Object? convertedAt = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Visitor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as VisitorKind,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,visitedOn: null == visitedOn ? _self.visitedOn : visitedOn // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,interestedPlanId: freezed == interestedPlanId ? _self.interestedPlanId : interestedPlanId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VisitorStatus,convertedMemberId: freezed == convertedMemberId ? _self.convertedMemberId : convertedMemberId // ignore: cast_nullable_to_non_nullable
as String?,convertedAt: freezed == convertedAt ? _self.convertedAt : convertedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
