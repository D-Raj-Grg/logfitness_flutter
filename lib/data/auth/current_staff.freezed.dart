// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_staff.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentStaff {

 String get staffId; String get orgId; String get orgName; String get fullName; String get email; StaffRole get role; List<String> get branchIds;
/// Create a copy of CurrentStaff
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentStaffCopyWith<CurrentStaff> get copyWith => _$CurrentStaffCopyWithImpl<CurrentStaff>(this as CurrentStaff, _$identity);

  /// Serializes this CurrentStaff to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentStaff&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.orgName, orgName) || other.orgName == orgName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.branchIds, branchIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,staffId,orgId,orgName,fullName,email,role,const DeepCollectionEquality().hash(branchIds));

@override
String toString() {
  return 'CurrentStaff(staffId: $staffId, orgId: $orgId, orgName: $orgName, fullName: $fullName, email: $email, role: $role, branchIds: $branchIds)';
}


}

/// @nodoc
abstract mixin class $CurrentStaffCopyWith<$Res>  {
  factory $CurrentStaffCopyWith(CurrentStaff value, $Res Function(CurrentStaff) _then) = _$CurrentStaffCopyWithImpl;
@useResult
$Res call({
 String staffId, String orgId, String orgName, String fullName, String email, StaffRole role, List<String> branchIds
});




}
/// @nodoc
class _$CurrentStaffCopyWithImpl<$Res>
    implements $CurrentStaffCopyWith<$Res> {
  _$CurrentStaffCopyWithImpl(this._self, this._then);

  final CurrentStaff _self;
  final $Res Function(CurrentStaff) _then;

/// Create a copy of CurrentStaff
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? staffId = null,Object? orgId = null,Object? orgName = null,Object? fullName = null,Object? email = null,Object? role = null,Object? branchIds = null,}) {
  return _then(_self.copyWith(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,orgName: null == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,branchIds: null == branchIds ? _self.branchIds : branchIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentStaff].
extension CurrentStaffPatterns on CurrentStaff {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentStaff value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentStaff() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentStaff value)  $default,){
final _that = this;
switch (_that) {
case _CurrentStaff():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentStaff value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentStaff() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String staffId,  String orgId,  String orgName,  String fullName,  String email,  StaffRole role,  List<String> branchIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentStaff() when $default != null:
return $default(_that.staffId,_that.orgId,_that.orgName,_that.fullName,_that.email,_that.role,_that.branchIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String staffId,  String orgId,  String orgName,  String fullName,  String email,  StaffRole role,  List<String> branchIds)  $default,) {final _that = this;
switch (_that) {
case _CurrentStaff():
return $default(_that.staffId,_that.orgId,_that.orgName,_that.fullName,_that.email,_that.role,_that.branchIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String staffId,  String orgId,  String orgName,  String fullName,  String email,  StaffRole role,  List<String> branchIds)?  $default,) {final _that = this;
switch (_that) {
case _CurrentStaff() when $default != null:
return $default(_that.staffId,_that.orgId,_that.orgName,_that.fullName,_that.email,_that.role,_that.branchIds);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CurrentStaff implements CurrentStaff {
  const _CurrentStaff({required this.staffId, required this.orgId, required this.orgName, required this.fullName, required this.email, required this.role, required final  List<String> branchIds}): _branchIds = branchIds;
  factory _CurrentStaff.fromJson(Map<String, dynamic> json) => _$CurrentStaffFromJson(json);

@override final  String staffId;
@override final  String orgId;
@override final  String orgName;
@override final  String fullName;
@override final  String email;
@override final  StaffRole role;
 final  List<String> _branchIds;
@override List<String> get branchIds {
  if (_branchIds is EqualUnmodifiableListView) return _branchIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branchIds);
}


/// Create a copy of CurrentStaff
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentStaffCopyWith<_CurrentStaff> get copyWith => __$CurrentStaffCopyWithImpl<_CurrentStaff>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentStaffToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentStaff&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.orgName, orgName) || other.orgName == orgName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other._branchIds, _branchIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,staffId,orgId,orgName,fullName,email,role,const DeepCollectionEquality().hash(_branchIds));

@override
String toString() {
  return 'CurrentStaff(staffId: $staffId, orgId: $orgId, orgName: $orgName, fullName: $fullName, email: $email, role: $role, branchIds: $branchIds)';
}


}

/// @nodoc
abstract mixin class _$CurrentStaffCopyWith<$Res> implements $CurrentStaffCopyWith<$Res> {
  factory _$CurrentStaffCopyWith(_CurrentStaff value, $Res Function(_CurrentStaff) _then) = __$CurrentStaffCopyWithImpl;
@override @useResult
$Res call({
 String staffId, String orgId, String orgName, String fullName, String email, StaffRole role, List<String> branchIds
});




}
/// @nodoc
class __$CurrentStaffCopyWithImpl<$Res>
    implements _$CurrentStaffCopyWith<$Res> {
  __$CurrentStaffCopyWithImpl(this._self, this._then);

  final _CurrentStaff _self;
  final $Res Function(_CurrentStaff) _then;

/// Create a copy of CurrentStaff
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? staffId = null,Object? orgId = null,Object? orgName = null,Object? fullName = null,Object? email = null,Object? role = null,Object? branchIds = null,}) {
  return _then(_CurrentStaff(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,orgName: null == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,branchIds: null == branchIds ? _self._branchIds : branchIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
