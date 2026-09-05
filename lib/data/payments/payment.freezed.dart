// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Payment {

 String get id; String get orgId; String get branchId; String get memberId; String? get membershipId; String? get invoiceId; PaymentKind get kind;// Money is integer paisa end to end. Never a double, never converted
// here. Negative for refunds — summing this column gives net cash.
 int get amountPaisa; PaymentMethod get method; String? get referenceNo; String? get reason; String? get collectedBy; DateTime get paidAt; String? get notes; DateTime get createdAt;
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentCopyWith<Payment> get copyWith => _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.amountPaisa, amountPaisa) || other.amountPaisa == amountPaisa)&&(identical(other.method, method) || other.method == method)&&(identical(other.referenceNo, referenceNo) || other.referenceNo == referenceNo)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.collectedBy, collectedBy) || other.collectedBy == collectedBy)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,branchId,memberId,membershipId,invoiceId,kind,amountPaisa,method,referenceNo,reason,collectedBy,paidAt,notes,createdAt);

@override
String toString() {
  return 'Payment(id: $id, orgId: $orgId, branchId: $branchId, memberId: $memberId, membershipId: $membershipId, invoiceId: $invoiceId, kind: $kind, amountPaisa: $amountPaisa, method: $method, referenceNo: $referenceNo, reason: $reason, collectedBy: $collectedBy, paidAt: $paidAt, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res>  {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) = _$PaymentCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String branchId, String memberId, String? membershipId, String? invoiceId, PaymentKind kind, int amountPaisa, PaymentMethod method, String? referenceNo, String? reason, String? collectedBy, DateTime paidAt, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$PaymentCopyWithImpl<$Res>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? branchId = null,Object? memberId = null,Object? membershipId = freezed,Object? invoiceId = freezed,Object? kind = null,Object? amountPaisa = null,Object? method = null,Object? referenceNo = freezed,Object? reason = freezed,Object? collectedBy = freezed,Object? paidAt = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,membershipId: freezed == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PaymentKind,amountPaisa: null == amountPaisa ? _self.amountPaisa : amountPaisa // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,referenceNo: freezed == referenceNo ? _self.referenceNo : referenceNo // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,collectedBy: freezed == collectedBy ? _self.collectedBy : collectedBy // ignore: cast_nullable_to_non_nullable
as String?,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payment value)  $default,){
final _that = this;
switch (_that) {
case _Payment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payment value)?  $default,){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String branchId,  String memberId,  String? membershipId,  String? invoiceId,  PaymentKind kind,  int amountPaisa,  PaymentMethod method,  String? referenceNo,  String? reason,  String? collectedBy,  DateTime paidAt,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.membershipId,_that.invoiceId,_that.kind,_that.amountPaisa,_that.method,_that.referenceNo,_that.reason,_that.collectedBy,_that.paidAt,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String branchId,  String memberId,  String? membershipId,  String? invoiceId,  PaymentKind kind,  int amountPaisa,  PaymentMethod method,  String? referenceNo,  String? reason,  String? collectedBy,  DateTime paidAt,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Payment():
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.membershipId,_that.invoiceId,_that.kind,_that.amountPaisa,_that.method,_that.referenceNo,_that.reason,_that.collectedBy,_that.paidAt,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String branchId,  String memberId,  String? membershipId,  String? invoiceId,  PaymentKind kind,  int amountPaisa,  PaymentMethod method,  String? referenceNo,  String? reason,  String? collectedBy,  DateTime paidAt,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.membershipId,_that.invoiceId,_that.kind,_that.amountPaisa,_that.method,_that.referenceNo,_that.reason,_that.collectedBy,_that.paidAt,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Payment implements Payment {
  const _Payment({required this.id, required this.orgId, required this.branchId, required this.memberId, this.membershipId, this.invoiceId, required this.kind, required this.amountPaisa, required this.method, this.referenceNo, this.reason, this.collectedBy, required this.paidAt, this.notes, required this.createdAt});
  factory _Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String branchId;
@override final  String memberId;
@override final  String? membershipId;
@override final  String? invoiceId;
@override final  PaymentKind kind;
// Money is integer paisa end to end. Never a double, never converted
// here. Negative for refunds — summing this column gives net cash.
@override final  int amountPaisa;
@override final  PaymentMethod method;
@override final  String? referenceNo;
@override final  String? reason;
@override final  String? collectedBy;
@override final  DateTime paidAt;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentCopyWith<_Payment> get copyWith => __$PaymentCopyWithImpl<_Payment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.amountPaisa, amountPaisa) || other.amountPaisa == amountPaisa)&&(identical(other.method, method) || other.method == method)&&(identical(other.referenceNo, referenceNo) || other.referenceNo == referenceNo)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.collectedBy, collectedBy) || other.collectedBy == collectedBy)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,branchId,memberId,membershipId,invoiceId,kind,amountPaisa,method,referenceNo,reason,collectedBy,paidAt,notes,createdAt);

@override
String toString() {
  return 'Payment(id: $id, orgId: $orgId, branchId: $branchId, memberId: $memberId, membershipId: $membershipId, invoiceId: $invoiceId, kind: $kind, amountPaisa: $amountPaisa, method: $method, referenceNo: $referenceNo, reason: $reason, collectedBy: $collectedBy, paidAt: $paidAt, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) = __$PaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String branchId, String memberId, String? membershipId, String? invoiceId, PaymentKind kind, int amountPaisa, PaymentMethod method, String? referenceNo, String? reason, String? collectedBy, DateTime paidAt, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$PaymentCopyWithImpl<$Res>
    implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? branchId = null,Object? memberId = null,Object? membershipId = freezed,Object? invoiceId = freezed,Object? kind = null,Object? amountPaisa = null,Object? method = null,Object? referenceNo = freezed,Object? reason = freezed,Object? collectedBy = freezed,Object? paidAt = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,membershipId: freezed == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PaymentKind,amountPaisa: null == amountPaisa ? _self.amountPaisa : amountPaisa // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,referenceNo: freezed == referenceNo ? _self.referenceNo : referenceNo // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,collectedBy: freezed == collectedBy ? _self.collectedBy : collectedBy // ignore: cast_nullable_to_non_nullable
as String?,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
