// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_rpc_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInMemberSummary {

 String get id; String get fullName; String? get memberCode; String? get phone; String? get photoPath; MemberStatus? get status;
/// Create a copy of CheckInMemberSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInMemberSummaryCopyWith<CheckInMemberSummary> get copyWith => _$CheckInMemberSummaryCopyWithImpl<CheckInMemberSummary>(this as CheckInMemberSummary, _$identity);

  /// Serializes this CheckInMemberSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInMemberSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,memberCode,phone,photoPath,status);

@override
String toString() {
  return 'CheckInMemberSummary(id: $id, fullName: $fullName, memberCode: $memberCode, phone: $phone, photoPath: $photoPath, status: $status)';
}


}

/// @nodoc
abstract mixin class $CheckInMemberSummaryCopyWith<$Res>  {
  factory $CheckInMemberSummaryCopyWith(CheckInMemberSummary value, $Res Function(CheckInMemberSummary) _then) = _$CheckInMemberSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? memberCode, String? phone, String? photoPath, MemberStatus? status
});




}
/// @nodoc
class _$CheckInMemberSummaryCopyWithImpl<$Res>
    implements $CheckInMemberSummaryCopyWith<$Res> {
  _$CheckInMemberSummaryCopyWithImpl(this._self, this._then);

  final CheckInMemberSummary _self;
  final $Res Function(CheckInMemberSummary) _then;

/// Create a copy of CheckInMemberSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? memberCode = freezed,Object? phone = freezed,Object? photoPath = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInMemberSummary].
extension CheckInMemberSummaryPatterns on CheckInMemberSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInMemberSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInMemberSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInMemberSummary value)  $default,){
final _that = this;
switch (_that) {
case _CheckInMemberSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInMemberSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInMemberSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? memberCode,  String? phone,  String? photoPath,  MemberStatus? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInMemberSummary() when $default != null:
return $default(_that.id,_that.fullName,_that.memberCode,_that.phone,_that.photoPath,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? memberCode,  String? phone,  String? photoPath,  MemberStatus? status)  $default,) {final _that = this;
switch (_that) {
case _CheckInMemberSummary():
return $default(_that.id,_that.fullName,_that.memberCode,_that.phone,_that.photoPath,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? memberCode,  String? phone,  String? photoPath,  MemberStatus? status)?  $default,) {final _that = this;
switch (_that) {
case _CheckInMemberSummary() when $default != null:
return $default(_that.id,_that.fullName,_that.memberCode,_that.phone,_that.photoPath,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CheckInMemberSummary implements CheckInMemberSummary {
  const _CheckInMemberSummary({required this.id, required this.fullName, this.memberCode, this.phone, this.photoPath, this.status});
  factory _CheckInMemberSummary.fromJson(Map<String, dynamic> json) => _$CheckInMemberSummaryFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String? memberCode;
@override final  String? phone;
@override final  String? photoPath;
@override final  MemberStatus? status;

/// Create a copy of CheckInMemberSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInMemberSummaryCopyWith<_CheckInMemberSummary> get copyWith => __$CheckInMemberSummaryCopyWithImpl<_CheckInMemberSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInMemberSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInMemberSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,memberCode,phone,photoPath,status);

@override
String toString() {
  return 'CheckInMemberSummary(id: $id, fullName: $fullName, memberCode: $memberCode, phone: $phone, photoPath: $photoPath, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CheckInMemberSummaryCopyWith<$Res> implements $CheckInMemberSummaryCopyWith<$Res> {
  factory _$CheckInMemberSummaryCopyWith(_CheckInMemberSummary value, $Res Function(_CheckInMemberSummary) _then) = __$CheckInMemberSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? memberCode, String? phone, String? photoPath, MemberStatus? status
});




}
/// @nodoc
class __$CheckInMemberSummaryCopyWithImpl<$Res>
    implements _$CheckInMemberSummaryCopyWith<$Res> {
  __$CheckInMemberSummaryCopyWithImpl(this._self, this._then);

  final _CheckInMemberSummary _self;
  final $Res Function(_CheckInMemberSummary) _then;

/// Create a copy of CheckInMemberSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? memberCode = freezed,Object? phone = freezed,Object? photoPath = freezed,Object? status = freezed,}) {
  return _then(_CheckInMemberSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus?,
  ));
}


}


/// @nodoc
mixin _$CheckInBranchSummary {

 String get id; String get name;
/// Create a copy of CheckInBranchSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInBranchSummaryCopyWith<CheckInBranchSummary> get copyWith => _$CheckInBranchSummaryCopyWithImpl<CheckInBranchSummary>(this as CheckInBranchSummary, _$identity);

  /// Serializes this CheckInBranchSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInBranchSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CheckInBranchSummary(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $CheckInBranchSummaryCopyWith<$Res>  {
  factory $CheckInBranchSummaryCopyWith(CheckInBranchSummary value, $Res Function(CheckInBranchSummary) _then) = _$CheckInBranchSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$CheckInBranchSummaryCopyWithImpl<$Res>
    implements $CheckInBranchSummaryCopyWith<$Res> {
  _$CheckInBranchSummaryCopyWithImpl(this._self, this._then);

  final CheckInBranchSummary _self;
  final $Res Function(CheckInBranchSummary) _then;

/// Create a copy of CheckInBranchSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInBranchSummary].
extension CheckInBranchSummaryPatterns on CheckInBranchSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInBranchSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInBranchSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInBranchSummary value)  $default,){
final _that = this;
switch (_that) {
case _CheckInBranchSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInBranchSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInBranchSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInBranchSummary() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _CheckInBranchSummary():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _CheckInBranchSummary() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CheckInBranchSummary implements CheckInBranchSummary {
  const _CheckInBranchSummary({required this.id, required this.name});
  factory _CheckInBranchSummary.fromJson(Map<String, dynamic> json) => _$CheckInBranchSummaryFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of CheckInBranchSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInBranchSummaryCopyWith<_CheckInBranchSummary> get copyWith => __$CheckInBranchSummaryCopyWithImpl<_CheckInBranchSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInBranchSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInBranchSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CheckInBranchSummary(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CheckInBranchSummaryCopyWith<$Res> implements $CheckInBranchSummaryCopyWith<$Res> {
  factory _$CheckInBranchSummaryCopyWith(_CheckInBranchSummary value, $Res Function(_CheckInBranchSummary) _then) = __$CheckInBranchSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$CheckInBranchSummaryCopyWithImpl<$Res>
    implements _$CheckInBranchSummaryCopyWith<$Res> {
  __$CheckInBranchSummaryCopyWithImpl(this._self, this._then);

  final _CheckInBranchSummary _self;
  final $Res Function(_CheckInBranchSummary) _then;

/// Create a copy of CheckInBranchSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_CheckInBranchSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CheckInResult {

 bool get ok; CheckInRefusal? get reason; CheckInBanner? get banner; CheckInMemberSummary? get member; CheckInBranchSummary? get branch;// Money is integer paisa end to end.
 int get duePaisa;
/// Create a copy of CheckInResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInResultCopyWith<CheckInResult> get copyWith => _$CheckInResultCopyWithImpl<CheckInResult>(this as CheckInResult, _$identity);

  /// Serializes this CheckInResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInResult&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.member, member) || other.member == member)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,reason,banner,member,branch,duePaisa);

@override
String toString() {
  return 'CheckInResult(ok: $ok, reason: $reason, banner: $banner, member: $member, branch: $branch, duePaisa: $duePaisa)';
}


}

/// @nodoc
abstract mixin class $CheckInResultCopyWith<$Res>  {
  factory $CheckInResultCopyWith(CheckInResult value, $Res Function(CheckInResult) _then) = _$CheckInResultCopyWithImpl;
@useResult
$Res call({
 bool ok, CheckInRefusal? reason, CheckInBanner? banner, CheckInMemberSummary? member, CheckInBranchSummary? branch, int duePaisa
});


$CheckInMemberSummaryCopyWith<$Res>? get member;$CheckInBranchSummaryCopyWith<$Res>? get branch;

}
/// @nodoc
class _$CheckInResultCopyWithImpl<$Res>
    implements $CheckInResultCopyWith<$Res> {
  _$CheckInResultCopyWithImpl(this._self, this._then);

  final CheckInResult _self;
  final $Res Function(CheckInResult) _then;

/// Create a copy of CheckInResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? reason = freezed,Object? banner = freezed,Object? member = freezed,Object? branch = freezed,Object? duePaisa = null,}) {
  return _then(_self.copyWith(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as CheckInRefusal?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as CheckInBanner?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as CheckInMemberSummary?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as CheckInBranchSummary?,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of CheckInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckInMemberSummaryCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $CheckInMemberSummaryCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}/// Create a copy of CheckInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckInBranchSummaryCopyWith<$Res>? get branch {
    if (_self.branch == null) {
    return null;
  }

  return $CheckInBranchSummaryCopyWith<$Res>(_self.branch!, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckInResult].
extension CheckInResultPatterns on CheckInResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInResult value)  $default,){
final _that = this;
switch (_that) {
case _CheckInResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInResult value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool ok,  CheckInRefusal? reason,  CheckInBanner? banner,  CheckInMemberSummary? member,  CheckInBranchSummary? branch,  int duePaisa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInResult() when $default != null:
return $default(_that.ok,_that.reason,_that.banner,_that.member,_that.branch,_that.duePaisa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool ok,  CheckInRefusal? reason,  CheckInBanner? banner,  CheckInMemberSummary? member,  CheckInBranchSummary? branch,  int duePaisa)  $default,) {final _that = this;
switch (_that) {
case _CheckInResult():
return $default(_that.ok,_that.reason,_that.banner,_that.member,_that.branch,_that.duePaisa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool ok,  CheckInRefusal? reason,  CheckInBanner? banner,  CheckInMemberSummary? member,  CheckInBranchSummary? branch,  int duePaisa)?  $default,) {final _that = this;
switch (_that) {
case _CheckInResult() when $default != null:
return $default(_that.ok,_that.reason,_that.banner,_that.member,_that.branch,_that.duePaisa);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CheckInResult extends CheckInResult {
  const _CheckInResult({required this.ok, this.reason, this.banner, this.member, this.branch, this.duePaisa = 0}): super._();
  factory _CheckInResult.fromJson(Map<String, dynamic> json) => _$CheckInResultFromJson(json);

@override final  bool ok;
@override final  CheckInRefusal? reason;
@override final  CheckInBanner? banner;
@override final  CheckInMemberSummary? member;
@override final  CheckInBranchSummary? branch;
// Money is integer paisa end to end.
@override@JsonKey() final  int duePaisa;

/// Create a copy of CheckInResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInResultCopyWith<_CheckInResult> get copyWith => __$CheckInResultCopyWithImpl<_CheckInResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInResult&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.member, member) || other.member == member)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ok,reason,banner,member,branch,duePaisa);

@override
String toString() {
  return 'CheckInResult(ok: $ok, reason: $reason, banner: $banner, member: $member, branch: $branch, duePaisa: $duePaisa)';
}


}

/// @nodoc
abstract mixin class _$CheckInResultCopyWith<$Res> implements $CheckInResultCopyWith<$Res> {
  factory _$CheckInResultCopyWith(_CheckInResult value, $Res Function(_CheckInResult) _then) = __$CheckInResultCopyWithImpl;
@override @useResult
$Res call({
 bool ok, CheckInRefusal? reason, CheckInBanner? banner, CheckInMemberSummary? member, CheckInBranchSummary? branch, int duePaisa
});


@override $CheckInMemberSummaryCopyWith<$Res>? get member;@override $CheckInBranchSummaryCopyWith<$Res>? get branch;

}
/// @nodoc
class __$CheckInResultCopyWithImpl<$Res>
    implements _$CheckInResultCopyWith<$Res> {
  __$CheckInResultCopyWithImpl(this._self, this._then);

  final _CheckInResult _self;
  final $Res Function(_CheckInResult) _then;

/// Create a copy of CheckInResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? reason = freezed,Object? banner = freezed,Object? member = freezed,Object? branch = freezed,Object? duePaisa = null,}) {
  return _then(_CheckInResult(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as CheckInRefusal?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as CheckInBanner?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as CheckInMemberSummary?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as CheckInBranchSummary?,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of CheckInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckInMemberSummaryCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $CheckInMemberSummaryCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}/// Create a copy of CheckInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckInBranchSummaryCopyWith<$Res>? get branch {
    if (_self.branch == null) {
    return null;
  }

  return $CheckInBranchSummaryCopyWith<$Res>(_self.branch!, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}

// dart format on
