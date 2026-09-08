// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_rpc_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RenewMembershipResult {

 String get membershipId; String get invoiceId; String get invoiceNo;/// Null when the sale took no money. An invoice with a due and no payment
/// row is a legitimate outcome, not a failure.
 String? get paymentId;@PlainDateConverter() DateTime get startDate;/// Null for a session pack with no validity window.
@NullablePlainDateConverter() DateTime? get endDate;// Money is integer paisa end to end.
 int get totalPaisa;/// `(subtotal - discount) - amount_paid`, computed inside the function.
/// Read it rather than recomputing: the subtotal includes the joining fee
/// the RPC decided to charge, which the caller does not know.
 int get duePaisa;
/// Create a copy of RenewMembershipResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RenewMembershipResultCopyWith<RenewMembershipResult> get copyWith => _$RenewMembershipResultCopyWithImpl<RenewMembershipResult>(this as RenewMembershipResult, _$identity);

  /// Serializes this RenewMembershipResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RenewMembershipResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalPaisa, totalPaisa) || other.totalPaisa == totalPaisa)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,invoiceId,invoiceNo,paymentId,startDate,endDate,totalPaisa,duePaisa);

@override
String toString() {
  return 'RenewMembershipResult(membershipId: $membershipId, invoiceId: $invoiceId, invoiceNo: $invoiceNo, paymentId: $paymentId, startDate: $startDate, endDate: $endDate, totalPaisa: $totalPaisa, duePaisa: $duePaisa)';
}


}

/// @nodoc
abstract mixin class $RenewMembershipResultCopyWith<$Res>  {
  factory $RenewMembershipResultCopyWith(RenewMembershipResult value, $Res Function(RenewMembershipResult) _then) = _$RenewMembershipResultCopyWithImpl;
@useResult
$Res call({
 String membershipId, String invoiceId, String invoiceNo, String? paymentId,@PlainDateConverter() DateTime startDate,@NullablePlainDateConverter() DateTime? endDate, int totalPaisa, int duePaisa
});




}
/// @nodoc
class _$RenewMembershipResultCopyWithImpl<$Res>
    implements $RenewMembershipResultCopyWith<$Res> {
  _$RenewMembershipResultCopyWithImpl(this._self, this._then);

  final RenewMembershipResult _self;
  final $Res Function(RenewMembershipResult) _then;

/// Create a copy of RenewMembershipResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? membershipId = null,Object? invoiceId = null,Object? invoiceNo = null,Object? paymentId = freezed,Object? startDate = null,Object? endDate = freezed,Object? totalPaisa = null,Object? duePaisa = null,}) {
  return _then(_self.copyWith(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,invoiceNo: null == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalPaisa: null == totalPaisa ? _self.totalPaisa : totalPaisa // ignore: cast_nullable_to_non_nullable
as int,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RenewMembershipResult].
extension RenewMembershipResultPatterns on RenewMembershipResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RenewMembershipResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RenewMembershipResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RenewMembershipResult value)  $default,){
final _that = this;
switch (_that) {
case _RenewMembershipResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RenewMembershipResult value)?  $default,){
final _that = this;
switch (_that) {
case _RenewMembershipResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String membershipId,  String invoiceId,  String invoiceNo,  String? paymentId, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int totalPaisa,  int duePaisa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RenewMembershipResult() when $default != null:
return $default(_that.membershipId,_that.invoiceId,_that.invoiceNo,_that.paymentId,_that.startDate,_that.endDate,_that.totalPaisa,_that.duePaisa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String membershipId,  String invoiceId,  String invoiceNo,  String? paymentId, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int totalPaisa,  int duePaisa)  $default,) {final _that = this;
switch (_that) {
case _RenewMembershipResult():
return $default(_that.membershipId,_that.invoiceId,_that.invoiceNo,_that.paymentId,_that.startDate,_that.endDate,_that.totalPaisa,_that.duePaisa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String membershipId,  String invoiceId,  String invoiceNo,  String? paymentId, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int totalPaisa,  int duePaisa)?  $default,) {final _that = this;
switch (_that) {
case _RenewMembershipResult() when $default != null:
return $default(_that.membershipId,_that.invoiceId,_that.invoiceNo,_that.paymentId,_that.startDate,_that.endDate,_that.totalPaisa,_that.duePaisa);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RenewMembershipResult implements RenewMembershipResult {
  const _RenewMembershipResult({required this.membershipId, required this.invoiceId, required this.invoiceNo, this.paymentId, @PlainDateConverter() required this.startDate, @NullablePlainDateConverter() this.endDate, required this.totalPaisa, required this.duePaisa});
  factory _RenewMembershipResult.fromJson(Map<String, dynamic> json) => _$RenewMembershipResultFromJson(json);

@override final  String membershipId;
@override final  String invoiceId;
@override final  String invoiceNo;
/// Null when the sale took no money. An invoice with a due and no payment
/// row is a legitimate outcome, not a failure.
@override final  String? paymentId;
@override@PlainDateConverter() final  DateTime startDate;
/// Null for a session pack with no validity window.
@override@NullablePlainDateConverter() final  DateTime? endDate;
// Money is integer paisa end to end.
@override final  int totalPaisa;
/// `(subtotal - discount) - amount_paid`, computed inside the function.
/// Read it rather than recomputing: the subtotal includes the joining fee
/// the RPC decided to charge, which the caller does not know.
@override final  int duePaisa;

/// Create a copy of RenewMembershipResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RenewMembershipResultCopyWith<_RenewMembershipResult> get copyWith => __$RenewMembershipResultCopyWithImpl<_RenewMembershipResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RenewMembershipResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RenewMembershipResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalPaisa, totalPaisa) || other.totalPaisa == totalPaisa)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,invoiceId,invoiceNo,paymentId,startDate,endDate,totalPaisa,duePaisa);

@override
String toString() {
  return 'RenewMembershipResult(membershipId: $membershipId, invoiceId: $invoiceId, invoiceNo: $invoiceNo, paymentId: $paymentId, startDate: $startDate, endDate: $endDate, totalPaisa: $totalPaisa, duePaisa: $duePaisa)';
}


}

/// @nodoc
abstract mixin class _$RenewMembershipResultCopyWith<$Res> implements $RenewMembershipResultCopyWith<$Res> {
  factory _$RenewMembershipResultCopyWith(_RenewMembershipResult value, $Res Function(_RenewMembershipResult) _then) = __$RenewMembershipResultCopyWithImpl;
@override @useResult
$Res call({
 String membershipId, String invoiceId, String invoiceNo, String? paymentId,@PlainDateConverter() DateTime startDate,@NullablePlainDateConverter() DateTime? endDate, int totalPaisa, int duePaisa
});




}
/// @nodoc
class __$RenewMembershipResultCopyWithImpl<$Res>
    implements _$RenewMembershipResultCopyWith<$Res> {
  __$RenewMembershipResultCopyWithImpl(this._self, this._then);

  final _RenewMembershipResult _self;
  final $Res Function(_RenewMembershipResult) _then;

/// Create a copy of RenewMembershipResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? membershipId = null,Object? invoiceId = null,Object? invoiceNo = null,Object? paymentId = freezed,Object? startDate = null,Object? endDate = freezed,Object? totalPaisa = null,Object? duePaisa = null,}) {
  return _then(_RenewMembershipResult(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,invoiceNo: null == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalPaisa: null == totalPaisa ? _self.totalPaisa : totalPaisa // ignore: cast_nullable_to_non_nullable
as int,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FreezeMembershipResult {

 String get membershipId;/// `org_today(org_id)`, not the device's today. A `date`.
@PlainDateConverter() DateTime get frozenOn;
/// Create a copy of FreezeMembershipResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FreezeMembershipResultCopyWith<FreezeMembershipResult> get copyWith => _$FreezeMembershipResultCopyWithImpl<FreezeMembershipResult>(this as FreezeMembershipResult, _$identity);

  /// Serializes this FreezeMembershipResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FreezeMembershipResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.frozenOn, frozenOn) || other.frozenOn == frozenOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,frozenOn);

@override
String toString() {
  return 'FreezeMembershipResult(membershipId: $membershipId, frozenOn: $frozenOn)';
}


}

/// @nodoc
abstract mixin class $FreezeMembershipResultCopyWith<$Res>  {
  factory $FreezeMembershipResultCopyWith(FreezeMembershipResult value, $Res Function(FreezeMembershipResult) _then) = _$FreezeMembershipResultCopyWithImpl;
@useResult
$Res call({
 String membershipId,@PlainDateConverter() DateTime frozenOn
});




}
/// @nodoc
class _$FreezeMembershipResultCopyWithImpl<$Res>
    implements $FreezeMembershipResultCopyWith<$Res> {
  _$FreezeMembershipResultCopyWithImpl(this._self, this._then);

  final FreezeMembershipResult _self;
  final $Res Function(FreezeMembershipResult) _then;

/// Create a copy of FreezeMembershipResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? membershipId = null,Object? frozenOn = null,}) {
  return _then(_self.copyWith(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,frozenOn: null == frozenOn ? _self.frozenOn : frozenOn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FreezeMembershipResult].
extension FreezeMembershipResultPatterns on FreezeMembershipResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FreezeMembershipResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FreezeMembershipResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FreezeMembershipResult value)  $default,){
final _that = this;
switch (_that) {
case _FreezeMembershipResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FreezeMembershipResult value)?  $default,){
final _that = this;
switch (_that) {
case _FreezeMembershipResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String membershipId, @PlainDateConverter()  DateTime frozenOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FreezeMembershipResult() when $default != null:
return $default(_that.membershipId,_that.frozenOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String membershipId, @PlainDateConverter()  DateTime frozenOn)  $default,) {final _that = this;
switch (_that) {
case _FreezeMembershipResult():
return $default(_that.membershipId,_that.frozenOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String membershipId, @PlainDateConverter()  DateTime frozenOn)?  $default,) {final _that = this;
switch (_that) {
case _FreezeMembershipResult() when $default != null:
return $default(_that.membershipId,_that.frozenOn);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _FreezeMembershipResult implements FreezeMembershipResult {
  const _FreezeMembershipResult({required this.membershipId, @PlainDateConverter() required this.frozenOn});
  factory _FreezeMembershipResult.fromJson(Map<String, dynamic> json) => _$FreezeMembershipResultFromJson(json);

@override final  String membershipId;
/// `org_today(org_id)`, not the device's today. A `date`.
@override@PlainDateConverter() final  DateTime frozenOn;

/// Create a copy of FreezeMembershipResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FreezeMembershipResultCopyWith<_FreezeMembershipResult> get copyWith => __$FreezeMembershipResultCopyWithImpl<_FreezeMembershipResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FreezeMembershipResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FreezeMembershipResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.frozenOn, frozenOn) || other.frozenOn == frozenOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,frozenOn);

@override
String toString() {
  return 'FreezeMembershipResult(membershipId: $membershipId, frozenOn: $frozenOn)';
}


}

/// @nodoc
abstract mixin class _$FreezeMembershipResultCopyWith<$Res> implements $FreezeMembershipResultCopyWith<$Res> {
  factory _$FreezeMembershipResultCopyWith(_FreezeMembershipResult value, $Res Function(_FreezeMembershipResult) _then) = __$FreezeMembershipResultCopyWithImpl;
@override @useResult
$Res call({
 String membershipId,@PlainDateConverter() DateTime frozenOn
});




}
/// @nodoc
class __$FreezeMembershipResultCopyWithImpl<$Res>
    implements _$FreezeMembershipResultCopyWith<$Res> {
  __$FreezeMembershipResultCopyWithImpl(this._self, this._then);

  final _FreezeMembershipResult _self;
  final $Res Function(_FreezeMembershipResult) _then;

/// Create a copy of FreezeMembershipResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? membershipId = null,Object? frozenOn = null,}) {
  return _then(_FreezeMembershipResult(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,frozenOn: null == frozenOn ? _self.frozenOn : frozenOn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UnfreezeMembershipResult {

 String get membershipId;/// How many days the freeze actually lasted, and therefore how far the
/// end date just moved. The function computes it from `org_today`, so it
/// is the only trustworthy source for it.
 int get pausedDays;@NullablePlainDateConverter() DateTime? get endDate;
/// Create a copy of UnfreezeMembershipResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnfreezeMembershipResultCopyWith<UnfreezeMembershipResult> get copyWith => _$UnfreezeMembershipResultCopyWithImpl<UnfreezeMembershipResult>(this as UnfreezeMembershipResult, _$identity);

  /// Serializes this UnfreezeMembershipResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnfreezeMembershipResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.pausedDays, pausedDays) || other.pausedDays == pausedDays)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,pausedDays,endDate);

@override
String toString() {
  return 'UnfreezeMembershipResult(membershipId: $membershipId, pausedDays: $pausedDays, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $UnfreezeMembershipResultCopyWith<$Res>  {
  factory $UnfreezeMembershipResultCopyWith(UnfreezeMembershipResult value, $Res Function(UnfreezeMembershipResult) _then) = _$UnfreezeMembershipResultCopyWithImpl;
@useResult
$Res call({
 String membershipId, int pausedDays,@NullablePlainDateConverter() DateTime? endDate
});




}
/// @nodoc
class _$UnfreezeMembershipResultCopyWithImpl<$Res>
    implements $UnfreezeMembershipResultCopyWith<$Res> {
  _$UnfreezeMembershipResultCopyWithImpl(this._self, this._then);

  final UnfreezeMembershipResult _self;
  final $Res Function(UnfreezeMembershipResult) _then;

/// Create a copy of UnfreezeMembershipResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? membershipId = null,Object? pausedDays = null,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,pausedDays: null == pausedDays ? _self.pausedDays : pausedDays // ignore: cast_nullable_to_non_nullable
as int,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UnfreezeMembershipResult].
extension UnfreezeMembershipResultPatterns on UnfreezeMembershipResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnfreezeMembershipResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnfreezeMembershipResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnfreezeMembershipResult value)  $default,){
final _that = this;
switch (_that) {
case _UnfreezeMembershipResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnfreezeMembershipResult value)?  $default,){
final _that = this;
switch (_that) {
case _UnfreezeMembershipResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String membershipId,  int pausedDays, @NullablePlainDateConverter()  DateTime? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnfreezeMembershipResult() when $default != null:
return $default(_that.membershipId,_that.pausedDays,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String membershipId,  int pausedDays, @NullablePlainDateConverter()  DateTime? endDate)  $default,) {final _that = this;
switch (_that) {
case _UnfreezeMembershipResult():
return $default(_that.membershipId,_that.pausedDays,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String membershipId,  int pausedDays, @NullablePlainDateConverter()  DateTime? endDate)?  $default,) {final _that = this;
switch (_that) {
case _UnfreezeMembershipResult() when $default != null:
return $default(_that.membershipId,_that.pausedDays,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UnfreezeMembershipResult implements UnfreezeMembershipResult {
  const _UnfreezeMembershipResult({required this.membershipId, required this.pausedDays, @NullablePlainDateConverter() this.endDate});
  factory _UnfreezeMembershipResult.fromJson(Map<String, dynamic> json) => _$UnfreezeMembershipResultFromJson(json);

@override final  String membershipId;
/// How many days the freeze actually lasted, and therefore how far the
/// end date just moved. The function computes it from `org_today`, so it
/// is the only trustworthy source for it.
@override final  int pausedDays;
@override@NullablePlainDateConverter() final  DateTime? endDate;

/// Create a copy of UnfreezeMembershipResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnfreezeMembershipResultCopyWith<_UnfreezeMembershipResult> get copyWith => __$UnfreezeMembershipResultCopyWithImpl<_UnfreezeMembershipResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnfreezeMembershipResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnfreezeMembershipResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.pausedDays, pausedDays) || other.pausedDays == pausedDays)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,pausedDays,endDate);

@override
String toString() {
  return 'UnfreezeMembershipResult(membershipId: $membershipId, pausedDays: $pausedDays, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$UnfreezeMembershipResultCopyWith<$Res> implements $UnfreezeMembershipResultCopyWith<$Res> {
  factory _$UnfreezeMembershipResultCopyWith(_UnfreezeMembershipResult value, $Res Function(_UnfreezeMembershipResult) _then) = __$UnfreezeMembershipResultCopyWithImpl;
@override @useResult
$Res call({
 String membershipId, int pausedDays,@NullablePlainDateConverter() DateTime? endDate
});




}
/// @nodoc
class __$UnfreezeMembershipResultCopyWithImpl<$Res>
    implements _$UnfreezeMembershipResultCopyWith<$Res> {
  __$UnfreezeMembershipResultCopyWithImpl(this._self, this._then);

  final _UnfreezeMembershipResult _self;
  final $Res Function(_UnfreezeMembershipResult) _then;

/// Create a copy of UnfreezeMembershipResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? membershipId = null,Object? pausedDays = null,Object? endDate = freezed,}) {
  return _then(_UnfreezeMembershipResult(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,pausedDays: null == pausedDays ? _self.pausedDays : pausedDays // ignore: cast_nullable_to_non_nullable
as int,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MembershipStatusResult {

 String get membershipId; MembershipStatus get status;
/// Create a copy of MembershipStatusResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipStatusResultCopyWith<MembershipStatusResult> get copyWith => _$MembershipStatusResultCopyWithImpl<MembershipStatusResult>(this as MembershipStatusResult, _$identity);

  /// Serializes this MembershipStatusResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipStatusResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,status);

@override
String toString() {
  return 'MembershipStatusResult(membershipId: $membershipId, status: $status)';
}


}

/// @nodoc
abstract mixin class $MembershipStatusResultCopyWith<$Res>  {
  factory $MembershipStatusResultCopyWith(MembershipStatusResult value, $Res Function(MembershipStatusResult) _then) = _$MembershipStatusResultCopyWithImpl;
@useResult
$Res call({
 String membershipId, MembershipStatus status
});




}
/// @nodoc
class _$MembershipStatusResultCopyWithImpl<$Res>
    implements $MembershipStatusResultCopyWith<$Res> {
  _$MembershipStatusResultCopyWithImpl(this._self, this._then);

  final MembershipStatusResult _self;
  final $Res Function(MembershipStatusResult) _then;

/// Create a copy of MembershipStatusResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? membershipId = null,Object? status = null,}) {
  return _then(_self.copyWith(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipStatusResult].
extension MembershipStatusResultPatterns on MembershipStatusResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipStatusResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipStatusResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipStatusResult value)  $default,){
final _that = this;
switch (_that) {
case _MembershipStatusResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipStatusResult value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipStatusResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String membershipId,  MembershipStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipStatusResult() when $default != null:
return $default(_that.membershipId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String membershipId,  MembershipStatus status)  $default,) {final _that = this;
switch (_that) {
case _MembershipStatusResult():
return $default(_that.membershipId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String membershipId,  MembershipStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MembershipStatusResult() when $default != null:
return $default(_that.membershipId,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MembershipStatusResult implements MembershipStatusResult {
  const _MembershipStatusResult({required this.membershipId, required this.status});
  factory _MembershipStatusResult.fromJson(Map<String, dynamic> json) => _$MembershipStatusResultFromJson(json);

@override final  String membershipId;
@override final  MembershipStatus status;

/// Create a copy of MembershipStatusResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipStatusResultCopyWith<_MembershipStatusResult> get copyWith => __$MembershipStatusResultCopyWithImpl<_MembershipStatusResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipStatusResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipStatusResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,status);

@override
String toString() {
  return 'MembershipStatusResult(membershipId: $membershipId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MembershipStatusResultCopyWith<$Res> implements $MembershipStatusResultCopyWith<$Res> {
  factory _$MembershipStatusResultCopyWith(_MembershipStatusResult value, $Res Function(_MembershipStatusResult) _then) = __$MembershipStatusResultCopyWithImpl;
@override @useResult
$Res call({
 String membershipId, MembershipStatus status
});




}
/// @nodoc
class __$MembershipStatusResultCopyWithImpl<$Res>
    implements _$MembershipStatusResultCopyWith<$Res> {
  __$MembershipStatusResultCopyWithImpl(this._self, this._then);

  final _MembershipStatusResult _self;
  final $Res Function(_MembershipStatusResult) _then;

/// Create a copy of MembershipStatusResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? membershipId = null,Object? status = null,}) {
  return _then(_MembershipStatusResult(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,
  ));
}


}


/// @nodoc
mixin _$AdjustMembershipDatesResult {

 String get membershipId; String get memberId;@PlainDateConverter() DateTime get previousStartDate;@NullablePlainDateConverter() DateTime? get previousEndDate;@PlainDateConverter() DateTime get startDate;@NullablePlainDateConverter() DateTime? get endDate;/// Signed day counts, computed in Postgres as `date - date`. Negative
/// means the window moved earlier or shortened.
 int get daysMoved; int get daysChanged; MembershipStatus get status;
/// Create a copy of AdjustMembershipDatesResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdjustMembershipDatesResultCopyWith<AdjustMembershipDatesResult> get copyWith => _$AdjustMembershipDatesResultCopyWithImpl<AdjustMembershipDatesResult>(this as AdjustMembershipDatesResult, _$identity);

  /// Serializes this AdjustMembershipDatesResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdjustMembershipDatesResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.previousStartDate, previousStartDate) || other.previousStartDate == previousStartDate)&&(identical(other.previousEndDate, previousEndDate) || other.previousEndDate == previousEndDate)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.daysMoved, daysMoved) || other.daysMoved == daysMoved)&&(identical(other.daysChanged, daysChanged) || other.daysChanged == daysChanged)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,memberId,previousStartDate,previousEndDate,startDate,endDate,daysMoved,daysChanged,status);

@override
String toString() {
  return 'AdjustMembershipDatesResult(membershipId: $membershipId, memberId: $memberId, previousStartDate: $previousStartDate, previousEndDate: $previousEndDate, startDate: $startDate, endDate: $endDate, daysMoved: $daysMoved, daysChanged: $daysChanged, status: $status)';
}


}

/// @nodoc
abstract mixin class $AdjustMembershipDatesResultCopyWith<$Res>  {
  factory $AdjustMembershipDatesResultCopyWith(AdjustMembershipDatesResult value, $Res Function(AdjustMembershipDatesResult) _then) = _$AdjustMembershipDatesResultCopyWithImpl;
@useResult
$Res call({
 String membershipId, String memberId,@PlainDateConverter() DateTime previousStartDate,@NullablePlainDateConverter() DateTime? previousEndDate,@PlainDateConverter() DateTime startDate,@NullablePlainDateConverter() DateTime? endDate, int daysMoved, int daysChanged, MembershipStatus status
});




}
/// @nodoc
class _$AdjustMembershipDatesResultCopyWithImpl<$Res>
    implements $AdjustMembershipDatesResultCopyWith<$Res> {
  _$AdjustMembershipDatesResultCopyWithImpl(this._self, this._then);

  final AdjustMembershipDatesResult _self;
  final $Res Function(AdjustMembershipDatesResult) _then;

/// Create a copy of AdjustMembershipDatesResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? membershipId = null,Object? memberId = null,Object? previousStartDate = null,Object? previousEndDate = freezed,Object? startDate = null,Object? endDate = freezed,Object? daysMoved = null,Object? daysChanged = null,Object? status = null,}) {
  return _then(_self.copyWith(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,previousStartDate: null == previousStartDate ? _self.previousStartDate : previousStartDate // ignore: cast_nullable_to_non_nullable
as DateTime,previousEndDate: freezed == previousEndDate ? _self.previousEndDate : previousEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,daysMoved: null == daysMoved ? _self.daysMoved : daysMoved // ignore: cast_nullable_to_non_nullable
as int,daysChanged: null == daysChanged ? _self.daysChanged : daysChanged // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [AdjustMembershipDatesResult].
extension AdjustMembershipDatesResultPatterns on AdjustMembershipDatesResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdjustMembershipDatesResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdjustMembershipDatesResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdjustMembershipDatesResult value)  $default,){
final _that = this;
switch (_that) {
case _AdjustMembershipDatesResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdjustMembershipDatesResult value)?  $default,){
final _that = this;
switch (_that) {
case _AdjustMembershipDatesResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String membershipId,  String memberId, @PlainDateConverter()  DateTime previousStartDate, @NullablePlainDateConverter()  DateTime? previousEndDate, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int daysMoved,  int daysChanged,  MembershipStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdjustMembershipDatesResult() when $default != null:
return $default(_that.membershipId,_that.memberId,_that.previousStartDate,_that.previousEndDate,_that.startDate,_that.endDate,_that.daysMoved,_that.daysChanged,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String membershipId,  String memberId, @PlainDateConverter()  DateTime previousStartDate, @NullablePlainDateConverter()  DateTime? previousEndDate, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int daysMoved,  int daysChanged,  MembershipStatus status)  $default,) {final _that = this;
switch (_that) {
case _AdjustMembershipDatesResult():
return $default(_that.membershipId,_that.memberId,_that.previousStartDate,_that.previousEndDate,_that.startDate,_that.endDate,_that.daysMoved,_that.daysChanged,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String membershipId,  String memberId, @PlainDateConverter()  DateTime previousStartDate, @NullablePlainDateConverter()  DateTime? previousEndDate, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int daysMoved,  int daysChanged,  MembershipStatus status)?  $default,) {final _that = this;
switch (_that) {
case _AdjustMembershipDatesResult() when $default != null:
return $default(_that.membershipId,_that.memberId,_that.previousStartDate,_that.previousEndDate,_that.startDate,_that.endDate,_that.daysMoved,_that.daysChanged,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AdjustMembershipDatesResult implements AdjustMembershipDatesResult {
  const _AdjustMembershipDatesResult({required this.membershipId, required this.memberId, @PlainDateConverter() required this.previousStartDate, @NullablePlainDateConverter() this.previousEndDate, @PlainDateConverter() required this.startDate, @NullablePlainDateConverter() this.endDate, required this.daysMoved, required this.daysChanged, required this.status});
  factory _AdjustMembershipDatesResult.fromJson(Map<String, dynamic> json) => _$AdjustMembershipDatesResultFromJson(json);

@override final  String membershipId;
@override final  String memberId;
@override@PlainDateConverter() final  DateTime previousStartDate;
@override@NullablePlainDateConverter() final  DateTime? previousEndDate;
@override@PlainDateConverter() final  DateTime startDate;
@override@NullablePlainDateConverter() final  DateTime? endDate;
/// Signed day counts, computed in Postgres as `date - date`. Negative
/// means the window moved earlier or shortened.
@override final  int daysMoved;
@override final  int daysChanged;
@override final  MembershipStatus status;

/// Create a copy of AdjustMembershipDatesResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdjustMembershipDatesResultCopyWith<_AdjustMembershipDatesResult> get copyWith => __$AdjustMembershipDatesResultCopyWithImpl<_AdjustMembershipDatesResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdjustMembershipDatesResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdjustMembershipDatesResult&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.previousStartDate, previousStartDate) || other.previousStartDate == previousStartDate)&&(identical(other.previousEndDate, previousEndDate) || other.previousEndDate == previousEndDate)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.daysMoved, daysMoved) || other.daysMoved == daysMoved)&&(identical(other.daysChanged, daysChanged) || other.daysChanged == daysChanged)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,memberId,previousStartDate,previousEndDate,startDate,endDate,daysMoved,daysChanged,status);

@override
String toString() {
  return 'AdjustMembershipDatesResult(membershipId: $membershipId, memberId: $memberId, previousStartDate: $previousStartDate, previousEndDate: $previousEndDate, startDate: $startDate, endDate: $endDate, daysMoved: $daysMoved, daysChanged: $daysChanged, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AdjustMembershipDatesResultCopyWith<$Res> implements $AdjustMembershipDatesResultCopyWith<$Res> {
  factory _$AdjustMembershipDatesResultCopyWith(_AdjustMembershipDatesResult value, $Res Function(_AdjustMembershipDatesResult) _then) = __$AdjustMembershipDatesResultCopyWithImpl;
@override @useResult
$Res call({
 String membershipId, String memberId,@PlainDateConverter() DateTime previousStartDate,@NullablePlainDateConverter() DateTime? previousEndDate,@PlainDateConverter() DateTime startDate,@NullablePlainDateConverter() DateTime? endDate, int daysMoved, int daysChanged, MembershipStatus status
});




}
/// @nodoc
class __$AdjustMembershipDatesResultCopyWithImpl<$Res>
    implements _$AdjustMembershipDatesResultCopyWith<$Res> {
  __$AdjustMembershipDatesResultCopyWithImpl(this._self, this._then);

  final _AdjustMembershipDatesResult _self;
  final $Res Function(_AdjustMembershipDatesResult) _then;

/// Create a copy of AdjustMembershipDatesResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? membershipId = null,Object? memberId = null,Object? previousStartDate = null,Object? previousEndDate = freezed,Object? startDate = null,Object? endDate = freezed,Object? daysMoved = null,Object? daysChanged = null,Object? status = null,}) {
  return _then(_AdjustMembershipDatesResult(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,previousStartDate: null == previousStartDate ? _self.previousStartDate : previousStartDate // ignore: cast_nullable_to_non_nullable
as DateTime,previousEndDate: freezed == previousEndDate ? _self.previousEndDate : previousEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,daysMoved: null == daysMoved ? _self.daysMoved : daysMoved // ignore: cast_nullable_to_non_nullable
as int,daysChanged: null == daysChanged ? _self.daysChanged : daysChanged // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,
  ));
}


}

// dart format on
