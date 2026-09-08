// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_rpc_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecordPaymentResult {

 String get paymentId; String get invoiceId; int get paidPaisa; int get duePaisa; InvoiceStatus get status;
/// Create a copy of RecordPaymentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordPaymentResultCopyWith<RecordPaymentResult> get copyWith => _$RecordPaymentResultCopyWithImpl<RecordPaymentResult>(this as RecordPaymentResult, _$identity);

  /// Serializes this RecordPaymentResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordPaymentResult&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.paidPaisa, paidPaisa) || other.paidPaisa == paidPaisa)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentId,invoiceId,paidPaisa,duePaisa,status);

@override
String toString() {
  return 'RecordPaymentResult(paymentId: $paymentId, invoiceId: $invoiceId, paidPaisa: $paidPaisa, duePaisa: $duePaisa, status: $status)';
}


}

/// @nodoc
abstract mixin class $RecordPaymentResultCopyWith<$Res>  {
  factory $RecordPaymentResultCopyWith(RecordPaymentResult value, $Res Function(RecordPaymentResult) _then) = _$RecordPaymentResultCopyWithImpl;
@useResult
$Res call({
 String paymentId, String invoiceId, int paidPaisa, int duePaisa, InvoiceStatus status
});




}
/// @nodoc
class _$RecordPaymentResultCopyWithImpl<$Res>
    implements $RecordPaymentResultCopyWith<$Res> {
  _$RecordPaymentResultCopyWithImpl(this._self, this._then);

  final RecordPaymentResult _self;
  final $Res Function(RecordPaymentResult) _then;

/// Create a copy of RecordPaymentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentId = null,Object? invoiceId = null,Object? paidPaisa = null,Object? duePaisa = null,Object? status = null,}) {
  return _then(_self.copyWith(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,paidPaisa: null == paidPaisa ? _self.paidPaisa : paidPaisa // ignore: cast_nullable_to_non_nullable
as int,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordPaymentResult].
extension RecordPaymentResultPatterns on RecordPaymentResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordPaymentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordPaymentResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordPaymentResult value)  $default,){
final _that = this;
switch (_that) {
case _RecordPaymentResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordPaymentResult value)?  $default,){
final _that = this;
switch (_that) {
case _RecordPaymentResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String paymentId,  String invoiceId,  int paidPaisa,  int duePaisa,  InvoiceStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordPaymentResult() when $default != null:
return $default(_that.paymentId,_that.invoiceId,_that.paidPaisa,_that.duePaisa,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String paymentId,  String invoiceId,  int paidPaisa,  int duePaisa,  InvoiceStatus status)  $default,) {final _that = this;
switch (_that) {
case _RecordPaymentResult():
return $default(_that.paymentId,_that.invoiceId,_that.paidPaisa,_that.duePaisa,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String paymentId,  String invoiceId,  int paidPaisa,  int duePaisa,  InvoiceStatus status)?  $default,) {final _that = this;
switch (_that) {
case _RecordPaymentResult() when $default != null:
return $default(_that.paymentId,_that.invoiceId,_that.paidPaisa,_that.duePaisa,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RecordPaymentResult implements RecordPaymentResult {
  const _RecordPaymentResult({required this.paymentId, required this.invoiceId, required this.paidPaisa, required this.duePaisa, required this.status});
  factory _RecordPaymentResult.fromJson(Map<String, dynamic> json) => _$RecordPaymentResultFromJson(json);

@override final  String paymentId;
@override final  String invoiceId;
@override final  int paidPaisa;
@override final  int duePaisa;
@override final  InvoiceStatus status;

/// Create a copy of RecordPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordPaymentResultCopyWith<_RecordPaymentResult> get copyWith => __$RecordPaymentResultCopyWithImpl<_RecordPaymentResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecordPaymentResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordPaymentResult&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.paidPaisa, paidPaisa) || other.paidPaisa == paidPaisa)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentId,invoiceId,paidPaisa,duePaisa,status);

@override
String toString() {
  return 'RecordPaymentResult(paymentId: $paymentId, invoiceId: $invoiceId, paidPaisa: $paidPaisa, duePaisa: $duePaisa, status: $status)';
}


}

/// @nodoc
abstract mixin class _$RecordPaymentResultCopyWith<$Res> implements $RecordPaymentResultCopyWith<$Res> {
  factory _$RecordPaymentResultCopyWith(_RecordPaymentResult value, $Res Function(_RecordPaymentResult) _then) = __$RecordPaymentResultCopyWithImpl;
@override @useResult
$Res call({
 String paymentId, String invoiceId, int paidPaisa, int duePaisa, InvoiceStatus status
});




}
/// @nodoc
class __$RecordPaymentResultCopyWithImpl<$Res>
    implements _$RecordPaymentResultCopyWith<$Res> {
  __$RecordPaymentResultCopyWithImpl(this._self, this._then);

  final _RecordPaymentResult _self;
  final $Res Function(_RecordPaymentResult) _then;

/// Create a copy of RecordPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentId = null,Object? invoiceId = null,Object? paidPaisa = null,Object? duePaisa = null,Object? status = null,}) {
  return _then(_RecordPaymentResult(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,paidPaisa: null == paidPaisa ? _self.paidPaisa : paidPaisa // ignore: cast_nullable_to_non_nullable
as int,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,
  ));
}


}


/// @nodoc
mixin _$RefundPaymentResult {

 String get refundId; int get amountPaisa;
/// Create a copy of RefundPaymentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundPaymentResultCopyWith<RefundPaymentResult> get copyWith => _$RefundPaymentResultCopyWithImpl<RefundPaymentResult>(this as RefundPaymentResult, _$identity);

  /// Serializes this RefundPaymentResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundPaymentResult&&(identical(other.refundId, refundId) || other.refundId == refundId)&&(identical(other.amountPaisa, amountPaisa) || other.amountPaisa == amountPaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refundId,amountPaisa);

@override
String toString() {
  return 'RefundPaymentResult(refundId: $refundId, amountPaisa: $amountPaisa)';
}


}

/// @nodoc
abstract mixin class $RefundPaymentResultCopyWith<$Res>  {
  factory $RefundPaymentResultCopyWith(RefundPaymentResult value, $Res Function(RefundPaymentResult) _then) = _$RefundPaymentResultCopyWithImpl;
@useResult
$Res call({
 String refundId, int amountPaisa
});




}
/// @nodoc
class _$RefundPaymentResultCopyWithImpl<$Res>
    implements $RefundPaymentResultCopyWith<$Res> {
  _$RefundPaymentResultCopyWithImpl(this._self, this._then);

  final RefundPaymentResult _self;
  final $Res Function(RefundPaymentResult) _then;

/// Create a copy of RefundPaymentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refundId = null,Object? amountPaisa = null,}) {
  return _then(_self.copyWith(
refundId: null == refundId ? _self.refundId : refundId // ignore: cast_nullable_to_non_nullable
as String,amountPaisa: null == amountPaisa ? _self.amountPaisa : amountPaisa // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RefundPaymentResult].
extension RefundPaymentResultPatterns on RefundPaymentResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefundPaymentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefundPaymentResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefundPaymentResult value)  $default,){
final _that = this;
switch (_that) {
case _RefundPaymentResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefundPaymentResult value)?  $default,){
final _that = this;
switch (_that) {
case _RefundPaymentResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refundId,  int amountPaisa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefundPaymentResult() when $default != null:
return $default(_that.refundId,_that.amountPaisa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refundId,  int amountPaisa)  $default,) {final _that = this;
switch (_that) {
case _RefundPaymentResult():
return $default(_that.refundId,_that.amountPaisa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refundId,  int amountPaisa)?  $default,) {final _that = this;
switch (_that) {
case _RefundPaymentResult() when $default != null:
return $default(_that.refundId,_that.amountPaisa);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RefundPaymentResult implements RefundPaymentResult {
  const _RefundPaymentResult({required this.refundId, required this.amountPaisa});
  factory _RefundPaymentResult.fromJson(Map<String, dynamic> json) => _$RefundPaymentResultFromJson(json);

@override final  String refundId;
@override final  int amountPaisa;

/// Create a copy of RefundPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefundPaymentResultCopyWith<_RefundPaymentResult> get copyWith => __$RefundPaymentResultCopyWithImpl<_RefundPaymentResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefundPaymentResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefundPaymentResult&&(identical(other.refundId, refundId) || other.refundId == refundId)&&(identical(other.amountPaisa, amountPaisa) || other.amountPaisa == amountPaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refundId,amountPaisa);

@override
String toString() {
  return 'RefundPaymentResult(refundId: $refundId, amountPaisa: $amountPaisa)';
}


}

/// @nodoc
abstract mixin class _$RefundPaymentResultCopyWith<$Res> implements $RefundPaymentResultCopyWith<$Res> {
  factory _$RefundPaymentResultCopyWith(_RefundPaymentResult value, $Res Function(_RefundPaymentResult) _then) = __$RefundPaymentResultCopyWithImpl;
@override @useResult
$Res call({
 String refundId, int amountPaisa
});




}
/// @nodoc
class __$RefundPaymentResultCopyWithImpl<$Res>
    implements _$RefundPaymentResultCopyWith<$Res> {
  __$RefundPaymentResultCopyWithImpl(this._self, this._then);

  final _RefundPaymentResult _self;
  final $Res Function(_RefundPaymentResult) _then;

/// Create a copy of RefundPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refundId = null,Object? amountPaisa = null,}) {
  return _then(_RefundPaymentResult(
refundId: null == refundId ? _self.refundId : refundId // ignore: cast_nullable_to_non_nullable
as String,amountPaisa: null == amountPaisa ? _self.amountPaisa : amountPaisa // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReversePaymentResult {

 String get reversalId;/// The entry that was reversed, not the reversal itself.
 String get paymentId;/// Negative, like a refund.
 int get amountPaisa; String? get invoiceId; String? get invoiceNo; int? get duePaisa; InvoiceStatus? get status;
/// Create a copy of ReversePaymentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReversePaymentResultCopyWith<ReversePaymentResult> get copyWith => _$ReversePaymentResultCopyWithImpl<ReversePaymentResult>(this as ReversePaymentResult, _$identity);

  /// Serializes this ReversePaymentResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReversePaymentResult&&(identical(other.reversalId, reversalId) || other.reversalId == reversalId)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.amountPaisa, amountPaisa) || other.amountPaisa == amountPaisa)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reversalId,paymentId,amountPaisa,invoiceId,invoiceNo,duePaisa,status);

@override
String toString() {
  return 'ReversePaymentResult(reversalId: $reversalId, paymentId: $paymentId, amountPaisa: $amountPaisa, invoiceId: $invoiceId, invoiceNo: $invoiceNo, duePaisa: $duePaisa, status: $status)';
}


}

/// @nodoc
abstract mixin class $ReversePaymentResultCopyWith<$Res>  {
  factory $ReversePaymentResultCopyWith(ReversePaymentResult value, $Res Function(ReversePaymentResult) _then) = _$ReversePaymentResultCopyWithImpl;
@useResult
$Res call({
 String reversalId, String paymentId, int amountPaisa, String? invoiceId, String? invoiceNo, int? duePaisa, InvoiceStatus? status
});




}
/// @nodoc
class _$ReversePaymentResultCopyWithImpl<$Res>
    implements $ReversePaymentResultCopyWith<$Res> {
  _$ReversePaymentResultCopyWithImpl(this._self, this._then);

  final ReversePaymentResult _self;
  final $Res Function(ReversePaymentResult) _then;

/// Create a copy of ReversePaymentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reversalId = null,Object? paymentId = null,Object? amountPaisa = null,Object? invoiceId = freezed,Object? invoiceNo = freezed,Object? duePaisa = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
reversalId: null == reversalId ? _self.reversalId : reversalId // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,amountPaisa: null == amountPaisa ? _self.amountPaisa : amountPaisa // ignore: cast_nullable_to_non_nullable
as int,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNo: freezed == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String?,duePaisa: freezed == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReversePaymentResult].
extension ReversePaymentResultPatterns on ReversePaymentResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReversePaymentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReversePaymentResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReversePaymentResult value)  $default,){
final _that = this;
switch (_that) {
case _ReversePaymentResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReversePaymentResult value)?  $default,){
final _that = this;
switch (_that) {
case _ReversePaymentResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reversalId,  String paymentId,  int amountPaisa,  String? invoiceId,  String? invoiceNo,  int? duePaisa,  InvoiceStatus? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReversePaymentResult() when $default != null:
return $default(_that.reversalId,_that.paymentId,_that.amountPaisa,_that.invoiceId,_that.invoiceNo,_that.duePaisa,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reversalId,  String paymentId,  int amountPaisa,  String? invoiceId,  String? invoiceNo,  int? duePaisa,  InvoiceStatus? status)  $default,) {final _that = this;
switch (_that) {
case _ReversePaymentResult():
return $default(_that.reversalId,_that.paymentId,_that.amountPaisa,_that.invoiceId,_that.invoiceNo,_that.duePaisa,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reversalId,  String paymentId,  int amountPaisa,  String? invoiceId,  String? invoiceNo,  int? duePaisa,  InvoiceStatus? status)?  $default,) {final _that = this;
switch (_that) {
case _ReversePaymentResult() when $default != null:
return $default(_that.reversalId,_that.paymentId,_that.amountPaisa,_that.invoiceId,_that.invoiceNo,_that.duePaisa,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ReversePaymentResult implements ReversePaymentResult {
  const _ReversePaymentResult({required this.reversalId, required this.paymentId, required this.amountPaisa, this.invoiceId, this.invoiceNo, this.duePaisa, this.status});
  factory _ReversePaymentResult.fromJson(Map<String, dynamic> json) => _$ReversePaymentResultFromJson(json);

@override final  String reversalId;
/// The entry that was reversed, not the reversal itself.
@override final  String paymentId;
/// Negative, like a refund.
@override final  int amountPaisa;
@override final  String? invoiceId;
@override final  String? invoiceNo;
@override final  int? duePaisa;
@override final  InvoiceStatus? status;

/// Create a copy of ReversePaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReversePaymentResultCopyWith<_ReversePaymentResult> get copyWith => __$ReversePaymentResultCopyWithImpl<_ReversePaymentResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReversePaymentResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReversePaymentResult&&(identical(other.reversalId, reversalId) || other.reversalId == reversalId)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.amountPaisa, amountPaisa) || other.amountPaisa == amountPaisa)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reversalId,paymentId,amountPaisa,invoiceId,invoiceNo,duePaisa,status);

@override
String toString() {
  return 'ReversePaymentResult(reversalId: $reversalId, paymentId: $paymentId, amountPaisa: $amountPaisa, invoiceId: $invoiceId, invoiceNo: $invoiceNo, duePaisa: $duePaisa, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ReversePaymentResultCopyWith<$Res> implements $ReversePaymentResultCopyWith<$Res> {
  factory _$ReversePaymentResultCopyWith(_ReversePaymentResult value, $Res Function(_ReversePaymentResult) _then) = __$ReversePaymentResultCopyWithImpl;
@override @useResult
$Res call({
 String reversalId, String paymentId, int amountPaisa, String? invoiceId, String? invoiceNo, int? duePaisa, InvoiceStatus? status
});




}
/// @nodoc
class __$ReversePaymentResultCopyWithImpl<$Res>
    implements _$ReversePaymentResultCopyWith<$Res> {
  __$ReversePaymentResultCopyWithImpl(this._self, this._then);

  final _ReversePaymentResult _self;
  final $Res Function(_ReversePaymentResult) _then;

/// Create a copy of ReversePaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reversalId = null,Object? paymentId = null,Object? amountPaisa = null,Object? invoiceId = freezed,Object? invoiceNo = freezed,Object? duePaisa = freezed,Object? status = freezed,}) {
  return _then(_ReversePaymentResult(
reversalId: null == reversalId ? _self.reversalId : reversalId // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,amountPaisa: null == amountPaisa ? _self.amountPaisa : amountPaisa // ignore: cast_nullable_to_non_nullable
as int,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNo: freezed == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String?,duePaisa: freezed == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus?,
  ));
}


}


/// @nodoc
mixin _$DailyCollectionRow {

 String get branchId; String get branchName;/// Null for a payment whose collector has since been removed, or one
/// taken by a function rather than a person.
 String? get staffId; String? get staffName; PaymentMethod get method; PaymentKind get kind;/// `bigint` from `count(*)`.
 int get txnCount;/// Signed: negative for the refund and reversal rows. Summing the whole
/// sheet gives net cash, which is the number the drawer has to match.
 int get amountPaisa;
/// Create a copy of DailyCollectionRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyCollectionRowCopyWith<DailyCollectionRow> get copyWith => _$DailyCollectionRowCopyWithImpl<DailyCollectionRow>(this as DailyCollectionRow, _$identity);

  /// Serializes this DailyCollectionRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyCollectionRow&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.method, method) || other.method == method)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.txnCount, txnCount) || other.txnCount == txnCount)&&(identical(other.amountPaisa, amountPaisa) || other.amountPaisa == amountPaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,branchId,branchName,staffId,staffName,method,kind,txnCount,amountPaisa);

@override
String toString() {
  return 'DailyCollectionRow(branchId: $branchId, branchName: $branchName, staffId: $staffId, staffName: $staffName, method: $method, kind: $kind, txnCount: $txnCount, amountPaisa: $amountPaisa)';
}


}

/// @nodoc
abstract mixin class $DailyCollectionRowCopyWith<$Res>  {
  factory $DailyCollectionRowCopyWith(DailyCollectionRow value, $Res Function(DailyCollectionRow) _then) = _$DailyCollectionRowCopyWithImpl;
@useResult
$Res call({
 String branchId, String branchName, String? staffId, String? staffName, PaymentMethod method, PaymentKind kind, int txnCount, int amountPaisa
});




}
/// @nodoc
class _$DailyCollectionRowCopyWithImpl<$Res>
    implements $DailyCollectionRowCopyWith<$Res> {
  _$DailyCollectionRowCopyWithImpl(this._self, this._then);

  final DailyCollectionRow _self;
  final $Res Function(DailyCollectionRow) _then;

/// Create a copy of DailyCollectionRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branchId = null,Object? branchName = null,Object? staffId = freezed,Object? staffName = freezed,Object? method = null,Object? kind = null,Object? txnCount = null,Object? amountPaisa = null,}) {
  return _then(_self.copyWith(
branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,staffId: freezed == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String?,staffName: freezed == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String?,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PaymentKind,txnCount: null == txnCount ? _self.txnCount : txnCount // ignore: cast_nullable_to_non_nullable
as int,amountPaisa: null == amountPaisa ? _self.amountPaisa : amountPaisa // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyCollectionRow].
extension DailyCollectionRowPatterns on DailyCollectionRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyCollectionRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyCollectionRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyCollectionRow value)  $default,){
final _that = this;
switch (_that) {
case _DailyCollectionRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyCollectionRow value)?  $default,){
final _that = this;
switch (_that) {
case _DailyCollectionRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String branchId,  String branchName,  String? staffId,  String? staffName,  PaymentMethod method,  PaymentKind kind,  int txnCount,  int amountPaisa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyCollectionRow() when $default != null:
return $default(_that.branchId,_that.branchName,_that.staffId,_that.staffName,_that.method,_that.kind,_that.txnCount,_that.amountPaisa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String branchId,  String branchName,  String? staffId,  String? staffName,  PaymentMethod method,  PaymentKind kind,  int txnCount,  int amountPaisa)  $default,) {final _that = this;
switch (_that) {
case _DailyCollectionRow():
return $default(_that.branchId,_that.branchName,_that.staffId,_that.staffName,_that.method,_that.kind,_that.txnCount,_that.amountPaisa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String branchId,  String branchName,  String? staffId,  String? staffName,  PaymentMethod method,  PaymentKind kind,  int txnCount,  int amountPaisa)?  $default,) {final _that = this;
switch (_that) {
case _DailyCollectionRow() when $default != null:
return $default(_that.branchId,_that.branchName,_that.staffId,_that.staffName,_that.method,_that.kind,_that.txnCount,_that.amountPaisa);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _DailyCollectionRow implements DailyCollectionRow {
  const _DailyCollectionRow({required this.branchId, required this.branchName, this.staffId, this.staffName, required this.method, required this.kind, required this.txnCount, required this.amountPaisa});
  factory _DailyCollectionRow.fromJson(Map<String, dynamic> json) => _$DailyCollectionRowFromJson(json);

@override final  String branchId;
@override final  String branchName;
/// Null for a payment whose collector has since been removed, or one
/// taken by a function rather than a person.
@override final  String? staffId;
@override final  String? staffName;
@override final  PaymentMethod method;
@override final  PaymentKind kind;
/// `bigint` from `count(*)`.
@override final  int txnCount;
/// Signed: negative for the refund and reversal rows. Summing the whole
/// sheet gives net cash, which is the number the drawer has to match.
@override final  int amountPaisa;

/// Create a copy of DailyCollectionRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyCollectionRowCopyWith<_DailyCollectionRow> get copyWith => __$DailyCollectionRowCopyWithImpl<_DailyCollectionRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyCollectionRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyCollectionRow&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.method, method) || other.method == method)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.txnCount, txnCount) || other.txnCount == txnCount)&&(identical(other.amountPaisa, amountPaisa) || other.amountPaisa == amountPaisa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,branchId,branchName,staffId,staffName,method,kind,txnCount,amountPaisa);

@override
String toString() {
  return 'DailyCollectionRow(branchId: $branchId, branchName: $branchName, staffId: $staffId, staffName: $staffName, method: $method, kind: $kind, txnCount: $txnCount, amountPaisa: $amountPaisa)';
}


}

/// @nodoc
abstract mixin class _$DailyCollectionRowCopyWith<$Res> implements $DailyCollectionRowCopyWith<$Res> {
  factory _$DailyCollectionRowCopyWith(_DailyCollectionRow value, $Res Function(_DailyCollectionRow) _then) = __$DailyCollectionRowCopyWithImpl;
@override @useResult
$Res call({
 String branchId, String branchName, String? staffId, String? staffName, PaymentMethod method, PaymentKind kind, int txnCount, int amountPaisa
});




}
/// @nodoc
class __$DailyCollectionRowCopyWithImpl<$Res>
    implements _$DailyCollectionRowCopyWith<$Res> {
  __$DailyCollectionRowCopyWithImpl(this._self, this._then);

  final _DailyCollectionRow _self;
  final $Res Function(_DailyCollectionRow) _then;

/// Create a copy of DailyCollectionRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branchId = null,Object? branchName = null,Object? staffId = freezed,Object? staffName = freezed,Object? method = null,Object? kind = null,Object? txnCount = null,Object? amountPaisa = null,}) {
  return _then(_DailyCollectionRow(
branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,staffId: freezed == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String?,staffName: freezed == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String?,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PaymentKind,txnCount: null == txnCount ? _self.txnCount : txnCount // ignore: cast_nullable_to_non_nullable
as int,amountPaisa: null == amountPaisa ? _self.amountPaisa : amountPaisa // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ArrearsRow {

 String get memberId; String get memberCode; String get fullName; String get phone; String get homeBranchId; String get homeBranchName; int get duePaisa;/// The `issued_on` of the oldest unsettled invoice. A `date`.
@NullablePlainDateConverter() DateTime? get oldestDueOn;/// Days since [oldestDueOn], measured in Postgres against the org's own
/// today. Not recomputed on the device.
 int? get ageDays;/// The ageing bucket the report assigned. Free text from the function,
/// not a Postgres enum, so it is carried as a string rather than
/// pretending to be one.
 String? get bucket;
/// Create a copy of ArrearsRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArrearsRowCopyWith<ArrearsRow> get copyWith => _$ArrearsRowCopyWithImpl<ArrearsRow>(this as ArrearsRow, _$identity);

  /// Serializes this ArrearsRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArrearsRow&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.homeBranchName, homeBranchName) || other.homeBranchName == homeBranchName)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.oldestDueOn, oldestDueOn) || other.oldestDueOn == oldestDueOn)&&(identical(other.ageDays, ageDays) || other.ageDays == ageDays)&&(identical(other.bucket, bucket) || other.bucket == bucket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,memberCode,fullName,phone,homeBranchId,homeBranchName,duePaisa,oldestDueOn,ageDays,bucket);

@override
String toString() {
  return 'ArrearsRow(memberId: $memberId, memberCode: $memberCode, fullName: $fullName, phone: $phone, homeBranchId: $homeBranchId, homeBranchName: $homeBranchName, duePaisa: $duePaisa, oldestDueOn: $oldestDueOn, ageDays: $ageDays, bucket: $bucket)';
}


}

/// @nodoc
abstract mixin class $ArrearsRowCopyWith<$Res>  {
  factory $ArrearsRowCopyWith(ArrearsRow value, $Res Function(ArrearsRow) _then) = _$ArrearsRowCopyWithImpl;
@useResult
$Res call({
 String memberId, String memberCode, String fullName, String phone, String homeBranchId, String homeBranchName, int duePaisa,@NullablePlainDateConverter() DateTime? oldestDueOn, int? ageDays, String? bucket
});




}
/// @nodoc
class _$ArrearsRowCopyWithImpl<$Res>
    implements $ArrearsRowCopyWith<$Res> {
  _$ArrearsRowCopyWithImpl(this._self, this._then);

  final ArrearsRow _self;
  final $Res Function(ArrearsRow) _then;

/// Create a copy of ArrearsRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? memberCode = null,Object? fullName = null,Object? phone = null,Object? homeBranchId = null,Object? homeBranchName = null,Object? duePaisa = null,Object? oldestDueOn = freezed,Object? ageDays = freezed,Object? bucket = freezed,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,homeBranchName: null == homeBranchName ? _self.homeBranchName : homeBranchName // ignore: cast_nullable_to_non_nullable
as String,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,oldestDueOn: freezed == oldestDueOn ? _self.oldestDueOn : oldestDueOn // ignore: cast_nullable_to_non_nullable
as DateTime?,ageDays: freezed == ageDays ? _self.ageDays : ageDays // ignore: cast_nullable_to_non_nullable
as int?,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ArrearsRow].
extension ArrearsRowPatterns on ArrearsRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArrearsRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArrearsRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArrearsRow value)  $default,){
final _that = this;
switch (_that) {
case _ArrearsRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArrearsRow value)?  $default,){
final _that = this;
switch (_that) {
case _ArrearsRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String memberCode,  String fullName,  String phone,  String homeBranchId,  String homeBranchName,  int duePaisa, @NullablePlainDateConverter()  DateTime? oldestDueOn,  int? ageDays,  String? bucket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArrearsRow() when $default != null:
return $default(_that.memberId,_that.memberCode,_that.fullName,_that.phone,_that.homeBranchId,_that.homeBranchName,_that.duePaisa,_that.oldestDueOn,_that.ageDays,_that.bucket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String memberCode,  String fullName,  String phone,  String homeBranchId,  String homeBranchName,  int duePaisa, @NullablePlainDateConverter()  DateTime? oldestDueOn,  int? ageDays,  String? bucket)  $default,) {final _that = this;
switch (_that) {
case _ArrearsRow():
return $default(_that.memberId,_that.memberCode,_that.fullName,_that.phone,_that.homeBranchId,_that.homeBranchName,_that.duePaisa,_that.oldestDueOn,_that.ageDays,_that.bucket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String memberCode,  String fullName,  String phone,  String homeBranchId,  String homeBranchName,  int duePaisa, @NullablePlainDateConverter()  DateTime? oldestDueOn,  int? ageDays,  String? bucket)?  $default,) {final _that = this;
switch (_that) {
case _ArrearsRow() when $default != null:
return $default(_that.memberId,_that.memberCode,_that.fullName,_that.phone,_that.homeBranchId,_that.homeBranchName,_that.duePaisa,_that.oldestDueOn,_that.ageDays,_that.bucket);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ArrearsRow implements ArrearsRow {
  const _ArrearsRow({required this.memberId, required this.memberCode, required this.fullName, required this.phone, required this.homeBranchId, required this.homeBranchName, required this.duePaisa, @NullablePlainDateConverter() this.oldestDueOn, this.ageDays, this.bucket});
  factory _ArrearsRow.fromJson(Map<String, dynamic> json) => _$ArrearsRowFromJson(json);

@override final  String memberId;
@override final  String memberCode;
@override final  String fullName;
@override final  String phone;
@override final  String homeBranchId;
@override final  String homeBranchName;
@override final  int duePaisa;
/// The `issued_on` of the oldest unsettled invoice. A `date`.
@override@NullablePlainDateConverter() final  DateTime? oldestDueOn;
/// Days since [oldestDueOn], measured in Postgres against the org's own
/// today. Not recomputed on the device.
@override final  int? ageDays;
/// The ageing bucket the report assigned. Free text from the function,
/// not a Postgres enum, so it is carried as a string rather than
/// pretending to be one.
@override final  String? bucket;

/// Create a copy of ArrearsRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArrearsRowCopyWith<_ArrearsRow> get copyWith => __$ArrearsRowCopyWithImpl<_ArrearsRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArrearsRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArrearsRow&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.homeBranchName, homeBranchName) || other.homeBranchName == homeBranchName)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.oldestDueOn, oldestDueOn) || other.oldestDueOn == oldestDueOn)&&(identical(other.ageDays, ageDays) || other.ageDays == ageDays)&&(identical(other.bucket, bucket) || other.bucket == bucket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,memberCode,fullName,phone,homeBranchId,homeBranchName,duePaisa,oldestDueOn,ageDays,bucket);

@override
String toString() {
  return 'ArrearsRow(memberId: $memberId, memberCode: $memberCode, fullName: $fullName, phone: $phone, homeBranchId: $homeBranchId, homeBranchName: $homeBranchName, duePaisa: $duePaisa, oldestDueOn: $oldestDueOn, ageDays: $ageDays, bucket: $bucket)';
}


}

/// @nodoc
abstract mixin class _$ArrearsRowCopyWith<$Res> implements $ArrearsRowCopyWith<$Res> {
  factory _$ArrearsRowCopyWith(_ArrearsRow value, $Res Function(_ArrearsRow) _then) = __$ArrearsRowCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String memberCode, String fullName, String phone, String homeBranchId, String homeBranchName, int duePaisa,@NullablePlainDateConverter() DateTime? oldestDueOn, int? ageDays, String? bucket
});




}
/// @nodoc
class __$ArrearsRowCopyWithImpl<$Res>
    implements _$ArrearsRowCopyWith<$Res> {
  __$ArrearsRowCopyWithImpl(this._self, this._then);

  final _ArrearsRow _self;
  final $Res Function(_ArrearsRow) _then;

/// Create a copy of ArrearsRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? memberCode = null,Object? fullName = null,Object? phone = null,Object? homeBranchId = null,Object? homeBranchName = null,Object? duePaisa = null,Object? oldestDueOn = freezed,Object? ageDays = freezed,Object? bucket = freezed,}) {
  return _then(_ArrearsRow(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,homeBranchName: null == homeBranchName ? _self.homeBranchName : homeBranchName // ignore: cast_nullable_to_non_nullable
as String,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,oldestDueOn: freezed == oldestDueOn ? _self.oldestDueOn : oldestDueOn // ignore: cast_nullable_to_non_nullable
as DateTime?,ageDays: freezed == ageDays ? _self.ageDays : ageDays // ignore: cast_nullable_to_non_nullable
as int?,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
