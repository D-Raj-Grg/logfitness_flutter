// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_rpc_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterMemberResult {

 String get memberId;/// Minted by `prepare_member_row`, never supplied by the client.
 String get memberCode; bool get sold; String? get membershipId; String? get invoiceId; String? get invoiceNo;/// Null when the sale took no money -- an invoice raised to be settled
/// later.
 String? get paymentId;@NullablePlainDateConverter() DateTime? get startDate;@NullablePlainDateConverter() DateTime? get endDate;// Money is integer paisa end to end.
 int? get totalPaisa; int? get duePaisa;
/// Create a copy of RegisterMemberResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterMemberResultCopyWith<RegisterMemberResult> get copyWith => _$RegisterMemberResultCopyWithImpl<RegisterMemberResult>(this as RegisterMemberResult, _$identity);

  /// Serializes this RegisterMemberResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterMemberResult&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.sold, sold) || other.sold == sold)&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalPaisa, totalPaisa) || other.totalPaisa == totalPaisa)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,memberCode,sold,membershipId,invoiceId,invoiceNo,paymentId,startDate,endDate,totalPaisa,duePaisa);

@override
String toString() {
  return 'RegisterMemberResult(memberId: $memberId, memberCode: $memberCode, sold: $sold, membershipId: $membershipId, invoiceId: $invoiceId, invoiceNo: $invoiceNo, paymentId: $paymentId, startDate: $startDate, endDate: $endDate, totalPaisa: $totalPaisa, duePaisa: $duePaisa)';
}


}

/// @nodoc
abstract mixin class $RegisterMemberResultCopyWith<$Res>  {
  factory $RegisterMemberResultCopyWith(RegisterMemberResult value, $Res Function(RegisterMemberResult) _then) = _$RegisterMemberResultCopyWithImpl;
@useResult
$Res call({
 String memberId, String memberCode, bool sold, String? membershipId, String? invoiceId, String? invoiceNo, String? paymentId,@NullablePlainDateConverter() DateTime? startDate,@NullablePlainDateConverter() DateTime? endDate, int? totalPaisa, int? duePaisa
});




}
/// @nodoc
class _$RegisterMemberResultCopyWithImpl<$Res>
    implements $RegisterMemberResultCopyWith<$Res> {
  _$RegisterMemberResultCopyWithImpl(this._self, this._then);

  final RegisterMemberResult _self;
  final $Res Function(RegisterMemberResult) _then;

/// Create a copy of RegisterMemberResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? memberCode = null,Object? sold = null,Object? membershipId = freezed,Object? invoiceId = freezed,Object? invoiceNo = freezed,Object? paymentId = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? totalPaisa = freezed,Object? duePaisa = freezed,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,sold: null == sold ? _self.sold : sold // ignore: cast_nullable_to_non_nullable
as bool,membershipId: freezed == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNo: freezed == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String?,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalPaisa: freezed == totalPaisa ? _self.totalPaisa : totalPaisa // ignore: cast_nullable_to_non_nullable
as int?,duePaisa: freezed == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterMemberResult].
extension RegisterMemberResultPatterns on RegisterMemberResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterMemberResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterMemberResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterMemberResult value)  $default,){
final _that = this;
switch (_that) {
case _RegisterMemberResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterMemberResult value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterMemberResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String memberCode,  bool sold,  String? membershipId,  String? invoiceId,  String? invoiceNo,  String? paymentId, @NullablePlainDateConverter()  DateTime? startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? totalPaisa,  int? duePaisa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterMemberResult() when $default != null:
return $default(_that.memberId,_that.memberCode,_that.sold,_that.membershipId,_that.invoiceId,_that.invoiceNo,_that.paymentId,_that.startDate,_that.endDate,_that.totalPaisa,_that.duePaisa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String memberCode,  bool sold,  String? membershipId,  String? invoiceId,  String? invoiceNo,  String? paymentId, @NullablePlainDateConverter()  DateTime? startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? totalPaisa,  int? duePaisa)  $default,) {final _that = this;
switch (_that) {
case _RegisterMemberResult():
return $default(_that.memberId,_that.memberCode,_that.sold,_that.membershipId,_that.invoiceId,_that.invoiceNo,_that.paymentId,_that.startDate,_that.endDate,_that.totalPaisa,_that.duePaisa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String memberCode,  bool sold,  String? membershipId,  String? invoiceId,  String? invoiceNo,  String? paymentId, @NullablePlainDateConverter()  DateTime? startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? totalPaisa,  int? duePaisa)?  $default,) {final _that = this;
switch (_that) {
case _RegisterMemberResult() when $default != null:
return $default(_that.memberId,_that.memberCode,_that.sold,_that.membershipId,_that.invoiceId,_that.invoiceNo,_that.paymentId,_that.startDate,_that.endDate,_that.totalPaisa,_that.duePaisa);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RegisterMemberResult implements RegisterMemberResult {
  const _RegisterMemberResult({required this.memberId, required this.memberCode, required this.sold, this.membershipId, this.invoiceId, this.invoiceNo, this.paymentId, @NullablePlainDateConverter() this.startDate, @NullablePlainDateConverter() this.endDate, this.totalPaisa, this.duePaisa});
  factory _RegisterMemberResult.fromJson(Map<String, dynamic> json) => _$RegisterMemberResultFromJson(json);

@override final  String memberId;
/// Minted by `prepare_member_row`, never supplied by the client.
@override final  String memberCode;
@override final  bool sold;
@override final  String? membershipId;
@override final  String? invoiceId;
@override final  String? invoiceNo;
/// Null when the sale took no money -- an invoice raised to be settled
/// later.
@override final  String? paymentId;
@override@NullablePlainDateConverter() final  DateTime? startDate;
@override@NullablePlainDateConverter() final  DateTime? endDate;
// Money is integer paisa end to end.
@override final  int? totalPaisa;
@override final  int? duePaisa;

/// Create a copy of RegisterMemberResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterMemberResultCopyWith<_RegisterMemberResult> get copyWith => __$RegisterMemberResultCopyWithImpl<_RegisterMemberResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterMemberResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterMemberResult&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.sold, sold) || other.sold == sold)&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalPaisa, totalPaisa) || other.totalPaisa == totalPaisa)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,memberCode,sold,membershipId,invoiceId,invoiceNo,paymentId,startDate,endDate,totalPaisa,duePaisa);

@override
String toString() {
  return 'RegisterMemberResult(memberId: $memberId, memberCode: $memberCode, sold: $sold, membershipId: $membershipId, invoiceId: $invoiceId, invoiceNo: $invoiceNo, paymentId: $paymentId, startDate: $startDate, endDate: $endDate, totalPaisa: $totalPaisa, duePaisa: $duePaisa)';
}


}

/// @nodoc
abstract mixin class _$RegisterMemberResultCopyWith<$Res> implements $RegisterMemberResultCopyWith<$Res> {
  factory _$RegisterMemberResultCopyWith(_RegisterMemberResult value, $Res Function(_RegisterMemberResult) _then) = __$RegisterMemberResultCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String memberCode, bool sold, String? membershipId, String? invoiceId, String? invoiceNo, String? paymentId,@NullablePlainDateConverter() DateTime? startDate,@NullablePlainDateConverter() DateTime? endDate, int? totalPaisa, int? duePaisa
});




}
/// @nodoc
class __$RegisterMemberResultCopyWithImpl<$Res>
    implements _$RegisterMemberResultCopyWith<$Res> {
  __$RegisterMemberResultCopyWithImpl(this._self, this._then);

  final _RegisterMemberResult _self;
  final $Res Function(_RegisterMemberResult) _then;

/// Create a copy of RegisterMemberResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? memberCode = null,Object? sold = null,Object? membershipId = freezed,Object? invoiceId = freezed,Object? invoiceNo = freezed,Object? paymentId = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? totalPaisa = freezed,Object? duePaisa = freezed,}) {
  return _then(_RegisterMemberResult(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,sold: null == sold ? _self.sold : sold // ignore: cast_nullable_to_non_nullable
as bool,membershipId: freezed == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNo: freezed == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String?,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalPaisa: freezed == totalPaisa ? _self.totalPaisa : totalPaisa // ignore: cast_nullable_to_non_nullable
as int?,duePaisa: freezed == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ArchiveMemberResult {

 String get memberId;/// `timestamptz`, not a date: archiving is an instant, and the audit
/// trail wants the time of day.
 DateTime get archivedAt;
/// Create a copy of ArchiveMemberResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArchiveMemberResultCopyWith<ArchiveMemberResult> get copyWith => _$ArchiveMemberResultCopyWithImpl<ArchiveMemberResult>(this as ArchiveMemberResult, _$identity);

  /// Serializes this ArchiveMemberResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArchiveMemberResult&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,archivedAt);

@override
String toString() {
  return 'ArchiveMemberResult(memberId: $memberId, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class $ArchiveMemberResultCopyWith<$Res>  {
  factory $ArchiveMemberResultCopyWith(ArchiveMemberResult value, $Res Function(ArchiveMemberResult) _then) = _$ArchiveMemberResultCopyWithImpl;
@useResult
$Res call({
 String memberId, DateTime archivedAt
});




}
/// @nodoc
class _$ArchiveMemberResultCopyWithImpl<$Res>
    implements $ArchiveMemberResultCopyWith<$Res> {
  _$ArchiveMemberResultCopyWithImpl(this._self, this._then);

  final ArchiveMemberResult _self;
  final $Res Function(ArchiveMemberResult) _then;

/// Create a copy of ArchiveMemberResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? archivedAt = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,archivedAt: null == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ArchiveMemberResult].
extension ArchiveMemberResultPatterns on ArchiveMemberResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArchiveMemberResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArchiveMemberResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArchiveMemberResult value)  $default,){
final _that = this;
switch (_that) {
case _ArchiveMemberResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArchiveMemberResult value)?  $default,){
final _that = this;
switch (_that) {
case _ArchiveMemberResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  DateTime archivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArchiveMemberResult() when $default != null:
return $default(_that.memberId,_that.archivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  DateTime archivedAt)  $default,) {final _that = this;
switch (_that) {
case _ArchiveMemberResult():
return $default(_that.memberId,_that.archivedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  DateTime archivedAt)?  $default,) {final _that = this;
switch (_that) {
case _ArchiveMemberResult() when $default != null:
return $default(_that.memberId,_that.archivedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ArchiveMemberResult implements ArchiveMemberResult {
  const _ArchiveMemberResult({required this.memberId, required this.archivedAt});
  factory _ArchiveMemberResult.fromJson(Map<String, dynamic> json) => _$ArchiveMemberResultFromJson(json);

@override final  String memberId;
/// `timestamptz`, not a date: archiving is an instant, and the audit
/// trail wants the time of day.
@override final  DateTime archivedAt;

/// Create a copy of ArchiveMemberResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchiveMemberResultCopyWith<_ArchiveMemberResult> get copyWith => __$ArchiveMemberResultCopyWithImpl<_ArchiveMemberResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArchiveMemberResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArchiveMemberResult&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,archivedAt);

@override
String toString() {
  return 'ArchiveMemberResult(memberId: $memberId, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class _$ArchiveMemberResultCopyWith<$Res> implements $ArchiveMemberResultCopyWith<$Res> {
  factory _$ArchiveMemberResultCopyWith(_ArchiveMemberResult value, $Res Function(_ArchiveMemberResult) _then) = __$ArchiveMemberResultCopyWithImpl;
@override @useResult
$Res call({
 String memberId, DateTime archivedAt
});




}
/// @nodoc
class __$ArchiveMemberResultCopyWithImpl<$Res>
    implements _$ArchiveMemberResultCopyWith<$Res> {
  __$ArchiveMemberResultCopyWithImpl(this._self, this._then);

  final _ArchiveMemberResult _self;
  final $Res Function(_ArchiveMemberResult) _then;

/// Create a copy of ArchiveMemberResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? archivedAt = null,}) {
  return _then(_ArchiveMemberResult(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,archivedAt: null == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MemberStatusResult {

 String get memberId; MemberStatus get status;
/// Create a copy of MemberStatusResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberStatusResultCopyWith<MemberStatusResult> get copyWith => _$MemberStatusResultCopyWithImpl<MemberStatusResult>(this as MemberStatusResult, _$identity);

  /// Serializes this MemberStatusResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberStatusResult&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,status);

@override
String toString() {
  return 'MemberStatusResult(memberId: $memberId, status: $status)';
}


}

/// @nodoc
abstract mixin class $MemberStatusResultCopyWith<$Res>  {
  factory $MemberStatusResultCopyWith(MemberStatusResult value, $Res Function(MemberStatusResult) _then) = _$MemberStatusResultCopyWithImpl;
@useResult
$Res call({
 String memberId, MemberStatus status
});




}
/// @nodoc
class _$MemberStatusResultCopyWithImpl<$Res>
    implements $MemberStatusResultCopyWith<$Res> {
  _$MemberStatusResultCopyWithImpl(this._self, this._then);

  final MemberStatusResult _self;
  final $Res Function(MemberStatusResult) _then;

/// Create a copy of MemberStatusResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? status = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberStatusResult].
extension MemberStatusResultPatterns on MemberStatusResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberStatusResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberStatusResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberStatusResult value)  $default,){
final _that = this;
switch (_that) {
case _MemberStatusResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberStatusResult value)?  $default,){
final _that = this;
switch (_that) {
case _MemberStatusResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  MemberStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberStatusResult() when $default != null:
return $default(_that.memberId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  MemberStatus status)  $default,) {final _that = this;
switch (_that) {
case _MemberStatusResult():
return $default(_that.memberId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  MemberStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MemberStatusResult() when $default != null:
return $default(_that.memberId,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MemberStatusResult implements MemberStatusResult {
  const _MemberStatusResult({required this.memberId, required this.status});
  factory _MemberStatusResult.fromJson(Map<String, dynamic> json) => _$MemberStatusResultFromJson(json);

@override final  String memberId;
@override final  MemberStatus status;

/// Create a copy of MemberStatusResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberStatusResultCopyWith<_MemberStatusResult> get copyWith => __$MemberStatusResultCopyWithImpl<_MemberStatusResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberStatusResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberStatusResult&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,status);

@override
String toString() {
  return 'MemberStatusResult(memberId: $memberId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MemberStatusResultCopyWith<$Res> implements $MemberStatusResultCopyWith<$Res> {
  factory _$MemberStatusResultCopyWith(_MemberStatusResult value, $Res Function(_MemberStatusResult) _then) = __$MemberStatusResultCopyWithImpl;
@override @useResult
$Res call({
 String memberId, MemberStatus status
});




}
/// @nodoc
class __$MemberStatusResultCopyWithImpl<$Res>
    implements _$MemberStatusResultCopyWith<$Res> {
  __$MemberStatusResultCopyWithImpl(this._self, this._then);

  final _MemberStatusResult _self;
  final $Res Function(_MemberStatusResult) _then;

/// Create a copy of MemberStatusResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? status = null,}) {
  return _then(_MemberStatusResult(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,
  ));
}


}

// dart format on
