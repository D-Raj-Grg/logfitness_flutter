// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentMember {

 String get memberId; String get orgId; String get orgName; String get currency; String get timezone; String get homeBranchId; String get homeBranchName; String get memberCode; String get fullName;// members.email is nullable upstream; the RPC projects the column as-is.
 String? get email; String get phone; MemberStatus get status;
/// Create a copy of CurrentMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentMemberCopyWith<CurrentMember> get copyWith => _$CurrentMemberCopyWithImpl<CurrentMember>(this as CurrentMember, _$identity);

  /// Serializes this CurrentMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentMember&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.orgName, orgName) || other.orgName == orgName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.homeBranchName, homeBranchName) || other.homeBranchName == homeBranchName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,orgId,orgName,currency,timezone,homeBranchId,homeBranchName,memberCode,fullName,email,phone,status);

@override
String toString() {
  return 'CurrentMember(memberId: $memberId, orgId: $orgId, orgName: $orgName, currency: $currency, timezone: $timezone, homeBranchId: $homeBranchId, homeBranchName: $homeBranchName, memberCode: $memberCode, fullName: $fullName, email: $email, phone: $phone, status: $status)';
}


}

/// @nodoc
abstract mixin class $CurrentMemberCopyWith<$Res>  {
  factory $CurrentMemberCopyWith(CurrentMember value, $Res Function(CurrentMember) _then) = _$CurrentMemberCopyWithImpl;
@useResult
$Res call({
 String memberId, String orgId, String orgName, String currency, String timezone, String homeBranchId, String homeBranchName, String memberCode, String fullName, String? email, String phone, MemberStatus status
});




}
/// @nodoc
class _$CurrentMemberCopyWithImpl<$Res>
    implements $CurrentMemberCopyWith<$Res> {
  _$CurrentMemberCopyWithImpl(this._self, this._then);

  final CurrentMember _self;
  final $Res Function(CurrentMember) _then;

/// Create a copy of CurrentMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? orgId = null,Object? orgName = null,Object? currency = null,Object? timezone = null,Object? homeBranchId = null,Object? homeBranchName = null,Object? memberCode = null,Object? fullName = null,Object? email = freezed,Object? phone = null,Object? status = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,orgName: null == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,homeBranchName: null == homeBranchName ? _self.homeBranchName : homeBranchName // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentMember].
extension CurrentMemberPatterns on CurrentMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentMember value)  $default,){
final _that = this;
switch (_that) {
case _CurrentMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentMember value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String orgId,  String orgName,  String currency,  String timezone,  String homeBranchId,  String homeBranchName,  String memberCode,  String fullName,  String? email,  String phone,  MemberStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentMember() when $default != null:
return $default(_that.memberId,_that.orgId,_that.orgName,_that.currency,_that.timezone,_that.homeBranchId,_that.homeBranchName,_that.memberCode,_that.fullName,_that.email,_that.phone,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String orgId,  String orgName,  String currency,  String timezone,  String homeBranchId,  String homeBranchName,  String memberCode,  String fullName,  String? email,  String phone,  MemberStatus status)  $default,) {final _that = this;
switch (_that) {
case _CurrentMember():
return $default(_that.memberId,_that.orgId,_that.orgName,_that.currency,_that.timezone,_that.homeBranchId,_that.homeBranchName,_that.memberCode,_that.fullName,_that.email,_that.phone,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String orgId,  String orgName,  String currency,  String timezone,  String homeBranchId,  String homeBranchName,  String memberCode,  String fullName,  String? email,  String phone,  MemberStatus status)?  $default,) {final _that = this;
switch (_that) {
case _CurrentMember() when $default != null:
return $default(_that.memberId,_that.orgId,_that.orgName,_that.currency,_that.timezone,_that.homeBranchId,_that.homeBranchName,_that.memberCode,_that.fullName,_that.email,_that.phone,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CurrentMember implements CurrentMember {
  const _CurrentMember({required this.memberId, required this.orgId, required this.orgName, required this.currency, required this.timezone, required this.homeBranchId, required this.homeBranchName, required this.memberCode, required this.fullName, this.email, required this.phone, required this.status});
  factory _CurrentMember.fromJson(Map<String, dynamic> json) => _$CurrentMemberFromJson(json);

@override final  String memberId;
@override final  String orgId;
@override final  String orgName;
@override final  String currency;
@override final  String timezone;
@override final  String homeBranchId;
@override final  String homeBranchName;
@override final  String memberCode;
@override final  String fullName;
// members.email is nullable upstream; the RPC projects the column as-is.
@override final  String? email;
@override final  String phone;
@override final  MemberStatus status;

/// Create a copy of CurrentMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentMemberCopyWith<_CurrentMember> get copyWith => __$CurrentMemberCopyWithImpl<_CurrentMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentMember&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.orgName, orgName) || other.orgName == orgName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.homeBranchName, homeBranchName) || other.homeBranchName == homeBranchName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,orgId,orgName,currency,timezone,homeBranchId,homeBranchName,memberCode,fullName,email,phone,status);

@override
String toString() {
  return 'CurrentMember(memberId: $memberId, orgId: $orgId, orgName: $orgName, currency: $currency, timezone: $timezone, homeBranchId: $homeBranchId, homeBranchName: $homeBranchName, memberCode: $memberCode, fullName: $fullName, email: $email, phone: $phone, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CurrentMemberCopyWith<$Res> implements $CurrentMemberCopyWith<$Res> {
  factory _$CurrentMemberCopyWith(_CurrentMember value, $Res Function(_CurrentMember) _then) = __$CurrentMemberCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String orgId, String orgName, String currency, String timezone, String homeBranchId, String homeBranchName, String memberCode, String fullName, String? email, String phone, MemberStatus status
});




}
/// @nodoc
class __$CurrentMemberCopyWithImpl<$Res>
    implements _$CurrentMemberCopyWith<$Res> {
  __$CurrentMemberCopyWithImpl(this._self, this._then);

  final _CurrentMember _self;
  final $Res Function(_CurrentMember) _then;

/// Create a copy of CurrentMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? orgId = null,Object? orgName = null,Object? currency = null,Object? timezone = null,Object? homeBranchId = null,Object? homeBranchName = null,Object? memberCode = null,Object? fullName = null,Object? email = freezed,Object? phone = null,Object? status = null,}) {
  return _then(_CurrentMember(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,orgName: null == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,homeBranchName: null == homeBranchName ? _self.homeBranchName : homeBranchName // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,
  ));
}


}

// dart format on
