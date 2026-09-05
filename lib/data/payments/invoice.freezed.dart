// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invoice {

 String get id; String get orgId; String get branchId; String get memberId; String? get membershipId; String get invoiceNo;// Money is integer paisa end to end. Never a double, never converted here.
 int get subtotalPaisa; int get discountPaisa; int get totalPaisa;// Maintained by trigger from the payments rows. The app never writes
// this field.
 int get paidPaisa;// Generated column (`total_paisa - paid_paisa`, stored). Read-only —
// the app never writes this field.
 int get duePaisa; InvoiceStatus get status; DateTime get issuedOn; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.subtotalPaisa, subtotalPaisa) || other.subtotalPaisa == subtotalPaisa)&&(identical(other.discountPaisa, discountPaisa) || other.discountPaisa == discountPaisa)&&(identical(other.totalPaisa, totalPaisa) || other.totalPaisa == totalPaisa)&&(identical(other.paidPaisa, paidPaisa) || other.paidPaisa == paidPaisa)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.status, status) || other.status == status)&&(identical(other.issuedOn, issuedOn) || other.issuedOn == issuedOn)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,branchId,memberId,membershipId,invoiceNo,subtotalPaisa,discountPaisa,totalPaisa,paidPaisa,duePaisa,status,issuedOn,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Invoice(id: $id, orgId: $orgId, branchId: $branchId, memberId: $memberId, membershipId: $membershipId, invoiceNo: $invoiceNo, subtotalPaisa: $subtotalPaisa, discountPaisa: $discountPaisa, totalPaisa: $totalPaisa, paidPaisa: $paidPaisa, duePaisa: $duePaisa, status: $status, issuedOn: $issuedOn, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String branchId, String memberId, String? membershipId, String invoiceNo, int subtotalPaisa, int discountPaisa, int totalPaisa, int paidPaisa, int duePaisa, InvoiceStatus status, DateTime issuedOn, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? branchId = null,Object? memberId = null,Object? membershipId = freezed,Object? invoiceNo = null,Object? subtotalPaisa = null,Object? discountPaisa = null,Object? totalPaisa = null,Object? paidPaisa = null,Object? duePaisa = null,Object? status = null,Object? issuedOn = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,membershipId: freezed == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNo: null == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String,subtotalPaisa: null == subtotalPaisa ? _self.subtotalPaisa : subtotalPaisa // ignore: cast_nullable_to_non_nullable
as int,discountPaisa: null == discountPaisa ? _self.discountPaisa : discountPaisa // ignore: cast_nullable_to_non_nullable
as int,totalPaisa: null == totalPaisa ? _self.totalPaisa : totalPaisa // ignore: cast_nullable_to_non_nullable
as int,paidPaisa: null == paidPaisa ? _self.paidPaisa : paidPaisa // ignore: cast_nullable_to_non_nullable
as int,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,issuedOn: null == issuedOn ? _self.issuedOn : issuedOn // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String branchId,  String memberId,  String? membershipId,  String invoiceNo,  int subtotalPaisa,  int discountPaisa,  int totalPaisa,  int paidPaisa,  int duePaisa,  InvoiceStatus status,  DateTime issuedOn,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.membershipId,_that.invoiceNo,_that.subtotalPaisa,_that.discountPaisa,_that.totalPaisa,_that.paidPaisa,_that.duePaisa,_that.status,_that.issuedOn,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String branchId,  String memberId,  String? membershipId,  String invoiceNo,  int subtotalPaisa,  int discountPaisa,  int totalPaisa,  int paidPaisa,  int duePaisa,  InvoiceStatus status,  DateTime issuedOn,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.membershipId,_that.invoiceNo,_that.subtotalPaisa,_that.discountPaisa,_that.totalPaisa,_that.paidPaisa,_that.duePaisa,_that.status,_that.issuedOn,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String branchId,  String memberId,  String? membershipId,  String invoiceNo,  int subtotalPaisa,  int discountPaisa,  int totalPaisa,  int paidPaisa,  int duePaisa,  InvoiceStatus status,  DateTime issuedOn,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.orgId,_that.branchId,_that.memberId,_that.membershipId,_that.invoiceNo,_that.subtotalPaisa,_that.discountPaisa,_that.totalPaisa,_that.paidPaisa,_that.duePaisa,_that.status,_that.issuedOn,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Invoice implements Invoice {
  const _Invoice({required this.id, required this.orgId, required this.branchId, required this.memberId, this.membershipId, required this.invoiceNo, required this.subtotalPaisa, required this.discountPaisa, required this.totalPaisa, required this.paidPaisa, required this.duePaisa, required this.status, required this.issuedOn, this.notes, required this.createdAt, required this.updatedAt});
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String branchId;
@override final  String memberId;
@override final  String? membershipId;
@override final  String invoiceNo;
// Money is integer paisa end to end. Never a double, never converted here.
@override final  int subtotalPaisa;
@override final  int discountPaisa;
@override final  int totalPaisa;
// Maintained by trigger from the payments rows. The app never writes
// this field.
@override final  int paidPaisa;
// Generated column (`total_paisa - paid_paisa`, stored). Read-only —
// the app never writes this field.
@override final  int duePaisa;
@override final  InvoiceStatus status;
@override final  DateTime issuedOn;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.subtotalPaisa, subtotalPaisa) || other.subtotalPaisa == subtotalPaisa)&&(identical(other.discountPaisa, discountPaisa) || other.discountPaisa == discountPaisa)&&(identical(other.totalPaisa, totalPaisa) || other.totalPaisa == totalPaisa)&&(identical(other.paidPaisa, paidPaisa) || other.paidPaisa == paidPaisa)&&(identical(other.duePaisa, duePaisa) || other.duePaisa == duePaisa)&&(identical(other.status, status) || other.status == status)&&(identical(other.issuedOn, issuedOn) || other.issuedOn == issuedOn)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,branchId,memberId,membershipId,invoiceNo,subtotalPaisa,discountPaisa,totalPaisa,paidPaisa,duePaisa,status,issuedOn,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Invoice(id: $id, orgId: $orgId, branchId: $branchId, memberId: $memberId, membershipId: $membershipId, invoiceNo: $invoiceNo, subtotalPaisa: $subtotalPaisa, discountPaisa: $discountPaisa, totalPaisa: $totalPaisa, paidPaisa: $paidPaisa, duePaisa: $duePaisa, status: $status, issuedOn: $issuedOn, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String branchId, String memberId, String? membershipId, String invoiceNo, int subtotalPaisa, int discountPaisa, int totalPaisa, int paidPaisa, int duePaisa, InvoiceStatus status, DateTime issuedOn, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? branchId = null,Object? memberId = null,Object? membershipId = freezed,Object? invoiceNo = null,Object? subtotalPaisa = null,Object? discountPaisa = null,Object? totalPaisa = null,Object? paidPaisa = null,Object? duePaisa = null,Object? status = null,Object? issuedOn = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,membershipId: freezed == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNo: null == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String,subtotalPaisa: null == subtotalPaisa ? _self.subtotalPaisa : subtotalPaisa // ignore: cast_nullable_to_non_nullable
as int,discountPaisa: null == discountPaisa ? _self.discountPaisa : discountPaisa // ignore: cast_nullable_to_non_nullable
as int,totalPaisa: null == totalPaisa ? _self.totalPaisa : totalPaisa // ignore: cast_nullable_to_non_nullable
as int,paidPaisa: null == paidPaisa ? _self.paidPaisa : paidPaisa // ignore: cast_nullable_to_non_nullable
as int,duePaisa: null == duePaisa ? _self.duePaisa : duePaisa // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,issuedOn: null == issuedOn ? _self.issuedOn : issuedOn // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
